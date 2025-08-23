# Sacred Question Creation Guide 🌱
*Honoring the Journey of Conscious Content Development*

## 🌸 The Rhythm of Growth

We honor that building a question bank is a sacred journey, not a sprint. Each question planted with intention becomes a seed of wisdom that will bloom in countless classrooms across the Four Corners region and beyond.

## 📝 SQL Format - Perfect as It Is

Continue using the exact structure from `corrected-question-example.sql`:

```sql
-- ========== QUESTION [NUMBER]: [DESCRIPTIVE TITLE] ==========
WITH 
  ec6_cert AS (
    SELECT id FROM public.certifications WHERE name = 'EC-6 Core Subjects'
  ),
  [topic]_topic AS (
    SELECT t.id FROM public.topics t
    JOIN ec6_cert c ON t.certification_id = c.id
    WHERE t.name = '[Topic Name]'
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, topic_id, question_text, difficulty_level, explanation, cognitive_level, tags
    )
    SELECT 
      ec6_cert.id,
      [topic]_topic.id,
      '[Authentic classroom scenario question]',
      '[easy/medium/hard]',
      '[Pedagogical explanation with wisdom]',
      '[knowledge/comprehension/application/analysis/synthesis/evaluation]',
      ARRAY['tag1', 'tag2', 'tag3', 'specific_concept']
    FROM ec6_cert, [topic]_topic
    RETURNING id
)
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT inserted_question.id, choice_data.choice_text, choice_data.is_correct, choice_data.choice_order, choice_data.explanation
FROM inserted_question,
(VALUES 
  ('[Distractor 1]', false, 1, '[Teaching explanation]'),
  ('[Distractor 2]', false, 2, '[Teaching explanation]'),
  ('[Correct Answer]', true, 3, '[Affirming explanation with deeper insight]'),
  ('[Distractor 3]', false, 4, '[Teaching explanation]')
) AS choice_data(choice_text, is_correct, choice_order, explanation);
```

## 🌟 How This Feeds Our Adaptive Garden

### **Tags → Mandala Petals**
Each tag becomes a dimension in the learner's progress mandala:
- `'ELL_support'` → Shows growth in supporting English learners
- `'figurative_language'` → Tracks metaphorical comprehension  
- `'cultural_context'` → Monitors inclusive teaching awareness

### **Cognitive Levels → Growth Energy**
- `'knowledge'` → Dormant seeds (gray)
- `'comprehension'` → Budding understanding (soft yellow)  
- `'application'` → Blooming practice (fresh green)
- `'analysis/synthesis/evaluation'` → Radiant mastery (golden glow)

### **Rich Explanations → Wisdom Whispers**
Your thoughtful explanations become the voice of the Intuitive Guidance system, offering insights like:
- *"ELLs often struggle with idiomatic expressions..."* becomes wisdom about supporting all learners
- *"Correct! Idiom explanation bridges cultural meaning gaps"* becomes celebration of inclusive teaching

## 🌈 The Ripple Effect

Each question you craft with this intention:
1. **Serves the immediate learner** through authentic practice
2. **Feeds the adaptive system** with rich metadata for personalized growth
3. **Creates resonance** that extends into future classrooms
4. **Honors the sacred** nature of education and growth

## 💫 Sacred Deployment Rhythm

Remember: 
- **Quality over quantity** - Each question is a prayer for teacher success
- **Authentic scenarios** - Real classroom contexts honor the teaching journey  
- **Teaching through feedback** - Every explanation becomes a teaching moment
- **Gentle progression** - Honor natural learning cycles and readiness

Continue exactly as you have been. The SQL structure is perfect, the approach is sacred, and the impact will ripple through generations of learners.

---

*"In the garden of conscious learning, we plant seeds not for immediate harvest, but for the wisdom that will bloom in seasons yet to come."* 🌸
