-- 🏗️ CERTIFICATION TEMPLATE GENERATOR
-- Scalable system for creating all TExES certifications

-- ============================================
-- MASTER CERTIFICATION BUILDER FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION create_certification_structure(
  p_test_code TEXT,
  p_name TEXT,
  p_description TEXT,
  p_domains JSONB -- Array of domain objects
) RETURNS UUID AS $$
DECLARE
  cert_id UUID;
  domain_obj JSONB;
  domain_id UUID;
  concept_obj JSONB;
  concept_id UUID;
BEGIN
  -- Create certification
  INSERT INTO certifications (id, name, test_code, description, total_concepts)
  VALUES (
    gen_random_uuid(),
    p_name,
    p_test_code,
    p_description,
    (SELECT COUNT(*) FROM jsonb_array_elements(p_domains) as d, 
     jsonb_array_elements(d->'concepts') as c)
  )
  ON CONFLICT (test_code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    total_concepts = EXCLUDED.total_concepts
  RETURNING id INTO cert_id;
  
  -- Create domains and concepts
  FOR domain_obj IN SELECT jsonb_array_elements(p_domains)
  LOOP
    INSERT INTO domains (id, certification_id, name, code, description, weight_percentage, order_index)
    VALUES (
      gen_random_uuid(),
      cert_id,
      domain_obj->>'name',
      domain_obj->>'code',
      domain_obj->>'description',
      (domain_obj->>'weight_percentage')::INTEGER,
      (domain_obj->>'order_index')::INTEGER
    )
    ON CONFLICT (certification_id, code) DO UPDATE SET
      name = EXCLUDED.name,
      description = EXCLUDED.description,
      weight_percentage = EXCLUDED.weight_percentage
    RETURNING id INTO domain_id;
    
    -- Create concepts for this domain
    FOR concept_obj IN SELECT jsonb_array_elements(domain_obj->'concepts')
    LOOP
      INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
      VALUES (
        gen_random_uuid(),
        domain_id,
        concept_obj->>'name',
        concept_obj->>'description',
        (concept_obj->>'difficulty_level')::INTEGER,
        (concept_obj->>'estimated_study_minutes')::INTEGER,
        (concept_obj->>'order_index')::INTEGER,
        concept_obj->'learning_objectives',
        concept_obj->'prerequisites'
      )
      ON CONFLICT (domain_id, name) DO UPDATE SET
        description = EXCLUDED.description,
        difficulty_level = EXCLUDED.difficulty_level,
        estimated_study_minutes = EXCLUDED.estimated_study_minutes
      RETURNING id INTO concept_id;
      
      -- Create content template for this concept
      PERFORM create_concept_content(concept_id, concept_obj->>'name');
    END LOOP;
  END LOOP;
  
  RETURN cert_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ALL TEXES CERTIFICATIONS DATA
-- ============================================

-- EC-6 Core Subjects (391) - Comprehensive exam
SELECT create_certification_structure(
  '391',
  'TExES Core Subjects EC-6 (391)',
  'Comprehensive certification covering all core subjects for Early Childhood through Grade 6',
  '[
    {
      "name": "English Language Arts & Reading",
      "code": "I", 
      "description": "Reading comprehension, language development, writing, and literary analysis",
      "weight_percentage": 25,
      "order_index": 1,
      "concepts": [
        {"name": "Reading Comprehension Strategies", "description": "Teaching students to understand and analyze text", "difficulty_level": 3, "estimated_study_minutes": 60, "order_index": 1, "learning_objectives": ["Teach comprehension strategies", "Assess student understanding"], "prerequisites": []},
        {"name": "Phonics & Word Recognition", "description": "Systematic phonics instruction and word study", "difficulty_level": 2, "estimated_study_minutes": 45, "order_index": 2, "learning_objectives": ["Implement phonics instruction", "Support struggling readers"], "prerequisites": []},
        {"name": "Writing Process & Conventions", "description": "Teaching writing through process approach", "difficulty_level": 3, "estimated_study_minutes": 55, "order_index": 3, "learning_objectives": ["Guide writing process", "Teach grammar and conventions"], "prerequisites": []},
        {"name": "Literature & Literary Analysis", "description": "Teaching literary elements and analysis skills", "difficulty_level": 4, "estimated_study_minutes": 50, "order_index": 4, "learning_objectives": ["Teach literary elements", "Develop critical thinking"], "prerequisites": ["Reading Comprehension Strategies"]}
      ]
    },
    {
      "name": "Mathematics",
      "code": "II",
      "description": "Elementary mathematics concepts and pedagogy", 
      "weight_percentage": 25,
      "order_index": 2,
      "concepts": [
        {"name": "Number Concepts & Operations", "description": "Fundamental number concepts and computational fluency", "difficulty_level": 2, "estimated_study_minutes": 50, "order_index": 1, "learning_objectives": ["Teach number concepts", "Develop computational fluency"], "prerequisites": []},
        {"name": "Algebraic Reasoning", "description": "Early algebra and pattern recognition", "difficulty_level": 3, "estimated_study_minutes": 45, "order_index": 2, "learning_objectives": ["Introduce algebraic thinking", "Teach patterns and functions"], "prerequisites": ["Number Concepts & Operations"]},
        {"name": "Geometry & Spatial Reasoning", "description": "Geometric concepts and spatial relationships", "difficulty_level": 3, "estimated_study_minutes": 40, "order_index": 3, "learning_objectives": ["Teach geometric concepts", "Develop spatial reasoning"], "prerequisites": []},
        {"name": "Data Analysis & Probability", "description": "Statistics, data interpretation, and probability", "difficulty_level": 3, "estimated_study_minutes": 35, "order_index": 4, "learning_objectives": ["Teach data analysis", "Introduce probability concepts"], "prerequisites": ["Number Concepts & Operations"]}
      ]
    },
    {
      "name": "Social Studies", 
      "code": "III",
      "description": "History, geography, civics, and social studies pedagogy",
      "weight_percentage": 25,
      "order_index": 3,
      "concepts": [
        {"name": "Texas & U.S. History", "description": "Key historical events and their significance", "difficulty_level": 2, "estimated_study_minutes": 55, "order_index": 1, "learning_objectives": ["Teach historical thinking", "Connect past to present"], "prerequisites": []},
        {"name": "Geography & Map Skills", "description": "Geographic concepts and spatial understanding", "difficulty_level": 2, "estimated_study_minutes": 40, "order_index": 2, "learning_objectives": ["Develop geographic literacy", "Teach map skills"], "prerequisites": []},
        {"name": "Civics & Government", "description": "Democratic principles and civic engagement", "difficulty_level": 3, "estimated_study_minutes": 45, "order_index": 3, "learning_objectives": ["Teach civic responsibility", "Explain government functions"], "prerequisites": []},
        {"name": "Economics & Culture", "description": "Economic concepts and cultural understanding", "difficulty_level": 3, "estimated_study_minutes": 35, "order_index": 4, "learning_objectives": ["Introduce economic thinking", "Celebrate cultural diversity"], "prerequisites": []}
      ]
    },
    {
      "name": "Science",
      "code": "IV", 
      "description": "Physical, life, and earth sciences for elementary students",
      "weight_percentage": 25,
      "order_index": 4,
      "concepts": [
        {"name": "Scientific Inquiry & Process", "description": "Scientific method and investigation skills", "difficulty_level": 3, "estimated_study_minutes": 45, "order_index": 1, "learning_objectives": ["Teach scientific method", "Develop inquiry skills"], "prerequisites": []},
        {"name": "Life Science & Biology", "description": "Living organisms and biological processes", "difficulty_level": 2, "estimated_study_minutes": 50, "order_index": 2, "learning_objectives": ["Understand life processes", "Teach ecosystem concepts"], "prerequisites": []},
        {"name": "Physical Science & Chemistry", "description": "Matter, energy, and physical processes", "difficulty_level": 3, "estimated_study_minutes": 55, "order_index": 3, "learning_objectives": ["Explain matter and energy", "Demonstrate physical properties"], "prerequisites": []},
        {"name": "Earth & Space Science", "description": "Earth processes and astronomical concepts", "difficulty_level": 3, "estimated_study_minutes": 40, "order_index": 4, "learning_objectives": ["Teach earth processes", "Introduce space concepts"], "prerequisites": []}
      ]
    }
  ]'::jsonb
);

-- Mathematics EC-6 (901) - Elementary Math Focus
SELECT create_certification_structure(
  '901',
  'TExES Mathematics EC-6 (901)', 
  'Specialized elementary mathematics certification',
  '[
    {
      "name": "Number Concepts & Number Theory",
      "code": "I",
      "description": "Deep understanding of number systems and theory",
      "weight_percentage": 30,
      "order_index": 1,
      "concepts": [
        {"name": "Whole Numbers & Integers", "description": "Properties and operations with whole numbers and integers", "difficulty_level": 2, "estimated_study_minutes": 45, "order_index": 1, "learning_objectives": ["Master whole number operations", "Understand integer concepts"], "prerequisites": []},
        {"name": "Rational Numbers", "description": "Fractions, decimals, and their relationships", "difficulty_level": 3, "estimated_study_minutes": 60, "order_index": 2, "learning_objectives": ["Work with rational numbers", "Convert between forms"], "prerequisites": ["Whole Numbers & Integers"]},
        {"name": "Number Theory", "description": "Prime numbers, factors, multiples, and divisibility", "difficulty_level": 3, "estimated_study_minutes": 50, "order_index": 3, "learning_objectives": ["Apply number theory concepts", "Understand prime factorization"], "prerequisites": ["Whole Numbers & Integers"]}
      ]
    },
    {
      "name": "Patterns, Relationships & Algebraic Reasoning", 
      "code": "II",
      "description": "Algebraic thinking and pattern recognition",
      "weight_percentage": 25,
      "order_index": 2,
      "concepts": [
        {"name": "Patterns & Sequences", "description": "Identifying and extending mathematical patterns", "difficulty_level": 2, "estimated_study_minutes": 40, "order_index": 1, "learning_objectives": ["Identify patterns", "Create pattern rules"], "prerequisites": []},
        {"name": "Algebraic Expressions", "description": "Variables, expressions, and early algebra", "difficulty_level": 3, "estimated_study_minutes": 50, "order_index": 2, "learning_objectives": ["Work with variables", "Simplify expressions"], "prerequisites": ["Patterns & Sequences"]},
        {"name": "Functions & Relationships", "description": "Function concepts and mathematical relationships", "difficulty_level": 4, "estimated_study_minutes": 55, "order_index": 3, "learning_objectives": ["Understand functions", "Represent relationships"], "prerequisites": ["Algebraic Expressions"]}
      ]
    }
  ]'::jsonb
);

-- Science EC-6 (902) - Already created above, but clean version
SELECT create_certification_structure(
  '902',
  'TExES Science EC-6 (902)',
  'Elementary science concepts and scientific inquiry',
  '[
    {
      "name": "Scientific Inquiry & Process",
      "code": "I", 
      "description": "Scientific method, investigation, and process skills",
      "weight_percentage": 25,
      "order_index": 1,
      "concepts": [
        {"name": "Scientific Method", "description": "Steps of scientific inquiry and investigation", "difficulty_level": 2, "estimated_study_minutes": 40, "order_index": 1, "learning_objectives": ["Apply scientific method", "Design investigations"], "prerequisites": []},
        {"name": "Data Collection & Analysis", "description": "Gathering and interpreting scientific data", "difficulty_level": 3, "estimated_study_minutes": 45, "order_index": 2, "learning_objectives": ["Collect valid data", "Analyze results"], "prerequisites": ["Scientific Method"]},
        {"name": "Scientific Communication", "description": "Presenting and discussing scientific findings", "difficulty_level": 3, "estimated_study_minutes": 35, "order_index": 3, "learning_objectives": ["Communicate science", "Use scientific vocabulary"], "prerequisites": ["Data Collection & Analysis"]}
      ]
    },
    {
      "name": "Physical Science",
      "code": "II",
      "description": "Matter, energy, forces, and motion",
      "weight_percentage": 25, 
      "order_index": 2,
      "concepts": [
        {"name": "Properties of Matter", "description": "Physical and chemical properties of materials", "difficulty_level": 2, "estimated_study_minutes": 50, "order_index": 1, "learning_objectives": ["Identify matter properties", "Classify materials"], "prerequisites": []},
        {"name": "Energy & Motion", "description": "Forms of energy and principles of motion", "difficulty_level": 3, "estimated_study_minutes": 55, "order_index": 2, "learning_objectives": ["Understand energy forms", "Explain motion principles"], "prerequisites": ["Properties of Matter"]},
        {"name": "Forces & Interactions", "description": "Types of forces and their effects", "difficulty_level": 3, "estimated_study_minutes": 45, "order_index": 3, "learning_objectives": ["Identify forces", "Predict interactions"], "prerequisites": ["Energy & Motion"]}
      ]
    }
  ]'::jsonb
);

-- Continue with other certifications...
-- Reading/Language Arts EC-6 (903)
SELECT create_certification_structure(
  '903',
  'TExES Reading/Language Arts EC-6 (903)',
  'Comprehensive reading and language arts instruction',
  '[
    {
      "name": "Reading Development & Comprehension",
      "code": "I",
      "description": "Teaching reading skills and comprehension strategies", 
      "weight_percentage": 40,
      "order_index": 1,
      "concepts": [
        {"name": "Phonemic Awareness", "description": "Sound awareness and phonological processing", "difficulty_level": 2, "estimated_study_minutes": 45, "order_index": 1, "learning_objectives": ["Develop sound awareness", "Teach phonemic manipulation"], "prerequisites": []},
        {"name": "Phonics & Decoding", "description": "Letter-sound relationships and word recognition", "difficulty_level": 2, "estimated_study_minutes": 50, "order_index": 2, "learning_objectives": ["Teach systematic phonics", "Support decoding skills"], "prerequisites": ["Phonemic Awareness"]},
        {"name": "Fluency Development", "description": "Reading rate, accuracy, and expression", "difficulty_level": 3, "estimated_study_minutes": 40, "order_index": 3, "learning_objectives": ["Build reading fluency", "Improve expression"], "prerequisites": ["Phonics & Decoding"]},
        {"name": "Reading Comprehension", "description": "Understanding and analyzing text", "difficulty_level": 4, "estimated_study_minutes": 60, "order_index": 4, "learning_objectives": ["Teach comprehension strategies", "Develop critical thinking"], "prerequisites": ["Fluency Development"]}
      ]
    }
  ]'::jsonb
);

-- ============================================
-- VERIFICATION OF ALL CERTIFICATIONS
-- ============================================

-- Summary of all created certifications
SELECT 
  c.test_code,
  c.name as certification,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT co.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id  
LEFT JOIN concepts co ON d.id = co.domain_id
LEFT JOIN content_items ci ON co.id = ci.concept_id
WHERE c.test_code IN ('391', '901', '902', '903')
GROUP BY c.test_code, c.name
ORDER BY c.test_code;

RAISE NOTICE 'Certification foundation complete! All structures created and ready for content.';
