# CertBloom Question Bank System

## Overview
We've built a comprehensive question bank system that supports adaptive learning, progress tracking, and rotating content. This system is designed to prevent users from memorizing answers while providing personalized learning experiences.

## Database Schema

### Core Tables

#### `certifications`
- Stores certification types (EC-6 Core Subjects, Math 4-8, etc.)
- Links to test codes and descriptions

#### `topics` 
- Breaks down each certification into learning topics
- Includes weight for importance and adaptive learning

#### `questions`
- Complete question data with metadata
- Difficulty levels: easy, medium, hard
- Cognitive levels: knowledge, comprehension, application, analysis, synthesis, evaluation
- Tags for flexible categorization
- Explanations and rationale for learning

#### `answer_choices`
- Multiple choice options with explanations
- Correct answer tracking
- Order for consistent display

#### `user_question_attempts`
- Tracks every user interaction with questions
- Records correctness, time spent, confidence level
- Enables progress tracking and adaptive learning

#### `user_progress`
- Aggregated performance data by topic
- Mastery levels (0.0 to 1.0)
- Identifies topics needing review
- Tracks learning streaks

#### `reflection_prompts`
- Weekly reflection questions that rotate
- Categorized by type: mindfulness, progress, motivation, growth, balance
- Time-based for different learning phases

## Key Features

### 1. **Question Rotation & Randomization**
- Questions are randomly shuffled each time
- Filters prevent recent question repetition
- Large question pools (500-1000+ per certification)
- Variety in difficulty and topics

### 2. **Adaptive Learning Engine**
- Analyzes user performance to adjust difficulty
- Focuses on weak areas (topics with <70% mastery)
- Varies question types based on learning patterns
- Avoids recently attempted questions

### 3. **Progress Tracking**
- Real-time mastery level calculation
- Topic-specific performance analytics
- Identifies areas needing review
- Tracks learning streaks and consistency

### 4. **Mindful Learning Integration**
- Confidence level tracking (1-5 scale)
- Time spent per question analysis
- Flagging questions for review
- Weekly reflection prompts

## API Functions

### Question Management
```typescript
// Get questions with filters
getQuestions(filters: QuestionFilters, limit: number)

// Get adaptive questions based on user performance  
getAdaptiveQuestions(userId: string, certification: string, limit: number)
```

### Progress Tracking
```typescript
// Record user's answer attempt
recordQuestionAttempt(userId, questionId, sessionId, selectedAnswerId, timeSpent, confidence)

// Get user's learning progress
getUserProgress(userId: string)
```

### Reflection System
```typescript
// Get weekly reflection prompt
getWeeklyReflectionPrompt(weekNumber?: number)

// Get prompts by category
getReflectionPromptsByCategory(category)
```

## Sample Question Data

We've included sample questions for EC-6 Core Subjects covering:
- **Reading Comprehension**: Phonemic awareness, fluency, comprehension strategies
- **Mathematics Concepts**: Place value, number sense, instructional strategies
- **Child Development**: Learning theories, developmental stages

Each question includes:
- Detailed explanations
- Multiple choice options with rationale
- Difficulty and cognitive level classification
- Relevant tags for categorization

## Implementation Files

### Database
- `database-schema.sql` - Complete database structure
- `seed-questions.sql` - Sample question data and reflection prompts

### TypeScript Functions
- `src/lib/questionBank.ts` - Core question and progress functions
- `src/lib/reflectionPrompts.ts` - Weekly reflection system

### Components
- `src/components/QuestionCard.tsx` - Reusable question display component

## Next Steps

### Immediate (Ready to Implement)
1. **Run Database Updates**: Execute the SQL files in Supabase
2. **Create More Questions**: Expand the question bank for each certification
3. **Integrate with Practice Sessions**: Connect to existing practice session flow

### Phase 2 (Enhanced Features)
1. **Advanced Analytics**: Detailed progress charts and insights
2. **Study Recommendations**: AI-driven study plan suggestions
3. **Spaced Repetition**: Algorithm to bring back questions at optimal intervals
4. **Question Variations**: Multiple versions of the same concept

### Phase 3 (Advanced AI)
1. **Dynamic Question Generation**: AI-generated questions based on learning gaps
2. **Personalized Explanations**: Adaptive explanations based on learning style
3. **Predictive Analytics**: Predict exam readiness and success probability

## Benefits

### For Users
- ✅ **No Question Memorization**: Large, rotating question pools
- ✅ **Personalized Learning**: Adaptive difficulty and topic focus
- ✅ **Progress Visibility**: Clear mastery tracking
- ✅ **Mindful Practice**: Confidence and reflection integration

### For CertBloom
- ✅ **Scalable Content**: Easy to add new certifications and questions
- ✅ **Data-Driven Insights**: Rich analytics on user learning patterns
- ✅ **Competitive Advantage**: Advanced adaptive learning system
- ✅ **User Engagement**: Personalized, effective learning experience

## Getting Started

1. **Update Database**: Run the SQL files in your Supabase project
2. **Test Questions**: Use the sample data to test the system
3. **Expand Content**: Add more questions for your target certifications
4. **Integrate**: Connect to your existing practice session pages

The system is designed to grow with your needs while maintaining the mindful, personalized learning experience that sets CertBloom apart! 🌸
