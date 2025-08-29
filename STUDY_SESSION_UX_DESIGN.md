# STUDY SESSION UX DESIGN SPECIFICATION
## Reference Panel Approach for Optimal Learning

### Overview
This document outlines the user experience design for study sessions that balances realistic test simulation with effective learning support.

---

## SESSION STRUCTURE

### **Session Size: 12 Questions**
- **Duration**: 15-20 minutes optimal
- **Topic Mix**: 3-4 different topics per session
- **Difficulty**: Adaptive based on user performance
- **Realistic Simulation**: Mixed topics (not sequential by concept)

---

## QUESTION SELECTION ALGORITHM

### **Intelligent Weighted Selection**
1. **Performance-Based Prioritization**
   - Topics with <60% accuracy get higher weight
   - Never-practiced topics prioritized
   - Recent struggles surface more frequently

2. **Spaced Repetition**
   - Questions missed reappear after optimal intervals
   - Recent questions (last 3 days) have lower selection weight
   - Progressive difficulty adjustment based on confidence

3. **Topic Balancing**
   - Ensures 3-4 topics per session
   - Weighted distribution: Number Concepts (40%), Algebra (30%), Geometry (20%), Data (10%)
   - Maximum 4 questions per topic to maintain variety

---

## REFERENCE PANEL UI DESIGN

### **Just-in-Time Learning Support**

```
┌─────────────────────────────────────────────────────────────┐
│ Question 3 of 12                                   [📚 Help] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Ms. Rodriguez is working with her 2nd grade students on     │
│ two-digit place value. When she asks students to show 34   │
│ using base-ten blocks, most students correctly use 3 tens  │
│ and 4 ones. However, when she then asks them to write...   │
│                                                             │
│ ○ A) The student has mastered place value concepts         │
│ ○ B) The student needs more practice with number sequence  │
│ ○ C) The student understands counting but not place value  │
│ ○ D) The student has difficulty with subtraction           │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ 📚 Place Value Mastery - Quick Reference          [×] Close │
│                                                             │
│ Key Concepts:                                               │
│ • Place value = position determines value                   │
│ • Each position is 10× the position to its right          │
│ • Students often confuse counting vs. place value          │
│                                                             │
│ Common Misconceptions:                                      │
│ • "34 minus 1 equals 33" (counting) vs understanding       │
│   that 34 represents 3 tens + 4 ones                      │
│                                                             │
│ Teaching Strategies:                                        │
│ • Use manipulatives (base-ten blocks, place value charts)  │
│ • Emphasize the relationship between positions             │
│ • Practice decomposing numbers in multiple ways            │
│                                                             │
│ [📖 Read Full Study Guide] [🎯 More Practice Questions]    │
└─────────────────────────────────────────────────────────────┘
```

### **Panel Behavior**
- **Trigger**: Click "📚 Help" button (always visible)
- **Auto-Updates**: Content changes based on current question's concept
- **Non-Intrusive**: Collapsible, user-controlled
- **Context-Aware**: Shows relevant concept explanation + teaching strategies

---

## SESSION FLOW

### **Pre-Session Setup (2 minutes)**
1. **Mood Check**: "How are you feeling today?" (affects question selection)
2. **Quick Goal**: "What do you want to focus on?" (optional topic preference)
3. **Session Preview**: "12 questions, mixed topics, ~15 minutes"

### **During Session**
1. **Question Display**
   - Clean, uncluttered interface
   - Progress indicator (Question X of 12)
   - Timer (optional, can be hidden)

2. **Reference Panel**
   - Collapsed by default
   - Click "📚 Help" to expand
   - Shows concept explanation for current question
   - Includes teaching strategies and common misconceptions

3. **Answer Submission**
   - Immediate feedback after each question
   - Brief explanation of correct answer
   - Option to flag for review

### **Post-Session Review (3 minutes)**
1. **Performance Summary**
   - Score breakdown by topic
   - Confidence level check
   - Identified learning priorities

2. **Adaptive Recommendations**
   - "Focus on fractions next session"
   - "You're ready for harder geometry questions"
   - Study material suggestions

---

## TECHNICAL IMPLEMENTATION

### **Frontend Components**
- `QuestionDisplay.tsx` - Main question interface
- `ReferencePanel.tsx` - Collapsible study content
- `SessionProgress.tsx` - Progress tracking
- `AdaptiveFeedback.tsx` - Post-question feedback

### **API Integration**
- `GET /api/sessions/questions` - Uses intelligent selection algorithm
- `GET /api/concepts/{id}/content` - Fetches reference material
- `POST /api/sessions/attempt` - Records user answers for adaptive learning

### **Database Schema Updates**
- Enhanced `practice_sessions` with algorithm metadata
- `session_configs` for customizable parameters
- Question-concept linkage for contextual help

---

## SUCCESS METRICS

### **User Experience**
- **Session Completion Rate**: >85%
- **Reference Panel Usage**: 20-30% of questions
- **User Satisfaction**: "Feels like real test but with support when needed"

### **Learning Effectiveness**
- **Topic Coverage Balance**: All 4 topics represented per session
- **Difficulty Adaptation**: Questions adjust based on 70% confidence threshold
- **Retention**: Spaced repetition improves long-term memory

---

## IMPLEMENTATION PHASES

### **Phase 1: Core Algorithm** (Current)
- [x] Question-concept integration
- [x] Session selection algorithm
- [ ] Test with math certification

### **Phase 2: Reference Panel UI**
- [ ] Design and implement collapsible panel
- [ ] Connect to concept content
- [ ] User testing and refinement

### **Phase 3: Adaptive Enhancement**
- [ ] Real-time difficulty adjustment
- [ ] Personalized topic weighting
- [ ] Advanced spaced repetition

---

## NEXT STEPS

1. **Run Integration Scripts**: Execute the SQL files to link questions to concepts
2. **Test Question Selection**: Verify algorithm returns balanced topic mix
3. **Build Reference Panel**: Implement the collapsible help interface
4. **User Testing**: Validate the "realistic but supportive" experience

The goal is a study experience that feels like the real exam while providing intelligent, just-in-time learning support when users need it most.
