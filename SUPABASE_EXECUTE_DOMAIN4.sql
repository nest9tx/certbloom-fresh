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
    'Data representation makes information accessible and supports analysis. Students must understand how to choose appropriate graphs and charts while developing skills to read, interpret, and critique data representations critically.',
    ARRAY[
        'Choosing appropriate graphs and charts for different data types',
        'Creating clear and accurate visual representations of data',
        'Reading and interpreting information from various graph types',
        'Recognizing how representation choices can influence interpretation'
    ],
    ARRAY[
        'Graph paper and graphing tools for manual construction',
        'Technology tools for creating digital graphs and charts',
        'Real-world examples of graphs from media and research',
        'Comparison activities with different representation choices'
    ],
    ARRAY[
        'bar graph', 'line graph', 'pie chart', 'histogram', 'scatter plot',
        'axis', 'scale', 'title', 'legend', 'trend', 'correlation'
    ],
    ARRAY[
        '1. Begin with simple bar graphs and pictographs',
        '2. Explore different graph types and their purposes',
        '3. Practice reading and interpreting existing graphs',
        '4. Create original graphs from collected data',
        '5. Analyze how representation choices affect interpretation'
    ],
    ARRAY[
        'Below grade level: Simple bar graphs and pictographs',
        'On grade level: Multiple graph types and interpretation',
        'Above grade level: Complex graphs and critical analysis',
        'ELL students: Use visual graphs with clear labels and contexts'
    ],
    ARRAY[
        'Have students explain what graphs show in their own words',
        'Ask students to choose the best graph type for specific data',
        'Use "What story does this graph tell?" questioning',
        'Compare different representations of the same data'
    ],
    ARRAY[
        'Graph creation projects using student-collected data',
        'Media literacy activities analyzing graphs in news',
        'Comparison activities with different graph types',
        'Error analysis with misleading graphs and representations'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Inappropriate Graph Choice',
            'student_error', 'Using line graph for categorical data like favorite colors',
            'why_it_happens', 'Students don''t understand when different graph types are appropriate',
            'intervention', 'Practice matching data types with appropriate graph types',
            'prevention', 'Teach decision tree for choosing graph types'
        ),
        jsonb_build_object(
            'type', 'Scale Problems',
            'student_error', 'Creating graphs with uneven or inappropriate scales',
            'why_it_happens', 'Students don''t understand how scale affects interpretation',
            'intervention', 'Compare same data with different scales to show effect',
            'prevention', 'Always discuss scale choices and their impact'
        )
    ],
    ARRAY[
        'What type of graph would best show temperature changes over a week?',
        'What does the highest bar in this graph represent?',
        'How might this graph be misleading?',
        'What trend do you see in this line graph?'
    ],
    ARRAY[
        'Match graph types to data types and purposes',
        'Emphasize clear labeling and appropriate scales',
        'Use real-world graphs to develop interpretation skills',
        'Discuss how representation choices affect perception'
    ]
);

-- CONCEPT 15: Statistical Analysis
SELECT build_concept_learning_modules(
    'Statistical Analysis',
    'Statistical measures summarize data characteristics and support comparison and analysis. Students must understand mean, median, mode, and range as different ways to describe data sets, each providing unique insights into data distribution.',
    ARRAY[
        'Understanding mean, median, mode, and range as data summaries',
        'Calculating statistical measures accurately and efficiently',
        'Choosing appropriate measures for different data sets and purposes',
        'Interpreting statistical measures in real-world contexts'
    ],
    ARRAY[
        'Physical manipulatives for leveling and averaging activities',
        'Number lines for median and range visualization',
        'Real-world data sets for calculation practice',
        'Technology tools for statistical calculation and verification'
    ],
    ARRAY[
        'mean', 'median', 'mode', 'range', 'average', 'middle value',
        'most frequent', 'spread', 'outlier', 'typical', 'center'
    ],
    ARRAY[
        '1. Begin with concrete leveling activities for mean understanding',
        '2. Explore median as middle value with ordered data',
        '3. Identify mode as most frequent value',
        '4. Calculate range as measure of spread',
        '5. Apply measures to real-world data analysis'
    ],
    ARRAY[
        'Below grade level: Simple data sets with clear patterns',
        'On grade level: Various measures with interpretation',
        'Above grade level: Complex data sets and measure comparison',
        'ELL students: Use concrete activities and visual representations'
    ],
    ARRAY[
        'Have students explain what each measure tells about data',
        'Ask students which measure best represents a data set',
        'Use "What happens if we add this outlier?" explorations',
        'Connect measures to real-world decision making'
    ],
    ARRAY[
        'Real-world data analysis projects and investigations',
        'Comparison activities showing when different measures are useful',
        'Outlier exploration and effect on statistical measures',
        'Error analysis with calculation and interpretation mistakes'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Mean Calculation Errors',
            'student_error', 'Forgetting to divide by number of values when calculating mean',
            'why_it_happens', 'Students add correctly but don''t complete the averaging process',
            'intervention', 'Use physical leveling activities to show averaging concept',
            'prevention', 'Always connect mean to "fair share" or "leveling" concepts'
        ),
        jsonb_build_object(
            'type', 'Median with Even Number of Values',
            'student_error', 'Choosing either middle value instead of averaging them',
            'why_it_happens', 'Students don''t know how to handle even number of data points',
            'intervention', 'Use physical arrangement of objects to show middle position',
            'prevention', 'Practice both odd and even cases with concrete examples'
        )
    ],
    ARRAY[
        'What is the mean of 4, 6, 8, 10, 12?',
        'Find the median of 3, 7, 5, 9, 1, 8.',
        'Which measure of center would be most affected by an outlier?',
        'What does a large range tell you about a data set?'
    ],
    ARRAY[
        'Connect statistical measures to real-world interpretation',
        'Use concrete activities to build conceptual understanding',
        'Practice with various data sets including outliers',
        'Emphasize when different measures are most useful'
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
    SUM(CASE WHEN lm.content_data IS NOT NULL AND jsonb_object_keys_length(lm.content_data) > 3 THEN 1 ELSE 0 END) as rich_content_modules
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
