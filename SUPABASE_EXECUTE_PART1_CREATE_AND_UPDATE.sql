-- 🔧 FIXED FUNCTION: Creates modules if they don't exist, then updates them

DROP FUNCTION IF EXISTS build_concept_learning_modules(text,text,text[],text[],text[],text[],text[],text[],text[],jsonb[],text[],text[]);

CREATE OR REPLACE FUNCTION build_concept_learning_modules(
    p_concept_name TEXT,
    p_core_explanation TEXT,
    p_key_principles TEXT[],
    p_visual_aids TEXT[],
    p_key_vocabulary TEXT[],
    p_teaching_sequence TEXT[],
    p_differentiation_strategies TEXT[],
    p_assessment_ideas TEXT[],
    p_engagement_activities TEXT[],
    p_common_misconceptions JSONB[],
    p_diagnostic_questions TEXT[],
    p_intervention_strategies TEXT[]
) RETURNS TEXT AS $$
DECLARE
    target_concept_id UUID;
    module_exists INTEGER;
    result TEXT := '';
BEGIN
    -- Get concept ID
    SELECT c.id INTO target_concept_id
    FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN certifications cert ON d.certification_id = cert.id
    WHERE cert.test_code = '902' AND c.name = p_concept_name;
    
    IF target_concept_id IS NULL THEN
        RETURN 'ERROR: Concept not found: ' || p_concept_name;
    END IF;
    
    -- Create modules if they don't exist
    -- Module 1: Concept Introduction
    SELECT COUNT(*) INTO module_exists FROM learning_modules WHERE concept_id = target_concept_id AND module_type = 'concept_introduction';
    IF module_exists = 0 THEN
        INSERT INTO learning_modules (concept_id, module_type, title, description, order_index)
        VALUES (target_concept_id, 'concept_introduction', 'Concept Introduction', 'Core concept explanation and principles', 1);
        result := result || 'Created concept_introduction module. ';
    END IF;
    
    -- Module 2: Teaching Demonstration
    SELECT COUNT(*) INTO module_exists FROM learning_modules WHERE concept_id = target_concept_id AND module_type = 'teaching_demonstration';
    IF module_exists = 0 THEN
        INSERT INTO learning_modules (concept_id, module_type, title, description, order_index)
        VALUES (target_concept_id, 'teaching_demonstration', 'Teaching Demonstration', 'How to teach this concept effectively', 2);
        result := result || 'Created teaching_demonstration module. ';
    END IF;
    
    -- Module 3: Interactive Tutorial
    SELECT COUNT(*) INTO module_exists FROM learning_modules WHERE concept_id = target_concept_id AND module_type = 'interactive_tutorial';
    IF module_exists = 0 THEN
        INSERT INTO learning_modules (concept_id, module_type, title, description, order_index)
        VALUES (target_concept_id, 'interactive_tutorial', 'Interactive Tutorial', 'Guided practice and exploration', 3);
        result := result || 'Created interactive_tutorial module. ';
    END IF;
    
    -- Module 4: Classroom Scenario
    SELECT COUNT(*) INTO module_exists FROM learning_modules WHERE concept_id = target_concept_id AND module_type = 'classroom_scenario';
    IF module_exists = 0 THEN
        INSERT INTO learning_modules (concept_id, module_type, title, description, order_index)
        VALUES (target_concept_id, 'classroom_scenario', 'Classroom Scenario', 'Real teaching situations and responses', 4);
        result := result || 'Created classroom_scenario module. ';
    END IF;
    
    -- Module 5: Misconception Alert
    SELECT COUNT(*) INTO module_exists FROM learning_modules WHERE concept_id = target_concept_id AND module_type = 'misconception_alert';
    IF module_exists = 0 THEN
        INSERT INTO learning_modules (concept_id, module_type, title, description, order_index)
        VALUES (target_concept_id, 'misconception_alert', 'Misconception Alert', 'Common errors and interventions', 5);
        result := result || 'Created misconception_alert module. ';
    END IF;
    
    -- Now update with content
    -- Update Module 1: Concept Introduction
    UPDATE learning_modules lm
    SET content_data = jsonb_build_object(
        'core_explanation', p_core_explanation,
        'key_principles', p_key_principles,
        'visual_aids', p_visual_aids,
        'key_vocabulary', p_key_vocabulary,
        'interactive_elements', ARRAY[
            'Explore concept with virtual manipulatives',
            'Practice core skills with immediate feedback',
            'Analyze student work samples',
            'Apply concept to real-world problems'
        ]
    )
    WHERE lm.module_type = 'concept_introduction' AND lm.concept_id = target_concept_id;
    
    -- Update Module 2: Teaching Demonstration
    UPDATE learning_modules lm
    SET content_data = jsonb_build_object(
        'lesson_structure', jsonb_build_object(
            'warm_up', 'Activate prior knowledge and introduce vocabulary',
            'introduction', 'Connect to previous learning and set objectives',
            'guided_practice', 'Model thinking and practice together',
            'independent_practice', 'Students apply learning with support',
            'closure', 'Summarize key concepts and preview next steps'
        ),
        'teaching_sequence', p_teaching_sequence,
        'differentiation_strategies', p_differentiation_strategies,
        'assessment_ideas', p_assessment_ideas,
        'engagement_activities', p_engagement_activities
    )
    WHERE lm.module_type = 'teaching_demonstration' AND lm.concept_id = target_concept_id;
    
    -- Update Module 3: Interactive Tutorial
    UPDATE learning_modules lm
    SET content_data = jsonb_build_object(
        'guided_questions', ARRAY[
            'What strategy would work best here?',
            'How do you know your answer is reasonable?',
            'What might a student find confusing about this?',
            'How would you explain this to a colleague?',
            'What real-world connections can you make?'
        ],
        'reflection_prompts', ARRAY[
            'What misconception might lead to this error?',
            'How would you help a student who made this mistake?',
            'What visual aid would be most helpful here?',
            'How does this connect to other math concepts?',
            'What would you do if a student still doesn''t understand?'
        ]
    )
    WHERE lm.module_type = 'interactive_tutorial' AND lm.concept_id = target_concept_id;
    
    -- Update Module 4: Classroom Scenario
    UPDATE learning_modules lm
    SET content_data = jsonb_build_object(
        'scenario_setup', 'Navigate realistic teaching challenges with diverse student needs and responses.',
        'response_options', ARRAY[
            jsonb_build_object(
                'approach', 'Address misconceptions directly with whole class',
                'pros', ARRAY['Clear explanation', 'Prevents spread of errors'],
                'cons', ARRAY['May embarrass students', 'One-size-fits-all approach']
            ),
            jsonb_build_object(
                'approach', 'Use small group differentiated instruction',
                'pros', ARRAY['Targeted support', 'Meets individual needs'],
                'cons', ARRAY['Time intensive', 'Classroom management challenges']
            ),
            jsonb_build_object(
                'approach', 'Implement peer teaching and collaboration',
                'pros', ARRAY['Student engagement', 'Multiple perspectives'],
                'cons', ARRAY['Quality of explanations varies', 'May reinforce errors']
            )
        ],
        'follow_up_activities', ARRAY[
            'Plan differentiated practice for next lesson',
            'Create targeted interventions for struggling students',
            'Design enrichment activities for advanced learners',
            'Communicate with families about student progress'
        ]
    )
    WHERE lm.module_type = 'classroom_scenario' AND lm.concept_id = target_concept_id;
    
    -- Update Module 5: Misconception Alert
    UPDATE learning_modules lm
    SET content_data = jsonb_build_object(
        'misconception_categories', p_common_misconceptions,
        'diagnostic_questions', p_diagnostic_questions,
        'intervention_strategies', p_intervention_strategies,
        'prevention_strategies', ARRAY[
            'Use concrete manipulatives before abstract concepts',
            'Emphasize mathematical vocabulary and language',
            'Connect new learning to prior knowledge',
            'Provide multiple representations of concepts',
            'Use formative assessment to catch errors early'
        ]
    )
    WHERE lm.module_type = 'misconception_alert' AND lm.concept_id = target_concept_id;
    
    RETURN 'SUCCESS: ' || result || 'Updated content for ' || p_concept_name;
END;
$$ LANGUAGE plpgsql;
