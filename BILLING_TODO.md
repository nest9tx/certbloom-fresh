# Billing Management TODO

## Current State
- ✅ Stripe test payment links integrated
- ✅ Monthly ($25) and Yearly ($99) subscription options
- ✅ Test mode with clear indicators
- ✅ Email support for cancellations (support@certbloom.com)

## Next Steps for Billing Management

### Phase 1: Basic Billing Portal
- [ ] Add Stripe Customer Portal integration
- [ ] Create billing management page in dashboard (`/dashboard/billing`)
- [ ] Allow users to:
  - View current subscription status
  - Download invoices
  - Update payment method
  - Cancel subscription (with confirmation)

### Phase 2: Enhanced Management
- [ ] Subscription upgrade/downgrade flow
- [ ] Pause subscription option
- [ ] Billing history with detailed breakdowns
- [ ] Failed payment retry logic
- [ ] Email notifications for billing events

### Phase 3: Advanced Features
- [ ] Team/institutional billing
- [ ] Coupon/discount code system
- [ ] Usage-based billing options
- [ ] Refund management interface

## Technical Implementation Notes

### Stripe Integration
```javascript
// Example: Add to dashboard/billing/page.tsx
const handleManageBilling = async () => {
  const response = await fetch('/api/create-customer-portal', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ customerId: user.stripeCustomerId })
  })
  const { url } = await response.json()
  window.location.href = url
}
```

### Database Schema Additions
```sql
-- Add to user_profiles table
ALTER TABLE user_profiles ADD COLUMN stripe_customer_id TEXT;
ALTER TABLE user_profiles ADD COLUMN subscription_status TEXT;
ALTER TABLE user_profiles ADD COLUMN subscription_plan TEXT;
ALTER TABLE user_profiles ADD COLUMN subscription_end_date TIMESTAMP WITH TIME ZONE;
```

### API Routes Needed
- `/api/create-customer-portal` - Generate Stripe Customer Portal URL
- `/api/webhook/stripe` - Handle Stripe webhooks for subscription events
- `/api/subscription/status` - Check current subscription status
- `/api/subscription/cancel` - Cancel subscription programmatically

## Support Process (Current)
1. User emails support@certbloom.com
2. Manual cancellation/management via Stripe dashboard
3. Email confirmation to user

## Future Self-Service Process
1. User visits `/dashboard/billing`
2. Clicks "Manage Billing" → Redirects to Stripe Customer Portal
3. User manages subscription directly
4. Automatic updates reflected in dashboard
