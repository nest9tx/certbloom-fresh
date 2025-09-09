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
    'Area and perimeter are fundamental measurement concepts that connect geometry to real-world applications. Students must understand the difference between linear and area measurement while developing formulas through conceptual understanding rather than memorization.',
    ARRAY[
        'Understanding perimeter as distance around a shape',
        'Understanding area as space covered by a shape',
        'Developing formulas through pattern recognition and reasoning',
        'Distinguishing between area and perimeter in problem contexts'
    ],
    ARRAY[
        'Grid paper and square tiles for area visualization',
        'String or tape for perimeter measurement',
        'Geoboards for constructing shapes with given measurements',
        'Real-world contexts: room dimensions, garden planning, carpeting'
    ],
    ARRAY[
        'perimeter', 'area', 'square unit', 'length', 'width',
        'formula', 'square feet', 'square meters', 'boundary', 'interior'
    ],
    ARRAY[
        '1. Begin with concrete counting of perimeter and area units',
        '2. Develop understanding through hands-on measurement',
        '3. Recognize patterns leading to formula development',
        '4. Practice applying formulas to various shapes',
        '5. Solve real-world problems involving area and perimeter'
    ],
    ARRAY[
        'Below grade level: Count units for simple rectangular shapes',
        'On grade level: Use formulas for rectangles and basic shapes',
        'Above grade level: Complex shapes and composite figures',
        'ELL students: Use visual models and hands-on measurement'
    ],
    ARRAY[
        'Have students count units before using formulas',
        'Ask students to explain the difference between area and perimeter',
        'Use "What are we measuring?" to clarify concepts',
        'Connect to real-world planning and design problems'
    ],
    ARRAY[
        'Classroom measurement projects and design challenges',
        'Grid paper activities for area and perimeter exploration',
        'Real-world problem solving: flooring, fencing, gardening',
        'Error analysis with area vs. perimeter confusions'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Confusing Area and Perimeter',
            'student_error', 'Using area formula (l × w) when problem asks for perimeter',
            'why_it_happens', 'Students memorize formulas without understanding concepts',
            'intervention', 'Use physical materials to show distance around vs. space inside',
            'prevention', 'Always start with concrete counting before introducing formulas'
        ),
        jsonb_build_object(
            'type', 'Unit Confusion',
            'student_error', 'Reporting area as "12 feet" instead of "12 square feet"',
            'why_it_happens', 'Students don''t understand square units for area',
            'intervention', 'Use grid paper to show square units vs. linear units',
            'prevention', 'Emphasize unit differences: feet vs. square feet'
        )
    ],
    ARRAY[
        'What is the perimeter of a rectangle that is 5 cm by 3 cm?',
        'How many square tiles would cover a 4 by 6 rectangle?',
        'Which has more area: a 2×8 rectangle or a 4×4 square?',
        'If you need to fence a garden, are you finding area or perimeter?'
    ],
    ARRAY[
        'Always distinguish between linear and area measurement',
        'Use concrete materials before introducing formulas',
        'Connect to real-world applications students understand',
        'Emphasize appropriate units for different measurements'
    ]
);

-- CONCEPT 12: Transformations and Symmetry
SELECT build_concept_learning_modules(
    'Transformations and Symmetry',
    'Volume and surface area extend measurement concepts to three dimensions. Students must understand volume as space inside a solid and surface area as the total area of all faces, connecting these concepts to real-world applications and problem solving.',
    ARRAY[
        'Understanding volume as the amount of space inside a 3D figure',
        'Understanding surface area as the total area of all faces',
        'Developing formulas through hands-on exploration and pattern recognition',
        'Connecting volume and surface area to real-world applications'
    ],
    ARRAY[
        'Unit cubes and building blocks for volume exploration',
        'Nets of 3D figures for surface area understanding',
        'Containers and water for volume measurement',
        'Real-world contexts: packaging, construction, cooking'
    ],
    ARRAY[
        'volume', 'surface area', 'cubic unit', 'net', 'face',
        'prism', 'pyramid', 'cylinder', 'cube', 'cubic feet', 'cubic meters'
    ],
    ARRAY[
        '1. Begin with counting unit cubes for volume',
        '2. Explore surface area using nets and unfolded shapes',
        '3. Develop understanding through building and measuring',
        '4. Connect to formulas through pattern recognition',
        '5. Apply to real-world design and packaging problems'
    ],
    ARRAY[
        'Below grade level: Count unit cubes in simple rectangular prisms',
        'On grade level: Use formulas for basic 3D shapes',
        'Above grade level: Complex solids and composite figures',
        'ELL students: Use hands-on building and concrete materials'
    ],
    ARRAY[
        'Have students build figures with unit cubes before calculating',
        'Ask students to unfold boxes to explore surface area',
        'Use "How much space inside?" vs. "How much material to cover?"',
        'Connect to packaging and construction applications'
    ],
    ARRAY[
        'Building projects with unit cubes and blocks',
        'Packaging design challenges requiring surface area',
        'Real-world volume problems: containers, rooms, pools',
        'Error analysis with 3D measurement misconceptions'
    ],
    ARRAY[
        jsonb_build_object(
            'type', 'Confusing Volume and Surface Area',
            'student_error', 'Using volume formula when asked for surface area',
            'why_it_happens', 'Students don''t distinguish between inside space and outside covering',
            'intervention', 'Use boxes and wrapping paper to show the difference',
            'prevention', 'Always clarify: "space inside" vs. "material to cover"'
        ),
        jsonb_build_object(
            'type', 'Cubic Unit Misunderstanding',
            'student_error', 'Reporting volume as "24 feet" instead of "24 cubic feet"',
            'why_it_happens', 'Students don''t understand cubic units for volume',
            'intervention', 'Use unit cubes to build understanding of cubic units',
            'prevention', 'Emphasize cubic units whenever discussing volume'
        )
    ],
    ARRAY[
        'How many unit cubes fit in a 2×3×4 rectangular prism?',
        'What is the surface area of a cube with edge length 5 cm?',
        'If you''re painting a box, are you finding volume or surface area?',
        'Which holds more: a 2×2×6 box or a 3×3×3 box?'
    ],
    ARRAY[
        'Use concrete materials to build 3D understanding',
        'Always distinguish between volume and surface area concepts',
        'Connect to real-world applications like packaging and construction',
        'Emphasize appropriate cubic and square units'
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
