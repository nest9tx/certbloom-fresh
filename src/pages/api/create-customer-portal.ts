import type { NextApiRequest, NextApiResponse } from 'next';
import Stripe from 'stripe';
import { getStripeCustomerIdForUser } from '../../lib/getStripeCustomerId';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export default async function handler(req: NextApiRequest, res: NextApiResponse): Promise<void> {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }


  // Get Supabase access token from Authorization header
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

  // Get Stripe customer ID from Supabase user_profiles
  const stripeCustomerId = await getStripeCustomerIdForUser(uid);
  if (!stripeCustomerId) {
    return res.status(404).json({ error: 'Stripe customer ID not found for user' });
  }

  try {
    const portalSession = await stripe.billingPortal.sessions.create({
      customer: stripeCustomerId,
      return_url: process.env.NEXT_PUBLIC_BASE_URL || 'https://certbloom.com/dashboard',
    });
    return res.status(200).json({ url: portalSession.url });
  } catch (error) {
    return res.status(500).json({ error: 'Stripe portal error', details: error });
  }
}
