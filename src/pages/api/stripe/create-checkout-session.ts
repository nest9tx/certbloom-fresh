import type { NextApiRequest, NextApiResponse } from 'next';
import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export default async function handler(req: NextApiRequest, res: NextApiResponse): Promise<void> {
  if (req.method !== 'POST') {
    console.error('Method not allowed:', req.method);
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  // Check required environment variables
  if (!process.env.STRIPE_SECRET_KEY) {
    console.error('Missing STRIPE_SECRET_KEY environment variable');
    res.status(500).json({ error: 'Stripe configuration error: Missing secret key' });
    return;
  }
  
  if (!process.env.STRIPE_MONTHLY_PRICE_ID) {
    console.error('Missing STRIPE_MONTHLY_PRICE_ID environment variable');
    res.status(500).json({ error: 'Stripe configuration error: Missing monthly price ID' });
    return;
  }
  
  if (!process.env.STRIPE_YEARLY_PRICE_ID) {
    console.error('Missing STRIPE_YEARLY_PRICE_ID environment variable');
    return res.status(500).json({ error: 'Stripe configuration error: Missing yearly price ID' });
  }

  const { plan } = req.body; // 'monthly' or 'yearly'
  
  console.log('🚀 Starting checkout session creation for plan:', plan);
  
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.error('Missing or invalid authorization header:', authHeader);
    return res.status(401).json({ error: 'Missing or invalid authorization header' });
  }
  const accessToken = authHeader.replace('Bearer ', '');

  // Create authenticated Supabase client with the user's token
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      global: {
        headers: {
          Authorization: `Bearer ${accessToken}`
        }
      }
    }
  );

  // Get user UID from Supabase JWT
  let uid = null;
  try {
    const jwtPayload = JSON.parse(Buffer.from(accessToken.split('.')[1], 'base64').toString());
    uid = jwtPayload.sub;
  } catch (err) {
    console.error('Invalid Supabase JWT:', err);
    return res.status(401).json({ error: 'Invalid Supabase JWT' });
  }
  if (!uid) {
    console.error('Missing user UID from JWT payload:', accessToken);
    return res.status(401).json({ error: 'Missing user UID' });
  }

  // Create admin client for operations that might need to bypass RLS
  const supabaseAdmin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  );

  // Check for existing Stripe customer ID
  let stripeCustomerId: string | null = null;
  let userEmail = '';
  
  try {
    // First try with the authenticated client
    const { data: userProfile, error } = await supabase
      .from('user_profiles')
      .select('stripe_customer_id, email')
      .eq('id', uid)
      .single();
    
    if (error) {
      console.log('Error fetching user profile with authenticated client:', error);
      
      // Fall back to admin client if available
      if (process.env.SUPABASE_SERVICE_ROLE_KEY) {
        const { data: adminUserProfile, error: adminError } = await supabaseAdmin
          .from('user_profiles')
          .select('stripe_customer_id, email')
          .eq('id', uid)
          .single();
        
        if (adminError) {
          console.error('Error fetching user profile with admin client:', adminError);
        } else if (adminUserProfile) {
          stripeCustomerId = adminUserProfile.stripe_customer_id;
          userEmail = adminUserProfile.email;
        }
      }
    } else if (userProfile) {
      stripeCustomerId = userProfile.stripe_customer_id;
      userEmail = userProfile.email;
    }
    
    // If we still don't have a user profile, try to create one
    if (!stripeCustomerId) {
      // Get email from JWT payload
      const jwtPayload = JSON.parse(Buffer.from(accessToken.split('.')[1], 'base64').toString());
      userEmail = jwtPayload.email || '';
      
      if (!userEmail) {
        console.error('Email not found in JWT payload');
        return res.status(400).json({ error: 'Email not found in user data' });
      }
      
      // Try to create the profile with admin client if available
      if (process.env.SUPABASE_SERVICE_ROLE_KEY) {
        const { error: createError } = await supabaseAdmin
          .from('user_profiles')
          .insert([
            { 
              id: uid, 
              email: userEmail, 
              created_at: new Date().toISOString(), 
              updated_at: new Date().toISOString() 
            }
          ])
          .select()
          .single();
          
        if (createError) {
          console.error('Failed to create user profile with admin client:', createError);
        }
      }
    }
  } catch (err) {
    console.error('Error in user profile operations:', err);
    // Continue anyway, we'll create a Stripe customer with the email from JWT
  }

  // If we still don't have an email, try to get it from the JWT
  if (!userEmail) {
    try {
      const jwtPayload = JSON.parse(Buffer.from(accessToken.split('.')[1], 'base64').toString());
      userEmail = jwtPayload.email || '';
      
      if (!userEmail) {
        console.error('Email not found in JWT payload');
        return res.status(400).json({ error: 'Email not found in user data' });
      }
    } catch (err) {
      console.error('Error extracting email from JWT:', err);
      return res.status(500).json({ error: 'Could not determine user email' });
    }
  }

  // If no Stripe customer, create one and save to Supabase
  if (!stripeCustomerId) {
    console.log('Creating new Stripe customer for user:', uid, 'with email:', userEmail);
    try {
      const customer = await stripe.customers.create({
        email: userEmail,
        metadata: { uid },
      });
      stripeCustomerId = customer.id;
      console.log('Created Stripe customer:', stripeCustomerId);
      
      // Try to update the profile with the new Stripe customer ID
      if (process.env.SUPABASE_SERVICE_ROLE_KEY) {
        const { error: updateError } = await supabaseAdmin
          .from('user_profiles')
          .update({ stripe_customer_id: stripeCustomerId })
          .eq('id', uid);
          
        if (updateError) {
          console.error('Error updating Stripe customer ID with admin client:', updateError);
          // Continue anyway since we have the Stripe customer ID
        } else {
          console.log('Successfully updated user profile with Stripe customer ID');
        }
      }
    } catch (err) {
      console.error('Error creating Stripe customer:', err);
      return res.status(500).json({ error: 'Error creating Stripe customer' });
    }
  } else {
    console.log('Using existing Stripe customer:', stripeCustomerId);
  }

  // Set price ID based on plan
  let priceId = '';
  console.log('🏷️ Setting price ID for plan:', plan);
  
  if (plan === 'monthly') {
    priceId = process.env.STRIPE_MONTHLY_PRICE_ID!;
    console.log('💳 Monthly price ID:', priceId);
  } else if (plan === 'yearly') {
    priceId = process.env.STRIPE_YEARLY_PRICE_ID!;
    console.log('💳 Yearly price ID:', priceId);
  } else {
    console.error('❌ Invalid plan type:', plan);
    return res.status(400).json({ error: `Invalid plan type: ${plan}. Must be 'monthly' or 'yearly'.` });
  }
  
  if (!priceId) {
    console.error('❌ Price ID is empty for plan:', plan);
    return res.status(500).json({ error: `Price ID not configured for plan: ${plan}` });
  }

  // Get base URL with fallback
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || '';
  let successUrl = `${baseUrl}/dashboard?success=true`;
  let cancelUrl = `${baseUrl}/pricing?canceled=true`;
  
  // Ensure URLs have proper protocol
  if (!successUrl.startsWith('http')) {
    // Use the request's protocol and host if available
    const protocol = req.headers['x-forwarded-proto'] || 'http';
    const host = req.headers.host || 'localhost:3000';
    successUrl = `${protocol}://${host}/dashboard?success=true`;
    cancelUrl = `${protocol}://${host}/pricing?canceled=true`;
  }
  
  console.log('Success URL:', successUrl);
  console.log('Cancel URL:', cancelUrl);

  // Create Stripe Checkout session
  try {
    console.log('Creating Stripe checkout session with:');
    console.log('- Customer ID:', stripeCustomerId);
    console.log('- Price ID:', priceId);
    console.log('- User ID for metadata:', uid);
    
    const session = await stripe.checkout.sessions.create({
      customer: stripeCustomerId,
      payment_method_types: ['card'],
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: {
        userId: uid,
      },
    });
    
    console.log('Successfully created Stripe session:', session.id);
    return res.status(200).json({ url: session.url });
  } catch (error) {
    console.error('Stripe Checkout error:', error);
    return res.status(500).json({ error: 'Stripe Checkout error', details: error });
  }
}