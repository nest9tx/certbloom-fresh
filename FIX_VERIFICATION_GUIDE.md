# CertBloom Fix Verification Guide

## 🎯 **Issues Fixed:**

1. **Question Randomization** - Extended exclusion window to 24 hours and enhanced database function
2. **Mandala Data Updates** - Improved session completion tracking and refresh mechanisms  
3. **Subscription Enforcement** - Hard-coded 5-question limits for free users

## 🚀 **Steps to Test:**

### 1. **Run the Database Fix**
```sql
-- Copy and paste complete-diagnosis-fix.sql into Supabase SQL Editor
-- This will:
-- ✅ Diagnose current issues
-- ✅ Recreate randomization function with 24-hour exclusion
-- ✅ Set up mandala data triggers
-- ✅ Create sample progress data for testing
```

### 2. **Test Question Randomization**
1. Go to practice session: `/practice/session?type=quick`
2. Complete a 5-question session
3. Immediately start another session
4. **Expected:** Different questions should appear
5. **Debug:** Open browser console and run `debugQuestionSystem()`

### 3. **Test Mandala Updates**
1. Go to dashboard after completing a session
2. **Expected:** Mandala should show updated progress
3. **Debug:** Check console for "🔄 Mandala refreshing" messages
4. **Manual Refresh:** Check localStorage for `lastSessionCompleted` data

### 4. **Test Free User Limits**
1. Ensure user has free subscription status
2. Try starting any practice session
3. **Expected:** Maximum 5 questions regardless of session type
4. **Debug:** Check console for subscription enforcement logs

## 🔍 **Debugging Commands:**

### Browser Console Tests:
```javascript
// Test question randomization
debugQuestionSystem()

// Check session data
JSON.parse(localStorage.getItem('lastSessionCompleted') || '{}')

// Manual mandala refresh
window.dispatchEvent(new CustomEvent('sessionCompleted', {
  detail: { test: true }
}))
```

### Supabase SQL Queries:
```sql
-- Check if function exists
SELECT routine_name FROM information_schema.routines 
WHERE routine_name = 'get_randomized_adaptive_questions';

-- Check user progress
SELECT * FROM user_progress ORDER BY updated_at DESC LIMIT 5;

-- Check recent sessions
SELECT * FROM practice_sessions ORDER BY completed_at DESC LIMIT 5;

-- Test function directly
SELECT * FROM get_randomized_adaptive_questions(
  'your-user-id-here'::UUID, 
  'EC-6 Core Subjects', 
  5, 
  24
);
```

## 📊 **Expected Results:**

### ✅ **Question Randomization Working:**
- Different questions each session
- Console shows "Randomization function returned X questions"
- No repeated questions within 24 hours

### ✅ **Mandala Updates Working:**
- Progress visualization changes after sessions
- Console shows "Session data saved successfully"
- localStorage contains session completion data

### ✅ **Subscription Limits Working:**
- Free users limited to 5 questions max
- Console shows subscription enforcement logs
- URL parameters don't override free limits

## 🐛 **Common Issues:**

### Questions Still Repeating:
1. Check if database function deployed: `SELECT routine_name FROM information_schema.routines WHERE routine_name = 'get_randomized_adaptive_questions';`
2. Verify questions exist: `SELECT COUNT(*) FROM questions WHERE active = true;`
3. Clear recent attempts: `DELETE FROM user_question_attempts WHERE user_id = 'your-id';`

### Mandala Not Updating:
1. Check practice sessions saved: `SELECT * FROM practice_sessions ORDER BY completed_at DESC LIMIT 3;`
2. Verify progress trigger: Check for user_progress records after sessions
3. Check browser console for refresh events

### Free User Getting Too Many Questions:
1. Verify subscription status in user_profiles table
2. Check console logs for subscription enforcement
3. Clear browser cache and test fresh session

## 📝 **Next Steps:**
1. Run complete-diagnosis-fix.sql in Supabase
2. Test each scenario above
3. Check console logs and database for verification
4. Report any remaining issues with specific console error messages
