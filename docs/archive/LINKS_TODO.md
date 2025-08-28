# Website Links & Pages TODO

## Current Status: ✅ = Live, 🚧 = Placeholder, ❌ = Missing

### Main Navigation Links
- ✅ **Home** (`/`) - Complete
- ✅ **Pricing** (`/pricing`) - Complete with Stripe integration
- ✅ **About** (`/about`) - Complete
- ✅ **Contact** (`/contact`) - Complete
- ✅ **Dashboard** (`/dashboard`) - Complete with authentication
- ✅ **Practice Session** (`/practice/session`) - Complete

### Footer Links

#### Quick Links Section
- ✅ **Pricing** - Links to `/pricing`
- ✅ **Sign In** - Links to `/auth`
- ✅ **Features** - Links to `#features` (homepage anchor)
- ✅ **About** - Links to `/about`

#### Support Section
- ✅ **Email Support** - `support@certbloom.com` (working)
- ✅ **Help Center** - Links to `/contact` (reasonable redirect)
- 🚧 **Privacy Policy** - Marked as "Coming Soon"
- 🚧 **Terms of Service** - Marked as "Coming Soon"

#### Social Media
- 🚧 **Twitter** - Marked as "Coming Soon"
- 🚧 **LinkedIn** - Marked as "Coming Soon" 
- 🚧 **Instagram** - Marked as "Coming Soon"

## Priority Order for Completion

### High Priority (Legal/Compliance)
1. **Privacy Policy** (`/privacy`) - Required for user data collection
2. **Terms of Service** (`/terms`) - Required for subscription service

### Medium Priority (User Experience)
3. **Help Center/FAQ** (`/help` or enhanced `/contact`) - Common user questions
4. **Features Page** (`/features`) - Detailed feature breakdown

### Low Priority (Marketing/Growth)
5. **Social Media Accounts** - When ready for public marketing push
6. **Blog/Resources** (`/blog`) - Content marketing
7. **Testimonials Page** (`/testimonials`) - More detailed success stories

## Legal Pages Content Needed

### Privacy Policy Requirements
- Data collection practices
- Cookie usage
- Supabase data handling
- Stripe payment processing
- User rights (CCPA, GDPR considerations)
- Contact information for privacy requests

### Terms of Service Requirements
- Service description
- User responsibilities
- Payment terms (monthly/yearly billing)
- Cancellation policy
- Limitation of liability
- Dispute resolution
- Pass guarantee terms

## Implementation Notes

### Current State
- All placeholder links are clearly marked as "Coming Soon"
- No broken links or 404 errors
- Help Center redirects to Contact page (reasonable interim solution)
- Email support is fully functional

### Next Steps
1. Create privacy policy and terms pages first (legal necessity)
2. Set up social media accounts when ready for marketing
3. Consider adding a `/help` page with detailed FAQs
4. Track user questions to inform help content

### Technical Implementation
- Add new pages to `/src/app/` directory
- Update footer links when pages are ready
- Remove "Coming Soon" indicators
- Ensure consistent navigation across all pages
