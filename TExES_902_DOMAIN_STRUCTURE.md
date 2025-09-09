# 🎯 TExES 902 Math Domain Structure Reference
## Complete Domain & Concept Mapping for Question Creation

---

## 📋 **CERTIFICATION INFORMATION**

### **TExES Core Subjects EC-6: Mathematics (902)**
- **Test Code**: `902`
- **Full Name**: "TExES Core Subjects EC-6: Mathematics (902)"
- **Database Certification ID**: Look up via: `SELECT id FROM certifications WHERE test_code = '902'`

---

## 📊 **DOMAIN STRUCTURE** (4 Domains, 16 Concepts Total)

### **Domain 1: Number Concepts and Operations** (40% weight)
- **Database Lookup**: `SELECT id FROM domains WHERE certification_id = [902_cert_id] AND order_index = 1`

#### **Concepts:**
1. **Place Value and Number Sense**
   - Focus: Understanding digit positions, base-10 system, comparing numbers
   - Question Topics: Error analysis, misconceptions, teaching strategies
   
2. **Operations with Whole Numbers**
   - Focus: Addition, subtraction, multiplication, division algorithms and strategies
   - Question Topics: Student errors, alternative algorithms, real-world applications
   
3. **Fractions and Decimals**
   - Focus: Fraction concepts, decimal relationships, operations
   - Question Topics: Visual models, equivalent fractions, common misconceptions
   
4. **Proportional Reasoning**
   - Focus: Ratios, proportions, percentages, rate problems
   - Question Topics: Real-world applications, student reasoning patterns

### **Domain 2: Patterns, Relationships, and Algebraic Reasoning** (30% weight)
- **Database Lookup**: `SELECT id FROM domains WHERE certification_id = [902_cert_id] AND order_index = 2`

#### **Concepts:**
5. **Patterns and Sequences**
   - Focus: Numeric/geometric patterns, pattern rules, extensions
   - Question Topics: Student pattern recognition, teaching progression
   
6. **Algebraic Expressions**
   - Focus: Variables, expressions, evaluation, word problems
   - Question Topics: Translating between representations, student thinking
   
7. **Linear Equations**
   - Focus: Solving equations, balance method, inverse operations
   - Question Topics: Conceptual understanding vs. procedural knowledge
   
8. **Functions and Relationships**
   - Focus: Input/output, graphing, coordinate relationships
   - Question Topics: Multiple representations, student misconceptions

### **Domain 3: Geometry, Measurement, and Spatial Reasoning** (20% weight)
- **Database Lookup**: `SELECT id FROM domains WHERE certification_id = [902_cert_id] AND order_index = 3`

#### **Concepts:**
9. **Geometric Shapes and Properties**
   - Focus: 2D/3D shapes, attributes, classification, angle relationships
   - Question Topics: Shape recognition, property identification, spatial thinking
   
10. **Measurement and Units**
    - Focus: Length, area, volume, weight, time, standard/metric units
    - Question Topics: Unit conversion, estimation, measurement tools
    
11. **Coordinate Geometry**
    - Focus: Coordinate plane, plotting points, distance, graphing
    - Question Topics: Quadrant understanding, ordered pairs, graphing skills
    
12. **Transformations and Symmetry**
    - Focus: Slides, flips, turns, symmetry lines, congruence
    - Question Topics: Transformation identification, symmetry recognition

### **Domain 4: Data Analysis and Personal Financial Literacy** (10% weight)
- **Database Lookup**: `SELECT id FROM domains WHERE certification_id = [902_cert_id] AND order_index = 4`

#### **Concepts:**
13. **Data Collection and Organization**
    - Focus: Data gathering, organizing, displaying information
    - Question Topics: Appropriate data displays, student data interpretation
    
14. **Statistical Analysis**
    - Focus: Mean, median, mode, range, data interpretation
    - Question Topics: Student understanding of averages, data analysis skills
    
15. **Probability**
    - Focus: Likelihood, simple probability, experimental vs. theoretical
    - Question Topics: Student probability reasoning, real-world applications
    
16. **Personal Financial Literacy**
    - Focus: Money concepts, budgeting, saving, spending decisions
    - Question Topics: Real-world money problems, financial decision-making

---

## 🔍 **HOW TO GET CONCEPT IDS FOR QUESTIONS**

### **Database Query Pattern:**
```sql
-- Get concept ID for questions
SELECT c.id as concept_id, c.name, d.name as domain_name
FROM concepts c
JOIN domains d ON c.domain_id = d.id  
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' 
  AND c.name = '[CONCEPT NAME]'
LIMIT 1;
```

### **Example Queries:**
```sql
-- Place Value concept ID
SELECT c.id FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id  
WHERE cert.test_code = '902' AND c.name = 'Place Value and Number Sense';

-- Fractions concept ID  
SELECT c.id FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' AND c.name = 'Fractions and Decimals';
```

---

## 🎯 **CONCEPT ASSIGNMENT STRATEGY**

### **Question Distribution Targets:**
- **Domain 1** (Number Concepts): 180 questions (45 per concept)
- **Domain 2** (Patterns/Algebra): 135 questions (34 per concept)  
- **Domain 3** (Geometry): 90 questions (23 per concept)
- **Domain 4** (Data Analysis): 45 questions (11 per concept)

### **Per-Concept Question Mix:**
- **Easy (30%)**: Basic teaching strategies, clear misconceptions
- **Medium (50%)**: Complex scenarios, pedagogical decisions
- **Hard (20%)**: Advanced analysis, integration across concepts

---

## 💡 **READY-TO-USE CONCEPT LOOKUPS**

### **Most Common Question Targets:**
1. **Place Value and Number Sense** - Highest priority, most student errors
2. **Fractions and Decimals** - Complex concepts, many misconceptions  
3. **Operations with Whole Numbers** - Fundamental skills, algorithm understanding
4. **Patterns and Sequences** - Algebraic thinking development
5. **Geometric Shapes and Properties** - Spatial reasoning, visual concepts

### **Question Creation Priority Order:**
1. Start with **Domain 1** concepts (40% of exam weight)
2. Build comprehensive banks for **Place Value** and **Fractions** first
3. Add **Domain 2** algebraic thinking questions
4. Complete with geometry and data analysis

---

**This structure ensures questions tie to the correct concepts and serve the 391 EC-6 comprehensive exam as well!** 🌟
