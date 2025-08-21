# CertBloom AI Coding Agent Instructions

## Project Overview
CertBloom is a Next.js application for Texas teacher certification exam preparation with adaptive learning, built with:
- **Frontend**: Next.js 14 (App Router) + TypeScript + Tailwind CSS
- **Backend**: Next.js API Routes (Pages Router for Stripe) + Supabase
- **Payments**: Stripe subscriptions (monthly/yearly plans)
- **Auth**: Supabase Auth with custom auth context

## Architecture Patterns

### Hybrid Router Structure
- Main app uses **App Router** (`src/app/`)
- Stripe API routes use **Pages Router** (`src/pages/api/stripe/`) for webhook compatibility
- Auth context shared via `lib/auth-context.tsx`

### Database Schema
- Table name: `user_profiles` (not `profiles`)
- Key columns: `id`, `email`, `stripe_customer_id`, `subscription_status`
- Run schema updates via Supabase SQL editor using `database-schema.sql`

### Stripe Integration Flow
1. Frontend calls `/api/stripe/create-checkout-session` with Bearer token
2. API extracts user ID from Supabase JWT, creates/retrieves Stripe customer
3. Webhook at `/api/stripe/webhook` updates `user_profiles.subscription_status`
4. Dashboard reflects subscription changes

## Critical Debugging Patterns

### Payment Issues
- Check Stripe customer ID creation in `user_profiles` table
- Verify webhook receives `userId` in session metadata
- Use `console.log` in API routes for debugging (visible in Vercel/terminal)

### Environment Variables Required
```
STRIPE_SECRET_KEY=sk_test_...
STRIPE_MONTHLY_PRICE_ID=price_...
STRIPE_YEARLY_PRICE_ID=price_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_SUPABASE_URL=https://...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

## Common Fixes

### "No such customer" Error
- Missing `stripe_customer_id` column in database
- User profile not created before checkout
- Solution: Add Stripe columns to schema, ensure customer creation

### Webhook Not Updating Subscription
- Missing `userId` in Stripe session metadata
- Wrong table/column names in webhook
- Solution: Verify metadata flow and table schema

### UI State Issues
- Use specific loading states: `loadingPlan: 'monthly' | 'yearly' | null`
- Always reset loading state in `finally` blocks
- Test both subscription buttons independently

## Development Commands
```bash
npm run dev          # Start development server
npm run build        # Production build
```

The project supports both free and Pro subscription tiers with Stripe-powered billing and a mission to fund educational pods in the four corners region.
