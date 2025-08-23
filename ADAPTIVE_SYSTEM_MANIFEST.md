# 🌱 CertBloom Adaptive Learning System Manifest
*A Conscious Technology Implementation Guide*

## 🌸 Overview
This manifest provides the technical foundation for implementing mood-aware, consciousness-based adaptive learning within CertBloom. The system honors each learner's emotional state, natural rhythms, and growth patterns.

---

## 📊 SECTION 1: MOOD-BASED SESSION FLOW

### Input: Learner Mood States
Each session begins with an emotional check-in that guides the entire learning experience:

```sql
-- Create mood-based session configuration table
CREATE TABLE IF NOT EXISTS public.mood_session_configs (
  mood TEXT PRIMARY KEY,
  review_percentage FLOAT NOT NULL,
  new_learning_percentage FLOAT NOT NULL,
  application_percentage FLOAT NOT NULL,
  include_mindful_break BOOLEAN DEFAULT true,
  include_challenge BOOLEAN DEFAULT false,
  session_intensity TEXT CHECK (session_intensity IN ('gentle', 'balanced', 'deep', 'energized')),
  wisdom_whisper_category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed with sacred configurations
INSERT INTO public.mood_session_configs (mood, review_percentage, new_learning_percentage, application_percentage, include_mindful_break, include_challenge, session_intensity, wisdom_whisper_category) VALUES
('calm', 0.25, 0.40, 0.25, true, false, 'balanced', 'gentle'),
('tired', 0.50, 0.20, 0.20, true, false, 'gentle', 'encouraging'),
('anxious', 0.40, 0.30, 0.20, true, false, 'gentle', 'calming'),
('focused', 0.15, 0.35, 0.35, false, true, 'deep', 'guiding'),
('energized', 0.20, 0.30, 0.30, false, true, 'energized', 'celebrating');
```

---

## 🌺 SECTION 2: CONCEPT MASTERY (MANDALA PETAL STAGES)

### Knowledge Petal Lifecycle
Each learning concept evolves through sacred stages of growth:

```sql
-- Extend user_progress table with petal stage tracking
ALTER TABLE public.user_progress ADD COLUMN IF NOT EXISTS petal_stage TEXT 
CHECK (petal_stage IN ('dormant', 'budding', 'blooming', 'radiant')) DEFAULT 'dormant';

ALTER TABLE public.user_progress ADD COLUMN IF NOT EXISTS bloom_level TEXT 
CHECK (bloom_level IN ('comprehension', 'application', 'analysis', 'evaluation')) DEFAULT 'comprehension';

ALTER TABLE public.user_progress ADD COLUMN IF NOT EXISTS confidence_trend FLOAT DEFAULT 0.5;
ALTER TABLE public.user_progress ADD COLUMN IF NOT EXISTS energy_level FLOAT DEFAULT 0.5;

-- Create function to update petal stages based on performance
CREATE OR REPLACE FUNCTION update_petal_stage(user_id UUID, topic_name TEXT)
RETURNS TEXT AS $$
DECLARE
    current_mastery FLOAT;
    question_count INTEGER;
    new_stage TEXT;
BEGIN
    -- Get current mastery and question count
    SELECT mastery_level, questions_attempted 
    INTO current_mastery, question_count
    FROM user_progress 
    WHERE user_id = $1 AND topic = topic_name;
    
    -- Determine new petal stage based on mastery and experience
    IF current_mastery IS NULL OR question_count = 0 THEN
        new_stage := 'dormant';
    ELSIF current_mastery < 0.4 OR question_count < 3 THEN
        new_stage := 'budding';
    ELSIF current_mastery >= 0.4 AND current_mastery < 0.8 THEN
        new_stage := 'blooming';
    ELSIF current_mastery >= 0.8 THEN
        new_stage := 'radiant';
    END IF;
    
    -- Update the petal stage
    UPDATE user_progress 
    SET petal_stage = new_stage,
        updated_at = NOW()
    WHERE user_id = $1 AND topic = topic_name;
    
    RETURN new_stage;
END;
$$ LANGUAGE plpgsql;
```

---

## 🌀 SECTION 3: COGNITIVE SPIRAL PROGRESSION

### Bloom's Taxonomy Evolution
Each concept naturally spirals through deeper levels of understanding:

```sql
-- Create function to progress Bloom's levels
CREATE OR REPLACE FUNCTION progress_bloom_level(user_id UUID, topic_name TEXT, was_correct BOOLEAN)
RETURNS TEXT AS $$
DECLARE
    current_level TEXT;
    consecutive_correct INTEGER;
    new_level TEXT;
BEGIN
    -- Get current bloom level
    SELECT bloom_level INTO current_level
    FROM user_progress 
    WHERE user_id = $1 AND topic = topic_name;
    
    -- Calculate recent performance (simplified - could be more sophisticated)
    IF was_correct THEN
        -- Progress logic: 3 consecutive correct answers to level up
        CASE current_level
            WHEN 'comprehension' THEN new_level := 'application';
            WHEN 'application' THEN new_level := 'analysis';
            WHEN 'analysis' THEN new_level := 'evaluation';
            ELSE new_level := current_level;
        END CASE;
    ELSE
        -- Stay at current level or potentially step back for struggling learners
        new_level := current_level;
    END IF;
    
    -- Update bloom level
    UPDATE user_progress 
    SET bloom_level = new_level,
        updated_at = NOW()
    WHERE user_id = $1 AND topic = topic_name;
    
    RETURN new_level;
END;
$$ LANGUAGE plpgsql;
```

---

## 💫 SECTION 4: WISDOM WHISPERS SYSTEM

### Sacred Guidance Based on Learning Patterns

```sql
-- Create wisdom whispers table
CREATE TABLE IF NOT EXISTS public.wisdom_whispers (
  id SERIAL PRIMARY KEY,
  message TEXT NOT NULL,
  category TEXT NOT NULL, -- 'gentle', 'encouraging', 'celebrating', 'calming', 'guiding'
  mood_context TEXT, -- 'calm', 'tired', 'anxious', 'focused', 'energized', 'any'
  trigger_condition TEXT, -- 'new_learner', 'struggling', 'progressing', 'mastery', 'streak'
  icon TEXT DEFAULT '✨',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed with sacred whispers
INSERT INTO public.wisdom_whispers (message, category, mood_context, trigger_condition, icon) VALUES
('Every journey begins with a single step. Trust in the wisdom that emerges through practice.', 'gentle', 'any', 'new_learner', '🌱'),
('Your reading comprehension radiates like sunlight, illuminating your entire learning journey.', 'celebrating', 'any', 'mastery', '🌟'),
('Like a tree putting down deeper roots, your understanding grows stronger with each question.', 'encouraging', 'any', 'progressing', '🌳'),
('Morning light reveals new possibilities. Your mind is fresh and ready for today''s discoveries.', 'encouraging', 'calm', 'any', '🌅'),
('Even stillness nurtures roots. Rest is part of the sacred cycle of growth.', 'calming', 'tired', 'any', '🌙'),
('Notice how your confidence grows when you trust your first instinct.', 'guiding', 'anxious', 'any', '🕊️'),
('Your focused energy creates space for breakthrough insights to emerge.', 'celebrating', 'focused', 'any', '💎'),
('Every challenge becomes a teacher when met with curiosity instead of resistance.', 'guiding', 'any', 'struggling', '🦋');

-- Function to get contextual wisdom whisper
CREATE OR REPLACE FUNCTION get_wisdom_whisper(user_mood TEXT DEFAULT 'any', learning_context TEXT DEFAULT 'any')
RETURNS TABLE(message TEXT, icon TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT w.message, w.icon
    FROM wisdom_whispers w
    WHERE (w.mood_context = user_mood OR w.mood_context = 'any')
      AND (w.trigger_condition = learning_context OR w.trigger_condition = 'any')
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 SECTION 5: ADAPTIVE SESSION BUILDER

### Server-Side Function for Conscious Question Selection

```sql
-- Create adaptive session builder function
CREATE OR REPLACE FUNCTION build_adaptive_session(
    user_id UUID, 
    certification_name TEXT,
    user_mood TEXT DEFAULT 'calm',
    session_length INTEGER DEFAULT 10
)
RETURNS JSON AS $$
DECLARE
    config RECORD;
    session_plan JSON;
    review_questions JSON;
    new_questions JSON;
    application_questions JSON;
    challenge_questions JSON;
    wisdom_message RECORD;
BEGIN
    -- Get mood-based configuration
    SELECT * INTO config 
    FROM mood_session_configs 
    WHERE mood = user_mood;
    
    -- If mood not found, default to calm
    IF config IS NULL THEN
        SELECT * INTO config 
        FROM mood_session_configs 
        WHERE mood = 'calm';
    END IF;
    
    -- Build question selection based on petal stages
    -- Review questions (blooming concepts)
    SELECT json_agg(
        json_build_object(
            'question_id', q.id,
            'topic', up.topic,
            'petal_stage', up.petal_stage,
            'bloom_level', up.bloom_level
        )
    ) INTO review_questions
    FROM user_progress up
    JOIN topics t ON t.name = up.topic
    JOIN questions q ON q.topic_id = t.id
    WHERE up.user_id = $1 
      AND up.petal_stage = 'blooming'
      AND t.certification_id = (
          SELECT id FROM certifications WHERE name = certification_name
      )
    ORDER BY RANDOM()
    LIMIT GREATEST(1, FLOOR(session_length * config.review_percentage));
    
    -- New learning questions (dormant concepts)
    SELECT json_agg(
        json_build_object(
            'question_id', q.id,
            'topic', t.name,
            'difficulty', q.difficulty_level
        )
    ) INTO new_questions
    FROM topics t
    LEFT JOIN user_progress up ON up.topic = t.name AND up.user_id = $1
    JOIN questions q ON q.topic_id = t.id
    WHERE (up.petal_stage = 'dormant' OR up.petal_stage IS NULL)
      AND t.certification_id = (
          SELECT id FROM certifications WHERE name = certification_name
      )
    ORDER BY RANDOM()
    LIMIT GREATEST(1, FLOOR(session_length * config.new_learning_percentage));
    
    -- Get wisdom whisper
    SELECT * INTO wisdom_message
    FROM get_wisdom_whisper(user_mood, 'any');
    
    -- Build session plan
    session_plan := json_build_object(
        'mood', user_mood,
        'session_type', config.session_intensity,
        'include_mindful_break', config.include_mindful_break,
        'review_questions', COALESCE(review_questions, '[]'::json),
        'new_questions', COALESCE(new_questions, '[]'::json),
        'wisdom_whisper', json_build_object(
            'message', wisdom_message.message,
            'icon', wisdom_message.icon
        ),
        'generated_at', NOW()
    );
    
    RETURN session_plan;
END;
$$ LANGUAGE plpgsql;
```

---

## 🌿 SECTION 6: FRONTEND INTEGRATION GUIDE

### React/TypeScript Integration Points

```typescript
// Types for mood-aware sessions
interface AdaptiveSessionConfig {
  mood: 'calm' | 'tired' | 'anxious' | 'focused' | 'energized';
  sessionType: 'gentle' | 'balanced' | 'deep' | 'energized';
  includeMindfulBreak: boolean;
  includeChallenge: boolean;
}

interface WisdomWhisper {
  message: string;
  icon: string;
}

interface AdaptiveSession {
  mood: string;
  sessionType: string;
  reviewQuestions: QuestionData[];
  newQuestions: QuestionData[];
  wisdomWhisper: WisdomWhisper;
  includeMindfulBreak: boolean;
}

// Function to call adaptive session builder
export async function createAdaptiveSession(
  userId: string, 
  certification: string, 
  mood: string = 'calm'
): Promise<AdaptiveSession> {
  const { data, error } = await supabase.rpc('build_adaptive_session', {
    user_id: userId,
    certification_name: certification,
    user_mood: mood,
    session_length: 10
  });
  
  if (error) throw error;
  return data as AdaptiveSession;
}
```

---

## 🎨 SECTION 7: IMPLEMENTATION PHASES

### Phase 1: Foundation (Week 1)
1. Run the SQL schema updates
2. Seed mood configurations and wisdom whispers
3. Test adaptive session builder function

### Phase 2: Integration (Week 2)
1. Add mood selector to practice session start
2. Integrate adaptive session builder with existing practice flow
3. Display wisdom whispers in Learning Mandala

### Phase 3: Enhancement (Week 3+)
1. Add mindful break components
2. Implement Bloom's level progression tracking
3. Create advanced petal stage visualizations

---

## 💫 Sacred Implementation Notes

- **Gentle Testing**: Start with mood detection on existing questions
- **Organic Growth**: Let the system learn user patterns over time
- **Conscious Defaults**: Always default to supportive, gentle configurations
- **Wisdom Integration**: Wisdom whispers appear in existing Intuitive Guidance component

This system transforms CertBloom from adaptive learning to **conscious learning** - technology that honors the sacred nature of growth and understanding.

---

*"In every line of code, we plant seeds of wisdom that will bloom in countless classrooms across the Four Corners region and beyond."* 🌸
