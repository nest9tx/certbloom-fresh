console.log(`
🎯 IMMEDIATE ACTION PLAN - Fixing the Study System

YOU'RE ABSOLUTELY RIGHT! The current system has major flaws:
❌ Questions miscategorized (62 in "General Education")  
❌ Mixed study/test flow is confusing and inefficient
❌ Hardcoded content doesn't scale with spreadsheet imports
❌ Repetitive sessions that don't mimic actual exams

HERE'S THE FIX:

🔧 PHASE 1: CLEAN UP DATABASE (Today - 30 minutes)
1. Run: node cleanup-question-categories.js
   → Creates proper Math EC-6 topics
   → Sets up structure for recategorization

2. Use Admin Dashboard at /admin/questions
   → Manually review and recategorize 62 questions
   → Move from "General Education" to proper topics
   → Takes ~15 minutes to review and assign

🔧 PHASE 2: IMPLEMENT DUAL-MODE SYSTEM (This Week)
1. Add mode selection before entering topics
   📚 STUDY MODE: Learn concepts (content_items)
   🎯 PRACTICE MODE: Take exam questions (questions table)

2. Separate the flows completely:
   Study: Explanation → Example → Quick check → Ready for practice?
   Practice: 25 random questions → Performance review → Study recommendations

🔧 PHASE 3: SCALE WITH QUESTION BANK (Next Week)  
1. Connect practice mode to questions table
2. Random question selection from topic pools
3. Adaptive difficulty based on performance
4. Build toward 450 Math EC-6 questions

IMMEDIATE BENEFITS:
✅ No more confusing mixed study/test sessions
✅ Proper exam simulation experience
✅ Scalable system that works with spreadsheet imports
✅ Clear separation of learning vs testing
✅ Proper question categorization and tracking

WANT TO START? 
1. Let's run the database cleanup script first
2. Then recategorize questions in admin dashboard
3. Then implement the dual-mode interface

This fixes all the core issues you identified! 🎯
`);
