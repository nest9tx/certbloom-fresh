-- 🎯 DOMAIN 2-4 LEARNING MODULE BUILDER
-- Complete template system for all remaining 902 concepts

-- ============================================
-- DOMAIN 2: PATTERNS, RELATIONSHIPS, AND ALGEBRAIC REASONING (Concepts 5-8)
-- ============================================

-- CONCEPT 5: Patterns and Sequences
SELECT build_concept_learning_modules(
    'Patterns and Sequences',
    'Patterns and sequences are foundational to algebraic thinking and mathematical reasoning. Students must learn to identify, extend, and create patterns using numbers, shapes, and real-world contexts. This builds the foundation for functions and algebraic relationships.',
    ARRAY[
        'Identifying and describing patterns using multiple representations',
        'Understanding the difference between growing and repeating patterns',
        'Using pattern rules to predict future terms and missing elements',
        'Connecting patterns to algebraic thinking and function relationships'
    ],
    ARRAY[
        'Pattern blocks and manipulatives for visual patterns',
        'Hundreds charts for number pattern exploration',
        'T-charts to show input-output relationships',
        'Graphing patterns to show function relationships'
    ],
    ARRAY[
        'pattern', 'sequence', 'term', 'rule', 'growing pattern', 'repeating pattern',
        'arithmetic sequence', 'geometric sequence', 'function table', 'input', 'output'
    ],
    ARRAY[
        '1. Start with concrete repeating patterns using manipulatives',
        '2. Move to visual and number patterns',
        '3. Introduce growing patterns and pattern rules',
        '4. Connect patterns to algebraic thinking and functions',
        '5. Apply pattern reasoning to real-world situations'
    ],
    ARRAY[
        'Below grade level: Simple repeating patterns with colors/shapes',
        'On grade level: Number patterns and simple growing patterns',
        'Above grade level: Complex patterns and algebraic notation',
        'ELL students: Use visual patterns and concrete materials'
    ],
    ARRAY[
        'Have students describe pattern rules in their own words',
        'Ask students to find the 10th term without listing all terms',
        'Use "What comes next?" and "What would the 50th term be?"',
        'Connect patterns to real-world growth situations'
    ],
    ARRAY[
        'Pattern hunts in the classroom and school environment',
        'Creating patterns with various materials and contexts',
        'Pattern error analysis and misconception discussions',
        'Real-world pattern applications (population growth, savings)'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Continuing Patterns Without Understanding the Rule',
            'student_error', 'Extending 2, 4, 6, 8... as 2, 4, 6, 8, 2, 4, 6, 8...',
            'why_it_happens', 'Students see it as repeating instead of growing pattern',
            'intervention', 'Use physical objects to show +2 pattern rule',
            'prevention', 'Always discuss the pattern rule, not just next terms'
        ),
        jsonb_build_object(
            'type', 'Position vs. Term Value Confusion',
            'student_error', 'Saying the 5th term in 3, 6, 9, 12... is 5',
            'why_it_happens', 'Students confuse position with actual term value',
            'intervention', 'Use position cards and term value cards separately',
            'prevention', 'Always distinguish between "which term" and "what value"'
        )
    ],
    ARRAY[
        'What is the pattern rule for 5, 10, 15, 20...?',
        'If the pattern is +3 starting at 2, what is the 8th term?',
        'How are these patterns the same/different: 2,4,6,8 and 1,3,5,7?',
        'Create a growing pattern that starts with 10.'
    ],
    ARRAY[
        'Connect patterns to real-world situations students understand',
        'Use multiple representations: visual, numeric, and verbal',
        'Emphasize pattern rules over just finding next terms',
        'Build toward algebraic thinking and function concepts'
    ]
);

-- CONCEPT 6: Algebraic Expressions
SELECT build_concept_learning_modules(
    'Algebraic Expressions',
    'Variables and expressions bridge arithmetic and algebra. Students must understand variables as representations of unknown or changing quantities, not just "letters in math." Effective teaching connects variables to real-world contexts and builds from concrete to abstract thinking.',
    ARRAY[
        'Understanding variables as representations of unknown or changing quantities',
        'Writing and evaluating algebraic expressions from word problems',
        'Using the order of operations consistently in expression evaluation',
        'Connecting expressions to real-world situations and patterns'
    ],
    ARRAY[
        'Algebra tiles for building and visualizing expressions',
        'Balance scales for understanding equality and equations',
        'Function machines for input-output relationships',
        'Real-world contexts: money, measurement, growth problems'
    ],
    ARRAY[
        'variable', 'expression', 'equation', 'coefficient', 'constant',
        'term', 'evaluate', 'substitute', 'order of operations', 'PEMDAS'
    ],
    ARRAY[
        '1. Start with patterns and "what number" questions',
        '2. Introduce variables as placeholders for unknown values',
        '3. Build expressions from word problems and real contexts',
        '4. Practice evaluation with substitution',
        '5. Connect to equation solving strategies'
    ],
    ARRAY[
        'Below grade level: Use simple expressions with one operation',
        'On grade level: Multi-step expressions with order of operations',
        'Above grade level: Complex expressions and algebraic reasoning',
        'ELL students: Connect expressions to familiar word problems'
    ],
    ARRAY[
        'Have students write expressions for word problem situations',
        'Ask students to evaluate expressions with given variable values',
        'Use "Tell me in words what this expression means"',
        'Connect expressions to function tables and patterns'
    ],
    ARRAY[
        'Expression writing from real-world scenarios',
        'Evaluation practice with concrete substitution',
        'Error analysis with order of operations mistakes',
        'Connection activities linking expressions to equations'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Order of Operations Errors',
            'student_error', 'Evaluating 2 + 3 × 4 as (2 + 3) × 4 = 20',
            'why_it_happens', 'Students work left to right without considering operation priority',
            'intervention', 'Use PEMDAS memory devices and step-by-step practice',
            'prevention', 'Emphasize operation hierarchy from introduction'
        ),
        jsonb_build_object(
            'type', 'Variable as Label Instead of Quantity',
            'student_error', 'Thinking x always equals the same value in all problems',
            'why_it_happens', 'Students see variables as abbreviations, not unknowns',
            'intervention', 'Use different contexts where same variable represents different values',
            'prevention', 'Always connect variables to changing or unknown quantities'
        )
    ],
    ARRAY[
        'Write an expression for "5 more than a number"',
        'If x = 4, what is the value of 3x + 7?',
        'What does the expression 2n + 5 represent in a word problem?',
        'Evaluate 4 + 3 × 2 - 1 using order of operations'
    ],
    ARRAY[
        'Always connect variables to real-world changing quantities',
        'Use multiple contexts for the same variable letter',
        'Emphasize order of operations through consistent practice',
        'Build from concrete "what number" problems to abstract variables'
    ]
);

-- CONCEPT 7: Linear Equations
SELECT build_concept_learning_modules(
    'Linear Equations',
    'Equations and inequalities represent mathematical relationships and are essential for problem solving. Students must understand equality as balance and develop systematic approaches to finding unknown values while maintaining equality.',
    ARRAY[
        'Understanding equations as statements of equality and balance',
        'Using systematic approaches to solve for unknown variables',
        'Checking solutions by substitution and logical reasoning',
        'Connecting equation solving to real-world problem contexts'
    ],
    ARRAY[
        'Balance scales to demonstrate equality maintenance',
        'Algebra tiles for visual equation manipulation',
        'Number lines for inequality representation',
        'Real-world contexts: money problems, measurement situations'
    ],
    ARRAY[
        'equation', 'inequality', 'solution', 'solve', 'isolate', 'inverse operations',
        'equivalent equations', 'greater than', 'less than', 'balance'
    ],
    ARRAY[
        '1. Begin with simple one-step equations using inverse operations',
        '2. Use balance scales to demonstrate maintaining equality',
        '3. Progress to two-step equations with systematic approaches',
        '4. Introduce inequalities as ranges of solutions',
        '5. Apply equation solving to real-world problem situations'
    ],
    ARRAY[
        'Below grade level: One-step equations with whole numbers',
        'On grade level: Two-step equations and simple inequalities',
        'Above grade level: Multi-step equations and complex inequalities',
        'ELL students: Use visual models and word problem contexts'
    ],
    ARRAY[
        'Have students check solutions by substituting back',
        'Ask students to explain their solving steps',
        'Use "What operation undoes this?" questioning',
        'Connect equations to real-world problem situations'
    ],
    ARRAY[
        'Equation solving with balance scale demonstrations',
        'Real-world equation writing and solving practice',
        'Error analysis with common algebraic mistakes',
        'Inequality exploration with number line representations'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Not Maintaining Balance',
            'student_error', 'Solving x + 5 = 12 by subtracting 5 from only one side',
            'why_it_happens', 'Students forget that equations must stay balanced',
            'intervention', 'Use physical balance scales to show both sides changing',
            'prevention', 'Always emphasize "what you do to one side, do to the other"'
        ),
        jsonb_build_object(
            'type', 'Order of Operations in Solving',
            'student_error', 'Solving 2x + 3 = 11 by dividing by 2 first',
            'why_it_happens', 'Students apply operations in wrong order when solving',
            'intervention', 'Teach "undo operations in reverse order" strategy',
            'prevention', 'Connect solving to "unwrapping" the variable step by step'
        )
    ],
    ARRAY[
        'Solve: x + 8 = 15. Check your answer.',
        'What inequality represents "at least 10 students"?',
        'If 2n - 3 = 9, what is the value of n?',
        'Write and solve an equation for: "A number plus 7 equals 20"'
    ],
    ARRAY[
        'Always emphasize maintaining balance in equations',
        'Connect solving steps to inverse operations',
        'Use real-world contexts to make equations meaningful',
        'Teach systematic solving procedures with checking'
    ]
);

-- CONCEPT 8: Functions and Relationships
SELECT build_concept_learning_modules(
    'Functions and Relationships',
    'Functions represent relationships between variables and are fundamental to advanced mathematics. Students must understand functions as rules that assign exactly one output to each input, connecting algebraic, tabular, and graphical representations.',
    ARRAY[
        'Understanding functions as input-output relationships with unique outputs',
        'Representing functions using tables, graphs, and algebraic expressions',
        'Identifying linear vs. non-linear function patterns',
        'Connecting function representations to real-world situations'
    ],
    ARRAY[
        'Function machines for input-output visualization',
        'Coordinate grids for graphical representation',
        'T-tables for organizing function data',
        'Real-world contexts: distance-time, cost-quantity relationships'
    ],
    ARRAY[
        'function', 'input', 'output', 'domain', 'range', 'linear', 'non-linear',
        'coordinate plane', 'x-axis', 'y-axis', 'ordered pair', 'graph'
    ],
    ARRAY[
        '1. Start with function machines and input-output tables',
        '2. Explore patterns in function tables',
        '3. Graph functions on coordinate planes',
        '4. Connect algebraic expressions to function tables and graphs',
        '5. Apply function concepts to real-world situations'
    ],
    ARRAY[
        'Below grade level: Simple function tables with clear patterns',
        'On grade level: Linear functions and basic graphing',
        'Above grade level: Non-linear functions and complex relationships',
        'ELL students: Use visual function machines and concrete contexts'
    ],
    ARRAY[
        'Have students describe function patterns in words',
        'Ask students to predict outputs for given inputs',
        'Use "What rule connects inputs to outputs?"',
        'Connect graphs to real-world story contexts'
    ],
    ARRAY[
        'Function table creation and pattern analysis',
        'Graphing activities with real-world data',
        'Function machine explorations and investigations',
        'Error analysis with graphing and function misconceptions'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Confusing Domain and Range',
            'student_error', 'Listing y-values as domain and x-values as range',
            'why_it_happens', 'Students confuse input/output with horizontal/vertical',
            'intervention', 'Use function machines with clear input/output labeling',
            'prevention', 'Always connect domain to inputs and range to outputs'
        ),
        jsonb_build_object(
            'type', 'Graphing Points Incorrectly',
            'student_error', 'Plotting (3,5) at position (5,3) on coordinate plane',
            'why_it_happens', 'Students reverse x and y coordinates',
            'intervention', 'Use "over then up" or "x across, y up" memory aids',
            'prevention', 'Practice coordinate plotting with consistent language'
        )
    ],
    ARRAY[
        'If the input is 5 and the rule is "multiply by 3 then add 2", what is the output?',
        'What pattern do you see in this function table?',
        'Graph the points (1,3), (2,5), (3,7). What pattern do you notice?',
        'Is this a function: {(1,2), (2,4), (1,3)}? Why or why not?'
    ],
    ARRAY[
        'Use function machines to build input-output understanding',
        'Connect algebraic, tabular, and graphical representations',
        'Emphasize real-world applications of function relationships',
        'Build understanding of functions as mathematical relationships'
    ]
);

-- ============================================
-- VERIFICATION QUERY FOR DOMAIN 2
-- ============================================
SELECT 
    'Domain 2 Complete!' as status,
    COUNT(*) as concepts_built
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' AND d.name = 'Patterns, Relationships, and Algebraic Reasoning';
