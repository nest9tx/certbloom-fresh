-- 🎯 DOMAIN 3: GEOMETRY, MEASUREMENT, AND SPATIAL REASONING (Concepts 9-12)

-- CONCEPT 9: Geometric Shapes and Properties
SELECT build_concept_learning_modules(
    'Geometric Shapes and Properties',
    'Understanding geometric shapes and their properties builds spatial reasoning and logical thinking. Students must move beyond simple shape identification to analyzing attributes, relationships, and classifications that form the foundation for geometric proof and measurement.',
    ARRAY[
        'Identifying and classifying shapes by their geometric properties',
        'Understanding relationships between different geometric figures',
        'Using precise mathematical language to describe geometric attributes',
        'Connecting 2D and 3D shapes to real-world applications'
    ],
    ARRAY[
        'Pattern blocks and geometric manipulatives',
        'Geoboards for shape construction and transformation',
        'Shape sorting activities with attribute classifications',
        'Real-world shape identification in architecture and nature'
    ],
    ARRAY[
        'polygon', 'triangle', 'quadrilateral', 'pentagon', 'hexagon',
        'acute', 'obtuse', 'right angle', 'parallel', 'perpendicular',
        'vertex', 'edge', 'face', 'congruent', 'similar'
    ],
    ARRAY[
        '1. Begin with shape identification and basic properties',
        '2. Explore shape attributes and classifications',
        '3. Investigate relationships between shapes',
        '4. Connect 2D shapes to 3D solids',
        '5. Apply geometric reasoning to real-world contexts'
    ],
    ARRAY[
        'Below grade level: Basic shape identification and simple attributes',
        'On grade level: Shape classification and property analysis',
        'Above grade level: Complex geometric relationships and proofs',
        'ELL students: Use visual models and hands-on shape exploration'
    ],
    ARRAY[
        'Have students justify shape classifications using properties',
        'Ask students to find shapes in their environment',
        'Use "How are these shapes alike/different?" comparisons',
        'Connect shape properties to measurement and area concepts'
    ],
    ARRAY[
        'Shape scavenger hunts in school and community',
        'Geometric constructions with compass and straightedge',
        'Shape transformation activities and explorations',
        'Error analysis with geometric misconceptions'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Confusing Shape Names with Properties',
            'student_error', 'Calling any four-sided figure a "square"',
            'why_it_happens', 'Students overgeneralize familiar shape names',
            'intervention', 'Use attribute blocks to sort shapes by specific properties',
            'prevention', 'Teach shape hierarchy: all squares are rectangles, but not all rectangles are squares'
        ),
        jsonb_build_object(
            'type', 'Angle Misconceptions',
            'student_error', 'Thinking larger shapes automatically have larger angles',
            'why_it_happens', 'Students confuse size with angle measure',
            'intervention', 'Use angle measurement tools to compare angles in different sized shapes',
            'prevention', 'Separate discussions of shape size from angle measurement'
        )
    ],
    ARRAY[
        'What makes a triangle different from other polygons?',
        'How many right angles does a rectangle have?',
        'Which shapes have parallel sides?',
        'What is the difference between a square and a rhombus?'
    ],
    ARRAY[
        'Use precise mathematical vocabulary consistently',
        'Connect shape properties to measurement and calculation',
        'Emphasize shape relationships and hierarchies',
        'Build from concrete manipulation to abstract reasoning'
    ]
);

-- CONCEPT 10: Measurement and Units
SELECT build_concept_learning_modules(
    'Measurement and Units',
    'Measurement connects mathematics to the physical world and requires understanding of both the measurement process and appropriate units. Students must develop measurement sense, estimation skills, and facility with both customary and metric systems.',
    ARRAY[
        'Understanding measurement as comparison to a standard unit',
        'Developing estimation skills and measurement sense',
        'Converting between units within the same measurement system',
        'Choosing appropriate units and tools for different measurement tasks'
    ],
    ARRAY[
        'Rulers, measuring tapes, and various measurement tools',
        'Everyday objects for estimation and comparison',
        'Measurement charts and conversion tables',
        'Real-world measurement contexts and applications'
    ],
    ARRAY[
        'length', 'width', 'height', 'perimeter', 'area', 'volume',
        'inch', 'foot', 'yard', 'mile', 'centimeter', 'meter', 'kilometer',
        'ounce', 'pound', 'gram', 'kilogram', 'estimate', 'precision'
    ],
    ARRAY[
        '1. Begin with non-standard units and direct comparison',
        '2. Introduce standard units and measurement tools',
        '3. Develop estimation strategies and benchmarks',
        '4. Practice unit conversions within systems',
        '5. Apply measurement to real-world problem solving'
    ],
    ARRAY[
        'Below grade level: Non-standard units and simple measurement',
        'On grade level: Standard units and basic conversions',
        'Above grade level: Complex conversions and precision concepts',
        'ELL students: Connect to familiar objects and measurement experiences'
    ],
    ARRAY[
        'Have students estimate before measuring',
        'Ask students to choose appropriate units for different objects',
        'Use "Is your answer reasonable?" after measurement',
        'Connect measurement to real-world applications'
    ],
    ARRAY[
        'Measurement scavenger hunts and estimation challenges',
        'Cooking and recipe activities requiring measurement',
        'Comparison activities using different measurement systems',
        'Error analysis with measurement misconceptions'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Unit Confusion',
            'student_error', 'Measuring a pencil as "6 meters long"',
            'why_it_happens', 'Students lack understanding of unit size relationships',
            'intervention', 'Use benchmark objects: fingernail ≈ 1 cm, hand span ≈ 20 cm',
            'prevention', 'Always connect units to familiar reference objects'
        ),
        jsonb_build_object(
            'type', 'Conversion Errors',
            'student_error', 'Converting 3 feet to inches as 3 × 3 = 9 inches',
            'why_it_happens', 'Students confuse conversion factors',
            'intervention', 'Use visual models showing 1 foot = 12 inches',
            'prevention', 'Build understanding of conversion relationships before algorithms'
        )
    ],
    ARRAY[
        'Which unit would you use to measure the length of your classroom?',
        'About how many centimeters long is your hand?',
        'If a rope is 4 feet long, how many inches is that?',
        'What tool would be best for measuring the weight of an apple?'
    ],
    ARRAY[
        'Always connect units to familiar benchmark objects',
        'Emphasize estimation before precise measurement',
        'Use real-world contexts for measurement applications',
        'Build understanding of unit relationships through experience'
    ]
);

-- CONCEPT 11: Coordinate Geometry
SELECT build_concept_learning_modules(
    'Coordinate Geometry',
    'Coordinate geometry connects algebra and geometry by using coordinates to represent geometric figures. Students must understand the coordinate plane, plot points accurately, and analyze geometric relationships using coordinate methods.',
    ARRAY[
        'Understanding the coordinate plane and ordered pairs',
        'Plotting and identifying points in all four quadrants',
        'Finding distances and midpoints using coordinates',
        'Analyzing geometric figures using coordinate methods'
    ],
    ARRAY[
        'Coordinate grids and graph paper',
        'Plotting activities with real-world data',
        'Geometric constructions on coordinate planes',
        'Technology tools for coordinate graphing'
    ],
    ARRAY[
        'coordinate plane', 'x-axis', 'y-axis', 'origin', 'quadrant',
        'ordered pair', 'x-coordinate', 'y-coordinate', 'plot', 'distance formula'
    ],
    ARRAY[
        '1. Introduce the coordinate plane and axis system',
        '2. Practice plotting points in all quadrants',
        '3. Explore patterns and relationships in coordinate data',
        '4. Apply coordinate methods to geometric problems',
        '5. Connect to real-world applications and graphing'
    ],
    ARRAY[
        'Below grade level: Plot points in first quadrant only',
        'On grade level: Work with all four quadrants',
        'Above grade level: Distance and midpoint formulas',
        'ELL students: Use concrete grids and hands-on activities'
    ],
    ARRAY[
        'Have students describe locations using coordinates',
        'Ask students to find patterns in coordinate data',
        'Use "Where would this point be?" prediction questions',
        'Connect coordinate work to real-world mapping'
    ],
    ARRAY[
        'Coordinate battleship and treasure hunt games',
        'Real-world mapping and GPS activities',
        'Geometric figure construction on coordinate planes',
        'Error analysis with coordinate plotting mistakes'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Reversing Coordinates',
            'student_error', 'Plotting (3,5) as (5,3) on the coordinate plane',
            'why_it_happens', 'Students confuse x and y coordinate order',
            'intervention', 'Use "over then up" or "x across, y up" memory aids',
            'prevention', 'Always emphasize x-coordinate first, y-coordinate second'
        ),
        jsonb_build_object(
            'type', 'Negative Coordinate Confusion',
            'student_error', 'Plotting (-2,3) in the wrong quadrant',
            'why_it_happens', 'Students struggle with negative number locations',
            'intervention', 'Use number line understanding for negative directions',
            'prevention', 'Connect to familiar contexts: left/right, up/down'
        )
    ],
    ARRAY[
        'What are the coordinates of the point 3 units right and 2 units up from origin?',
        'In which quadrant is the point (-4, 2)?',
        'How far apart are the points (1,3) and (4,7)?',
        'What coordinate represents the center of a rectangle with corners at (0,0) and (6,4)?'
    ],
    ARRAY[
        'Always emphasize "x across, y up" coordinate order',
        'Use real-world contexts like maps and GPS',
        'Connect coordinate work to algebraic thinking',
        'Build understanding of quadrants and negative numbers'
    ]
);

-- CONCEPT 12: Transformations and Symmetry
SELECT build_concept_learning_modules(
    'Transformations and Symmetry',
    'Transformations and symmetry help students understand how shapes move and relate to each other in space. Students must visualize and perform transformations while recognizing symmetrical properties in geometric figures and real-world contexts.',
    ARRAY[
        'Understanding and performing geometric transformations (translations, reflections, rotations)',
        'Identifying lines of symmetry and rotational symmetry in figures',
        'Predicting and describing the results of transformations',
        'Connecting transformations to real-world applications and art'
    ],
    ARRAY[
        'Pattern blocks and geometric shapes for transformation activities',
        'Mirrors for exploring reflection and line symmetry',
        'Grid paper for coordinate transformations',
        'Real-world examples: art, architecture, nature patterns'
    ],
    ARRAY[
        'transformation', 'translation', 'reflection', 'rotation', 'symmetry',
        'line of symmetry', 'rotational symmetry', 'congruent', 'image', 'preimage'
    ],
    ARRAY[
        '1. Begin with concrete manipulation of shapes and objects',
        '2. Explore reflections using mirrors and folding',
        '3. Investigate rotations and translations with hands-on activities',
        '4. Identify symmetry in various figures and contexts',
        '5. Apply transformation concepts to art and design projects'
    ],
    ARRAY[
        'Below grade level: Simple reflections and basic symmetry identification',
        'On grade level: Multiple transformations and symmetry analysis',
        'Above grade level: Coordinate transformations and complex symmetries',
        'ELL students: Use visual demonstrations and concrete materials'
    ],
    ARRAY[
        'Have students predict transformation results before performing them',
        'Ask students to find symmetry in their environment',
        'Use "What happened to the shape?" after transformations',
        'Connect transformations to art, dance, and cultural patterns'
    ],
    ARRAY[
        'Transformation art projects and pattern creation',
        'Symmetry hunts in nature and architecture',
        'Mirror and folding activities for symmetry exploration',
        'Error analysis with transformation misconceptions'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Confusing Transformations',
            'student_error', 'Calling a translation a "rotation" or vice versa',
            'why_it_happens', 'Students don''t understand the specific nature of each transformation',
            'intervention', 'Use hands-on activities to show slide, flip, and turn movements',
            'prevention', 'Connect transformations to familiar movements: slide, flip, turn'
        ),
        jsonb_build_object(
            'type', 'Symmetry Line Placement',
            'student_error', 'Drawing lines of symmetry that don''t actually divide figure into matching halves',
            'why_it_happens', 'Students don''t test their symmetry lines by folding or reflection',
            'intervention', 'Use folding and mirrors to verify symmetry lines',
            'prevention', 'Always test symmetry lines with concrete verification methods'
        )
    ],
    ARRAY[
        'How many lines of symmetry does a square have?',
        'If you slide a triangle 3 units right, what transformation is this?',
        'What does a shape look like after a 90-degree rotation?',
        'Which letters of the alphabet have line symmetry?'
    ],
    ARRAY[
        'Use concrete materials and hands-on activities',
        'Connect transformations to real-world movements and patterns',
        'Always verify symmetry with folding or mirror tests',
        'Build understanding through art and design applications'
    ]
);

-- ============================================
-- VERIFICATION QUERY FOR DOMAIN 3
-- ============================================
SELECT 
    'Domain 3 Complete!' as status,
    COUNT(*) as concepts_built
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' AND d.name = 'Geometry, Measurement, and Spatial Reasoning';
