# User Profile Creation Fix

## Problem
Users signing up were experiencing PGRST116 "0 rows returned" errors because user profiles weren't being created in the `user_profiles` table during the signup process. This caused:

1. Dashboard mandala not displaying
2. Practice sessions failing to load  
3. Certification goals not being saved
4. General authentication flow issues

## Root Cause
The issue was that Supabase's Row Level Security (RLS) policies prevented profile creation during signup because:

1. When `createUserProfile` was called during signup, the user wasn't yet "authenticated" in the session
2. The `auth.uid()` function returned `null` during signup before email confirmation
3. RLS policy `"Users can insert own profile"` blocked the insert operation
4. The regular Supabase client couldn't bypass RLS restrictions

## Solution Implemented

### 1. Added Service Role Client
- Created `supabaseAdmin` client with service role key that bypasses RLS
- Added proper environment variable handling and validation
- Located in `lib/supabase.ts`

### 2. Updated Profile Creation Function
- Modified `createUserProfile` to use `supabaseAdmin` instead of regular `supabase` client
- Added comprehensive logging for debugging
- Enhanced error handling and reporting

### 3. Improved Auth Context Logic
- Fixed signup flow to create profiles immediately after user creation
- Added fallback handling for existing users without profiles
- Improved localStorage management for certification goals
- Enhanced error handling and user feedback

### 4. Created Diagnostic Tools
- `profile-fix.sql`: SQL script to identify and fix existing users without profiles
- `test-profile-creation.js`: Test script to verify profile creation functionality

## Files Modified

1. **lib/supabase.ts**
   - Added `supabaseAdmin` client with service role
   - Updated `createUserProfile` to use admin privileges
   - Enhanced logging and error handling

2. **lib/auth-context.tsx** 
   - Fixed signup flow to create profiles immediately
   - Improved auth state listener for existing users
   - Better localStorage and certification goal handling

3. **New diagnostic files**
   - `profile-fix.sql`: Database fix for existing users
   - `test-profile-creation.js`: Testing functionality

## Testing Steps

1. **Run the profile fix SQL** in Supabase SQL editor:
   ```bash
   # Copy contents of profile-fix.sql and run in Supabase
   ```

2. **Test new user signup**:
   - Go to /select-certification
   - Choose a certification 
   - Sign up with new email
   - Verify profile is created immediately

3. **Test existing user login**:
   - Sign in with existing account
   - Verify profile exists or gets created
   - Check dashboard displays properly

4. **Verify dashboard functionality**:
   - Check mandala visualization appears
   - Verify practice sessions load
   - Confirm certification goals are saved

## Environment Requirements

Ensure these environment variables are set:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` 
- `SUPABASE_SERVICE_ROLE_KEY` (NEW - required for admin operations)

## Expected Behavior After Fix

1. ✅ New users get profiles created immediately during signup
2. ✅ Existing users without profiles get them created on login
3. ✅ Dashboard mandala displays properly
4. ✅ Practice sessions load without PGRST116 errors
5. ✅ Certification goals are saved and retrievable
6. ✅ No more "hanging" signup processes

The fix maintains security by using RLS for normal operations while allowing profile creation through admin privileges during the signup flow.
