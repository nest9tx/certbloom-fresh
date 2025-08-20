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

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).end('Method Not Allowed');
  }

  const buf = await buffer(req);
  const sig = req.headers['stripe-signature'];

  let event: Stripe.Event;

  try {
    if (!sig || !endpointSecret) {
      console.error('Webhook Error: Missing Stripe signature or secret.');
      return res.status(400).send('Webhook Error: Missing configuration.');
    }
    event = stripe.webhooks.constructEvent(buf, sig, endpointSecret);
  } catch (err) {
    console.error(`Webhook signature verification failed: ${(err as Error).message}`);
    return res.status(400).send(`Webhook Error: ${(err as Error).message}`);
  }

  // Handle the checkout.session.completed event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session;
    const userId = session.metadata?.userId;
    const stripeCustomerId = session.customer as string;
    const stripeSubscriptionId = session.subscription as string;

    if (!userId) {
      console.error('Webhook Error: No userId in session metadata');
      return res.status(400).send('Webhook Error: Missing user ID in metadata.');
    }

    try {
      const { error } = await supabaseAdmin
        .from('user_profiles') // Ensure this is your profiles table name
        .update({
          subscription_status: 'active', // Or 'premium', etc.
          stripe_customer_id: stripeCustomerId,
          stripe_subscription_id: stripeSubscriptionId,
        })
        .eq('id', userId); // Use the user's ID to find the correct profile

      if (error) {
        console.error(`Supabase update error for user ${userId}:`, error);
        return res.status(500).send(`Webhook Error: ${error.message}`);
      }

      console.log(`Successfully updated subscription for user: ${userId}`);
    } catch (dbError) {
      console.error('Webhook handler database error:', dbError);
      return res.status(500).send('Webhook handler database error');
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