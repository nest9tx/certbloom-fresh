import type { NextApiRequest, NextApiResponse } from 'next';
import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';

// This is a buffer helper function
async function buffer(readable: NodeJS.ReadableStream) {
  const chunks = [];
  for await (const chunk of readable) {
    chunks.push(typeof chunk === 'string' ? Buffer.from(chunk) : chunk);
  }
  return Buffer.concat(chunks);
}

// Stripe API client
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2025-06-30.basil' });

// Supabase Admin client for secure server-side operations
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

// Webhook secret from Stripe dashboard
const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

export const config = {
  api: {
    bodyParser: false,
  },
};

export default async function handler(req: NextApiRequest, res: NextApiResponse): Promise<void> {
  console.log('🔔 Webhook received:', req.method);
  
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    res.status(405).end('Method Not Allowed');
    return;
  }

  const buf = await buffer(req);
  const sig = req.headers['stripe-signature'];

  let event: Stripe.Event;

  try {
    if (!sig || !endpointSecret) {
      console.error('❌ Webhook Error: Missing Stripe signature or secret.');
      res.status(400).send('Webhook Error: Missing configuration.');
      return;
    }
    event = stripe.webhooks.constructEvent(buf, sig, endpointSecret);
    console.log('✅ Webhook signature verified. Event type:', event.type);
  } catch (err) {
    console.error(`❌ Webhook signature verification failed: ${(err as Error).message}`);
    res.status(400).send(`Webhook Error: ${(err as Error).message}`);
    return;
  }

    // Handle the checkout.session.completed event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session;
    const userId = session.metadata?.userId;
    const stripeCustomerId = session.customer as string;
    const stripeSubscriptionId = session.subscription as string;

    console.log('🎯 Processing checkout.session.completed event');
    console.log('- User ID from metadata:', userId);
    console.log('- Stripe Customer ID:', stripeCustomerId);
    console.log('- Stripe Subscription ID:', stripeSubscriptionId);

    if (!userId) {
      console.error('❌ Webhook Error: No userId in session metadata');
      res.status(400).send('Webhook Error: Missing user ID in metadata.');
      return;
    }

    // Get subscription details to determine plan and end date
    let subscriptionPlan = null;
    let subscriptionEndDate = null;
    
    if (stripeSubscriptionId) {
      try {
        const subscription = await stripe.subscriptions.retrieve(stripeSubscriptionId);
        const priceId = subscription.items.data[0]?.price.id;
        
        // Determine plan based on price ID
        if (priceId === process.env.STRIPE_MONTHLY_PRICE_ID) {
          subscriptionPlan = 'monthly';
        } else if (priceId === process.env.STRIPE_YEARLY_PRICE_ID) {
          subscriptionPlan = 'yearly';
        }
        
        // Calculate end date from current_period_end (Stripe timestamp is in seconds)
        if (subscription && 'current_period_end' in subscription) {
          subscriptionEndDate = new Date((subscription.current_period_end as number) * 1000).toISOString();
        }
        
        console.log('📋 Subscription details:', { subscriptionPlan, subscriptionEndDate });
      } catch (err) {
        console.error('Error retrieving subscription details:', err);
      }
    }

    try {
      console.log('🔄 Updating user profile in database...');
      
      // First, try updating with all fields
      let updateData: Record<string, string | boolean> = {
        subscription_status: 'active',
        stripe_customer_id: stripeCustomerId,
      };
      
      // Try to add subscription details if columns exist
      if (stripeSubscriptionId) {
        updateData.stripe_subscription_id = stripeSubscriptionId;
      }
      if (subscriptionPlan) {
        updateData.subscription_plan = subscriptionPlan;
      }
      if (subscriptionEndDate) {
        updateData.subscription_end_date = subscriptionEndDate;
      }
      
      const { error } = await supabaseAdmin
        .from('user_profiles')
        .update(updateData)
        .eq('id', userId);

      // If error due to missing columns, try with just essential fields
      if (error && error.code === '42703') {
        console.log('🔄 Column missing, trying minimal update...');
        updateData = {
          subscription_status: 'active',
          stripe_customer_id: stripeCustomerId,
        };
        
        const { error: minimalError } = await supabaseAdmin
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId);
          
        if (minimalError) {
          console.error(`❌ Minimal Supabase update error for user ${userId}:`, minimalError);
          res.status(500).send(`Webhook Error: ${minimalError.message}`);
          return;
        }
        
        console.log(`✅ Successfully updated subscription status (minimal) for user: ${userId}`);
        console.log(`⚠️  Note: Additional columns (stripe_subscription_id, subscription_plan, subscription_end_date) need to be added to user_profiles table`);
      } else if (error) {
        console.error(`❌ Supabase update error for user ${userId}:`, error);
        res.status(500).send(`Webhook Error: ${error.message}`);
        return;
      } else {
        console.log(`✅ Successfully updated full subscription data for user: ${userId}`);
      }
    } catch (dbError) {
      console.error('❌ Webhook handler database error:', dbError);
      res.status(500).send('Webhook handler database error');
      return;
    }
  }

  // Handle other subscription events like cancellations
  if (event.type === 'customer.subscription.deleted') {
    const subscription = event.data.object as Stripe.Subscription;
    const stripeCustomerId = subscription.customer as string;

    const { error } = await supabaseAdmin
      .from('user_profiles')
      .update({ subscription_status: 'canceled' })
      .eq('stripe_customer_id', stripeCustomerId);

    if (error) {
      console.error(`Supabase cancellation update error for customer ${stripeCustomerId}:`, error);
    } else {
      console.log(`Successfully canceled subscription for customer: ${stripeCustomerId}`);
    }
  }

  res.status(200).json({ received: true });
}