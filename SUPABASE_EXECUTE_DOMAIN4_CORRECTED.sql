-- 🎯 DOMAIN 4: DATA ANALYSIS AND PERSONAL FINANCIAL LITERACY (Concepts 13-16)

-- CONCEPT 13: Data Collection and Organization
SELECT build_concept_learning_modules(
    'Data Collection and Organization',
    'Data collection and organization form the foundation of statistical reasoning. Students must understand how to gather, organize, and represent data in meaningful ways that support analysis and decision-making in real-world contexts.',
    ARRAY[
        'Understanding different methods of data collection and their purposes',
        'Organizing data using tables, charts, and systematic approaches',
        'Recognizing bias and limitations in data collection methods',
        'Connecting data organization to analysis and interpretation goals'
    ],
    ARRAY[
        'Surveys and questionnaires for primary data collection',
        'Tally charts and frequency tables for organization',
        'Real-world data sources: newspapers, websites, research',
        'Technology tools for data collection and management'
    ],
    ARRAY[
        'data', 'survey', 'sample', 'population', 'bias', 'frequency',
        'tally', 'questionnaire', 'variable', 'categorical', 'numerical'
    ],
    ARRAY[
        '1. Begin with simple data collection from classroom contexts',
        '2. Explore different types of questions and data',
        '3. Practice organizing data using various methods',
        '4. Discuss bias and representation in data collection',
        '5. Connect to real-world data analysis purposes'
    ],
    ARRAY[
        'Below grade level: Simple classroom surveys and basic organization',
        'On grade level: Various data types and organization methods',
        'Above grade level: Complex surveys and bias analysis',
        'ELL students: Use familiar contexts and visual organization tools'
    ],
    ARRAY[
        'Have students design surveys for questions they care about',
        'Ask students to identify potential bias in data collection',
        'Use "What questions could this data help answer?"',
        'Connect data collection to decision-making contexts'
    ],
    ARRAY[
        'Classroom and school survey projects',
        'Real-world data investigation and analysis',
        'Comparison of different data collection methods',
        'Error analysis with data collection bias and problems'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Leading Questions in Surveys',
            'student_error', 'Asking "Don''t you think homework is too much?" instead of neutral questions',
            'why_it_happens', 'Students don''t understand how question wording affects responses',
            'intervention', 'Compare responses to leading vs. neutral questions',
            'prevention', 'Teach principles of neutral question design'
        ),
        jsonb_build_object(
            'type', 'Sample Bias',
            'student_error', 'Surveying only friends about school lunch preferences',
            'why_it_happens', 'Students don''t understand representative sampling',
            'intervention', 'Discuss how different groups might have different opinions',
            'prevention', 'Always discuss who is being surveyed and why'
        )
    ],
    ARRAY[
        'What question would you ask to find out students'' favorite subjects?',
        'How could you collect data about reading habits in your school?',
        'What might be wrong with surveying only 6th graders about school policies?',
        'How would you organize data about students'' birth months?'
    ],
    ARRAY[
        'Use real questions that students care about investigating',
        'Emphasize neutral question design and representative sampling',
        'Connect data collection to decision-making purposes',
        'Practice multiple methods of data organization'
    ]
);

-- CONCEPT 14: Personal Financial Literacy
SELECT build_concept_learning_modules(
    'Personal Financial Literacy',
    'Personal financial literacy empowers students to make informed financial decisions throughout their lives. Students must understand basic financial concepts, develop money management skills, and recognize the mathematical relationships in financial planning and decision-making.',
    ARRAY[
        'Understanding income, expenses, budgets, and financial planning',
        'Calculating interest, loans, and investment returns',
        'Comparing financial options and making informed decisions',
        'Recognizing mathematical relationships in financial contexts'
    ],
    ARRAY[
        'Real-world financial documents: bills, bank statements, loan papers',
        'Budget planning worksheets and tracking tools',
        'Calculators and spreadsheets for financial calculations',
        'Role-playing activities with financial scenarios'
    ],
    ARRAY[
        'income', 'expense', 'budget', 'savings', 'interest', 'loan',
        'credit', 'debt', 'investment', 'profit', 'loss', 'tax'
    ],
    ARRAY[
        '1. Begin with basic income and expense concepts',
        '2. Explore budgeting and financial planning',
        '3. Calculate simple and compound interest',
        '4. Compare financial options and make decisions',
        '5. Apply financial literacy to real-world scenarios'
    ],
    ARRAY[
        'Below grade level: Simple income/expense and basic budgeting',
        'On grade level: Interest calculations and financial planning',
        'Above grade level: Complex financial analysis and investment concepts',
        'ELL students: Use familiar financial contexts and visual aids'
    ],
    ARRAY[
        'Have students create personal or family budgets',
        'Ask students to compare costs of different financial options',
        'Use "Which choice saves more money?" questions',
        'Connect financial math to future planning and goals'
    ],
    ARRAY[
        'Budget creation projects using real or simulated income',
        'Interest calculation activities with savings and loans',
        'Comparison shopping and financial decision activities',
        'Error analysis with financial calculation mistakes'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Not Understanding Compound Interest',
            'student_error', 'Calculating interest only on original principal',
            'why_it_happens', 'Students don''t understand that interest earns interest',
            'intervention', 'Use year-by-year calculations to show compounding effect',
            'prevention', 'Always distinguish between simple and compound interest'
        ),
        jsonb_build_object(
            'type', 'Budget Misconceptions',
            'student_error', 'Thinking budgets are only for people without money',
            'why_it_happens', 'Students misunderstand the purpose of budgeting',
            'intervention', 'Show how budgets help achieve financial goals',
            'prevention', 'Connect budgeting to planning and goal achievement'
        )
    ],
    ARRAY[
        'If you earn $20 per week and save 25%, how much do you save monthly?',
        'What is the total cost of a $500 loan with 10% annual interest for 2 years?',
        'Which saves more: $50 per month for 1 year or $500 at the end of the year?',
        'How would you budget $100 for school supplies, entertainment, and savings?'
    ],
    ARRAY[
        'Use real financial contexts and authentic documents',
        'Connect financial math to students'' future planning',
        'Emphasize decision-making and comparison skills',
        'Build understanding of long-term financial consequences'
    ]
);

-- CONCEPT 15: Statistical Analysis
SELECT build_concept_learning_modules(
    'Statistical Analysis',
    'Statistical analysis helps students interpret data and make informed conclusions. Students must understand measures of central tendency, variability, and distribution while developing skills to analyze data patterns and draw reasonable conclusions.',
    ARRAY[
        'Calculating and interpreting measures of central tendency and spread',
        'Analyzing data distributions and identifying patterns',
        'Drawing conclusions from statistical evidence',
        'Recognizing limitations and potential misinterpretations of statistical data'
    ],
    ARRAY[
        'Real-world data sets for analysis practice',
        'Statistical software and calculator tools',
        'Graphical representations for pattern identification',
        'Comparison activities with different data sets'
    ],
    ARRAY[
        'mean', 'median', 'mode', 'range', 'standard deviation', 'distribution',
        'outlier', 'correlation', 'trend', 'conclusion', 'evidence'
    ],
    ARRAY[
        '1. Begin with calculating basic statistical measures',
        '2. Explore data distributions and variability',
        '3. Practice drawing conclusions from data patterns',
        '4. Analyze real-world data sets and research',
        '5. Critique statistical claims and interpretations'
    ],
    ARRAY[
        'Below grade level: Basic measures with simple data sets',
        'On grade level: Multiple measures and data interpretation',
        'Above grade level: Complex analysis and statistical reasoning',
        'ELL students: Use visual representations and guided analysis'
    ],
    ARRAY[
        'Have students explain what statistical measures reveal about data',
        'Ask students to justify conclusions with statistical evidence',
        'Use "What does this data tell us?" questioning',
        'Connect statistical analysis to real-world decision making'
    ],
    ARRAY[
        'Real-world data analysis projects and investigations',
        'Statistical reasoning activities with authentic contexts',
        'Comparison studies using statistical measures',
        'Error analysis with statistical interpretation mistakes'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Confusing Correlation and Causation',
            'student_error', 'Assuming that correlation between variables means one causes the other',
            'why_it_happens', 'Students don''t understand difference between relationship and causation',
            'intervention', 'Provide examples of correlation without causation',
            'prevention', 'Always distinguish between "related to" and "caused by"'
        ),
        jsonb_build_object(
            'type', 'Overgeneralizing from Small Samples',
            'student_error', 'Drawing broad conclusions from very limited data',
            'why_it_happens', 'Students don''t understand sample size limitations',
            'intervention', 'Compare conclusions from small vs. large samples',
            'prevention', 'Always discuss sample size when analyzing data'
        )
    ],
    ARRAY[
        'What can you conclude from this data about student preferences?',
        'Which statistical measure best represents this data set?',
        'What questions does this data analysis raise for further investigation?',
        'How might this sample be biased or unrepresentative?'
    ],
    ARRAY[
        'Use authentic data sets and real-world contexts',
        'Emphasize evidence-based reasoning and conclusions',
        'Teach appropriate limitations of statistical analysis',
        'Connect analysis skills to informed decision making'
    ]
);

-- CONCEPT 16: Probability
SELECT build_concept_learning_modules(
    'Probability',
    'Probability quantifies uncertainty and helps make predictions about future events. Students must understand probability as a number between 0 and 1 that describes likelihood, connecting theoretical probability to experimental results and real-world applications.',
    ARRAY[
        'Understanding probability as a measure of likelihood from 0 to 1',
        'Distinguishing between theoretical and experimental probability',
        'Calculating simple probabilities using favorable outcomes and total outcomes',
        'Connecting probability concepts to real-world prediction and decision making'
    ],
    ARRAY[
        'Coins, dice, and spinners for probability experiments',
        'Number lines showing probability scale from 0 to 1',
        'Real-world contexts: weather, games, sports predictions',
        'Technology simulations for large-scale probability experiments'
    ],
    ARRAY[
        'probability', 'likelihood', 'chance', 'outcome', 'event',
        'favorable', 'theoretical', 'experimental', 'impossible', 'certain'
    ],
    ARRAY[
        '1. Begin with intuitive discussions of likely vs. unlikely events',
        '2. Introduce probability scale from impossible (0) to certain (1)',
        '3. Calculate simple theoretical probabilities',
        '4. Conduct experiments and compare to theoretical predictions',
        '5. Apply probability reasoning to real-world situations'
    ],
    ARRAY[
        'Below grade level: Simple probability with familiar contexts',
        'On grade level: Theoretical and experimental probability',
        'Above grade level: Complex probability and predictions',
        'ELL students: Use concrete experiments and visual probability scales'
    ],
    ARRAY[
        'Have students predict before conducting probability experiments',
        'Ask students to explain why experimental results vary',
        'Use "How likely is..." questions for probability estimation',
        'Connect probability to real-world decision making'
    ],
    ARRAY[
        'Probability experiments with coins, dice, and spinners',
        'Real-world probability applications and predictions',
        'Comparison of theoretical vs. experimental results',
        'Error analysis with probability misconceptions'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Gambler''s Fallacy',
            'student_error', 'Thinking coin must land heads after several tails',
            'why_it_happens', 'Students believe past results affect future independent events',
            'intervention', 'Conduct many coin flip experiments to show independence',
            'prevention', 'Emphasize that each trial is independent of previous results'
        ),
        jsonb_build_object(
            'type', 'Probability Scale Confusion',
            'student_error', 'Saying probability is 2 out of 3 instead of 2/3',
            'why_it_happens', 'Students don''t understand probability as number between 0 and 1',
            'intervention', 'Use number line and fraction/decimal/percent connections',
            'prevention', 'Always express probability as fraction, decimal, or percent'
        )
    ],
    ARRAY[
        'What is the probability of rolling a 4 on a standard die?',
        'If you flip a coin 10 times and get 7 heads, what might happen on the 11th flip?',
        'Which is more likely: rolling an even number or rolling a number greater than 4?',
        'How could you use probability to make a prediction about tomorrow''s weather?'
    ],
    ARRAY[
        'Use concrete experiments to build probability intuition',
        'Connect theoretical predictions to experimental results',
        'Emphasize probability as number between 0 and 1',
        'Apply probability reasoning to real-world situations'
    ]
);

-- ============================================
-- FINAL VERIFICATION FOR ALL DOMAINS
-- ============================================
SELECT 
    d.name as domain_name,
    COUNT(c.id) as total_concepts,
    COUNT(lm.id) as total_modules,
    SUM(CASE WHEN lm.content_data IS NOT NULL AND jsonb_typeof(lm.content_data) = 'object' THEN 1 ELSE 0 END) as rich_content_modules
FROM domains d
JOIN certifications cert ON d.certification_id = cert.id
JOIN concepts c ON d.id = c.domain_id
LEFT JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902'
GROUP BY d.name, d.order_index
ORDER BY d.order_index;

-- Success summary
SELECT '🎯 ALL 902 MATH LEARNING MODULES COMPLETE!' as status;
SELECT '📚 4 domains × 4 concepts × 5 modules = 80 total learning modules' as scope;
SELECT '🎓 Each module includes rich educational content for teacher preparation' as content;
SELECT '🚀 Ready for Enhanced Learning system deployment!' as next_step;
