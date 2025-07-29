import type { NextApiRequest, NextApiResponse } from 'next';
import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { plan } = req.body; // 'monthly' or 'yearly'
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid authorization header' });
  }
  const accessToken = authHeader.replace('Bearer ', '');

  // Get user UID from Supabase JWT
  let uid = null;
  try {
    const jwtPayload = JSON.parse(Buffer.from(accessToken.split('.')[1], 'base64').toString());
    uid = jwtPayload.sub;
  } catch {
    return res.status(401).json({ error: 'Invalid Supabase JWT' });
  }
  if (!uid) {
    return res.status(401).json({ error: 'Missing user UID' });
  }

  // Check for existing Stripe customer ID
  let stripeCustomerId: string | null = null;
  const { data: userProfile, error } = await supabase
    .from('user_profiles')
    .select('stripe_customer_id, email')
    .eq('uid', uid)
    .single();
  if (error || !userProfile) {
    return res.status(404).json({ error: 'User profile not found' });
  }
  stripeCustomerId = userProfile.stripe_customer_id;

  // If no Stripe customer, create one and save to Supabase
  if (!stripeCustomerId) {
    const customer = await stripe.customers.create({
      email: userProfile.email,
      metadata: { uid },
    });
    stripeCustomerId = customer.id;
    await supabase
      .from('user_profiles')
      .update({ stripe_customer_id: stripeCustomerId })
      .eq('uid', uid);
  }

  // Set price ID based on plan
  let priceId = '';
  if (plan === 'monthly') {
    priceId = process.env.STRIPE_MONTHLY_PRICE_ID!;
  } else if (plan === 'yearly') {
    priceId = process.env.STRIPE_YEARLY_PRICE_ID!;
  } else {
    return res.status(400).json({ error: 'Invalid plan type' });
  }

  // Create Stripe Checkout session
  try {
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
      success_url: `${process.env.NEXT_PUBLIC_BASE_URL}/dashboard?success=true`,
      cancel_url: `${process.env.NEXT_PUBLIC_BASE_URL}/pricing?canceled=true`,
    });
    return res.status(200).json({ url: session.url });
  } catch (error) {
    return res.status(500).json({ error: 'Stripe Checkout error', details: error });
  }
}
