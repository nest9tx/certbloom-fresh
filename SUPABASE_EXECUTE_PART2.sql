-- 🚀 EXECUTE THIS IN SUPABASE SQL EDITOR (PART 2)
-- Domain 1 Concept Content - Execute after PART1

-- CONCEPT 2: Operations with Whole Numbers
SELECT build_concept_learning_modules(
    'Operations with Whole Numbers',
    'Operations with whole numbers form the foundation for computational fluency. Students must understand the meaning behind addition, subtraction, multiplication, and division, not just memorize procedures. Effective teaching emphasizes conceptual understanding, multiple strategies, and real-world applications.',
    ARRAY[
        'Understanding operations as actions on quantities, not just symbols',
        'Connecting operations to real-world situations and problem solving',
        'Building fluency through understanding, not just memorization',
        'Using multiple strategies to develop number sense and flexibility'
    ],
    ARRAY[
        'Base-10 blocks for concrete understanding',
        'Number lines for visualization of operations',
        'Arrays and area models for multiplication',
        'Fact family triangles for operation relationships'
    ],
    ARRAY[
        'sum', 'difference', 'product', 'quotient', 'addend', 'factor',
        'algorithm', 'strategy', 'regroup', 'carry', 'borrow', 'remainder',
        'commutative', 'associative', 'distributive', 'identity property'
    ],
    ARRAY[
        '1. Start with concrete manipulatives and real-world contexts',
        '2. Move to pictorial representations and visual models',
        '3. Introduce multiple strategies before standard algorithms',
        '4. Connect procedures to conceptual understanding',
        '5. Practice for fluency with understanding'
    ],
    ARRAY[
        'Below grade level: Use manipulatives and smaller numbers',
        'On grade level: Practice multiple strategies and algorithms',
        'Above grade level: Explore patterns and algebraic thinking',
        'ELL students: Emphasize mathematical language and vocabulary'
    ],
    ARRAY[
        'Have students explain their solution strategies',
        'Use number talks to share different approaches',
        'Ask students to solve problems using two different methods',
        'Check understanding: "Does your answer make sense?"'
    ],
    ARRAY[
        'Mental math strategies and number talks',
        'Real-world problem solving with context',
        'Error analysis using common student mistakes',
        'Strategy sharing and mathematical discourse'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Addition Regrouping Errors',
            'student_error', 'Adding without regrouping: 47 + 38 = 715',
            'why_it_happens', 'Students add digits in each column without considering place value',
            'intervention', 'Use base-10 blocks to show when regrouping is needed',
            'prevention', 'Emphasize place value understanding before algorithms'
        ),
        jsonb_build_object(
            'type', 'Multiplication as Repeated Addition',
            'student_error', 'Thinking 4 × 6 means "add 4 six times" (4+4+4+4+4+4)',
            'why_it_happens', 'Students apply addition thinking to multiplication',
            'intervention', 'Use arrays to show 4 groups of 6 vs 6 groups of 4',
            'prevention', 'Teach multiple models for multiplication from the beginning'
        )
    ],
    ARRAY[
        'What is 47 + 38? Show your thinking.',
        'Solve 84 - 39 using two different strategies.',
        'A student says 6 × 4 = 6 + 4. How would you respond?',
        'What does it mean to regroup in addition?'
    ],
    ARRAY[
        'Use concrete manipulatives to build understanding',
        'Teach multiple strategies before standard algorithms',
        'Connect operations to real-world problem contexts',
        'Emphasize place value understanding in all operations'
    ]
);

-- CONCEPT 3: Fractions and Decimals
SELECT build_concept_learning_modules(
    'Fractions and Decimals',
    'Fractions and decimals represent parts of a whole and are essential for proportional reasoning. Students must understand fractions as numbers, not just parts of shapes. Effective teaching uses multiple representations and connects fractions to real-world experiences.',
    ARRAY[
        'Fractions as numbers on the number line, not just pieces of pie',
        'Understanding equivalence through multiple representations',
        'Connecting fractions and decimals as different notations for the same values',
        'Building conceptual understanding before computational procedures'
    ],
    ARRAY[
        'Fraction bars and strips for comparison',
        'Circle models (pie charts) for part-whole relationships',
        'Number lines for fraction as number understanding',
        'Decimal grids for place value and equivalence'
    ],
    ARRAY[
        'numerator', 'denominator', 'equivalent', 'benchmark fractions',
        'unit fraction', 'mixed number', 'improper fraction', 'decimal',
        'tenths', 'hundredths', 'thousandths', 'decimal point'
    ],
    ARRAY[
        '1. Begin with unit fractions and fraction as part of one whole',
        '2. Use multiple models: area, length, set, and number line',
        '3. Develop understanding of equivalence through visual models',
        '4. Connect fractions to decimals using place value understanding',
        '5. Introduce operations with strong conceptual foundation'
    ],
    ARRAY[
        'Below grade level: Focus on unit fractions and halves/fourths',
        'On grade level: Work with benchmark fractions and equivalence',
        'Above grade level: Explore complex fractions and decimal patterns',
        'ELL students: Use visual models and connect to familiar contexts'
    ],
    ARRAY[
        'Have students use fraction bars to show equivalent fractions',
        'Ask students to place fractions on a number line',
        'Use real-world contexts: "If we eat 3/8 of a pizza, how much is left?"',
        'Compare fractions using benchmark fractions like 1/2'
    ],
    ARRAY[
        'Fraction talks using visual models for comparison',
        'Real-world fraction applications (cooking, measurement)',
        'Fraction-decimal connection activities',
        'Error analysis with common fraction misconceptions'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Larger Denominator Means Larger Fraction',
            'student_error', 'Thinking 1/8 > 1/4 because 8 > 4',
            'why_it_happens', 'Students apply whole number thinking to fractions',
            'intervention', 'Use pizza or chocolate bar models to show 1/8 vs 1/4',
            'prevention', 'Always use visual models when introducing fractions'
        ),
        jsonb_build_object(
            'type', 'Adding Denominators',
            'student_error', 'Computing 1/4 + 1/4 = 2/8',
            'why_it_happens', 'Students add both numerator and denominator',
            'intervention', 'Use fraction bars to show 1/4 + 1/4 = 2/4',
            'prevention', 'Emphasize what the denominator represents (size of pieces)'
        )
    ],
    ARRAY[
        'Which is larger: 3/4 or 5/6? Explain using a visual model.',
        'Show 0.7 using a decimal grid. What fraction is this?',
        'A student says 1/3 = 0.3. How would you respond?',
        'What are three different ways to show 1/2?'
    ],
    ARRAY[
        'Always use visual models to support fraction understanding',
        'Connect fractions to real-world contexts students understand',
        'Emphasize equivalence through multiple representations',
        'Build decimal understanding through place value connections'
    ]
);

-- CONCEPT 4: Proportional Reasoning
SELECT build_concept_learning_modules(
    'Proportional Reasoning',
    'Proportional reasoning involves understanding relationships between quantities and is fundamental to algebra, geometry, and real-world problem solving. Students must recognize when quantities change at the same rate and use this understanding to solve problems.',
    ARRAY[
        'Understanding ratios as comparisons between quantities',
        'Recognizing proportional relationships in tables, graphs, and contexts',
        'Using multiple strategies to solve proportion problems',
        'Connecting proportional reasoning to fractions, decimals, and percentages'
    ],
    ARRAY[
        'Double number lines for rate problems',
        'Ratio tables for equivalent ratios',
        'Graphs showing proportional relationships',
        'Real-world contexts: recipes, maps, unit rates'
    ],
    ARRAY[
        'ratio', 'proportion', 'rate', 'unit rate', 'scale factor',
        'equivalent ratios', 'percent', 'cross multiply', 'per',
        'for every', 'constant rate', 'proportional relationship'
    ],
    ARRAY[
        '1. Start with concrete experiences comparing quantities',
        '2. Introduce ratio language and notation',
        '3. Build understanding of equivalent ratios',
        '4. Connect to fractions and decimal understanding',
        '5. Apply to real-world problem solving contexts'
    ],
    ARRAY[
        'Below grade level: Use simple whole number ratios and concrete contexts',
        'On grade level: Work with equivalent ratios and basic proportions',
        'Above grade level: Explore complex proportions and scale factors',
        'ELL students: Emphasize ratio language and real-world connections'
    ],
    ARRAY[
        'Have students create ratio tables for real-world situations',
        'Use double number lines to solve rate problems',
        'Ask students to find unit rates in everyday contexts',
        'Compare different strategies for solving proportion problems'
    ],
    ARRAY[
        'Real-world proportion problems (recipes, maps, shopping)',
        'Ratio reasoning with manipulatives and visual models',
        'Unit rate activities and comparisons',
        'Error analysis with common proportion mistakes'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Cross Multiplication Without Understanding',
            'student_error', 'Solving 2/3 = x/12 as 2×12 = 3×x without reasoning',
            'why_it_happens', 'Students memorize procedure without understanding ratios',
            'intervention', 'Use ratio tables to find x = 8 before introducing cross multiplication',
            'prevention', 'Build ratio understanding before algorithmic procedures'
        ),
        jsonb_build_object(
            'type', 'Additive Instead of Multiplicative Thinking',
            'student_error', 'If 2 cups flour serves 4 people, 4 cups serves 6 people (+2)',
            'why_it_happens', 'Students use addition instead of multiplication for scaling',
            'intervention', 'Use double number lines to show multiplicative relationships',
            'prevention', 'Emphasize "times as much" language in ratio contexts'
        )
    ],
    ARRAY[
        'If 3 apples cost $2, how much do 9 apples cost? Show your reasoning.',
        'A recipe calls for 2 cups flour for 12 cookies. How much flour for 18 cookies?',
        'Which is a better buy: 3 for $5 or 5 for $8? Explain.',
        'What is the unit rate for 150 miles in 3 hours?'
    ],
    ARRAY[
        'Use real-world contexts that students can understand and verify',
        'Build multiplicative reasoning through visual models',
        'Connect to fraction and decimal understanding',
        'Emphasize multiple strategies for solving proportion problems'
    ]
);

-- Verification query
SELECT 
    c.name as concept_name,
    COUNT(lm.id) as module_count,
    SUM(CASE WHEN lm.content_data IS NOT NULL AND jsonb_typeof(lm.content_data) = 'object' THEN 1 ELSE 0 END) as rich_content_modules
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
LEFT JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902' AND d.name = 'Number Concepts and Operations'
GROUP BY c.name, c.order_index
ORDER BY c.order_index;
