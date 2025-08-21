export interface Question {
  id: number;
  content: string;
  options: string[];
  correct: number;
  explanation: string;
  difficulty: 'easy' | 'medium' | 'hard';
  topic: string;
  certifications: string[];
}

export const certificationQuestions: Question[] = [
  {
    id: 1,
    content: "According to Piaget's theory of cognitive development, during which stage do children develop the ability to think logically about concrete objects?",
    options: [
      "Sensorimotor stage",
      "Preoperational stage", 
      "Concrete operational stage",
      "Formal operational stage"
    ],
    correct: 2,
    explanation: "The concrete operational stage (ages 7-11) is when children develop logical thinking about concrete objects and situations.",
    difficulty: 'medium',
    topic: 'Child Development',
    certifications: ['EC-6 Core Subjects', 'PPR EC-12', 'ELA 4-8']
  },
  {
    id: 2,
    content: "What is the most effective strategy for supporting English Language Learners in a mainstream classroom?",
    options: [
      "Speak more slowly and loudly",
      "Use visual aids and scaffolding techniques",
      "Separate them from English-speaking students",
      "Only use their native language"
    ],
    correct: 1,
    explanation: "Visual aids and scaffolding techniques help ELLs understand content while developing English proficiency.",
    difficulty: 'medium',
    topic: 'English Language Learners',
    certifications: ['EC-6 Core Subjects', 'ELA 4-8', 'English 7-12', 'ESL Supplemental', 'PPR EC-12']
  },
  {
    id: 3,
    content: "Which assessment type is most appropriate for measuring student growth over time?",
    options: [
      "Summative assessment only",
      "Formative assessment only",
      "Combination of formative and summative assessments",
      "Standardized tests only"
    ],
    correct: 2,
    explanation: "A combination allows for ongoing feedback (formative) and final evaluation (summative) to track growth.",
    difficulty: 'easy',
    topic: 'Assessment Strategies',
    certifications: ['EC-6 Core Subjects', 'ELA 4-8', 'Math 4-8', 'Science 4-8', 'Social Studies 4-8', 'PPR EC-12']
  },
  {
    id: 4,
    content: "Which of the following is the most effective strategy for helping a student who is struggling with reading comprehension?",
    options: [
      "Have the student read more difficult texts to challenge them",
      "Focus on phonics instruction exclusively",
      "Use graphic organizers and teach metacognitive strategies",
      "Reduce the amount of reading assignments"
    ],
    correct: 2,
    explanation: "Using graphic organizers and teaching metacognitive strategies helps students organize information and become aware of their thinking processes, which directly supports reading comprehension development.",
    difficulty: 'medium',
    topic: 'Reading Instruction',
    certifications: ['EC-6 Core Subjects', 'ELA 4-8', 'English 7-12', 'STR Supplemental']
  },
  {
    id: 5,
    content: "What is the primary purpose of a KWL chart in elementary education?",
    options: [
      "To assess students' final understanding of a topic",
      "To activate prior knowledge and guide learning",
      "To organize students into reading groups",
      "To track student behavior patterns"
    ],
    correct: 1,
    explanation: "A KWL chart (Know, Want to know, Learned) helps activate students' prior knowledge, generates curiosity about new learning, and provides a framework for reflecting on what was learned.",
    difficulty: 'easy',
    topic: 'Instructional Strategies',
    certifications: ['EC-6 Core Subjects', 'ELA 4-8', 'Math 4-8', 'Science 4-8', 'Social Studies 4-8']
  },
  {
    id: 6,
    content: "Which classroom management approach is most effective for building positive relationships with students?",
    options: [
      "Strict disciplinary rules with immediate consequences",
      "Allowing students complete freedom to choose their behavior",
      "Positive behavioral interventions and consistent expectations",
      "Public recognition only for academic achievements"
    ],
    correct: 2,
    explanation: "Positive behavioral interventions combined with consistent expectations create a supportive environment that builds trust, reduces behavioral issues, and promotes student engagement.",
    difficulty: 'medium',
    topic: 'Classroom Management',
    certifications: ['EC-6 Core Subjects', 'PPR EC-12', 'ELA 4-8', 'Math 4-8', 'Science 4-8', 'Social Studies 4-8']
  },
  {
    id: 7,
    content: "When teaching mathematical problem-solving, which strategy best supports student understanding?",
    options: [
      "Providing the correct formula immediately",
      "Having students memorize multiple solution methods",
      "Encouraging multiple solution pathways and student explanation",
      "Using only abstract numerical problems"
    ],
    correct: 2,
    explanation: "Encouraging multiple solution pathways and having students explain their thinking develops deeper mathematical understanding and problem-solving skills.",
    difficulty: 'medium',
    topic: 'Mathematics Instruction',
    certifications: ['EC-6 Core Subjects', 'Math 4-8', 'Math 7-12']
  },
  {
    id: 8,
    content: "Which practice best supports differentiated instruction in a diverse classroom?",
    options: [
      "Using the same teaching method for all students",
      "Providing multiple ways to access, process, and express learning",
      "Grouping students only by ability level",
      "Focusing instruction on grade-level standards only"
    ],
    correct: 1,
    explanation: "Differentiated instruction involves providing multiple ways for students to access content, process information, and express their learning, accommodating diverse learning needs and preferences.",
    difficulty: 'medium',
    topic: 'Differentiated Instruction',
    certifications: ['EC-6 Core Subjects', 'PPR EC-12', 'Special Education EC-12', 'ELA 4-8', 'Math 4-8']
  },
  {
    id: 9,
    content: "What is the most important factor in creating an inclusive classroom environment?",
    options: [
      "Having identical expectations for all students",
      "Celebrating diversity and individual strengths",
      "Focusing only on academic achievement",
      "Minimizing cultural differences"
    ],
    correct: 1,
    explanation: "Creating an inclusive environment involves celebrating diversity, recognizing individual strengths, and ensuring all students feel valued and supported in their learning journey.",
    difficulty: 'easy',
    topic: 'Inclusive Education',
    certifications: ['EC-6 Core Subjects', 'PPR EC-12', 'Special Education EC-12', 'ESL Supplemental', 'Bilingual Education Supplemental']
  },
  {
    id: 10,
    content: "Which strategy is most effective for teaching scientific inquiry to elementary students?",
    options: [
      "Lecture-based instruction with detailed notes",
      "Hands-on investigations with guided questioning",
      "Independent reading of science textbooks",
      "Memorization of scientific facts and formulas"
    ],
    correct: 1,
    explanation: "Hands-on investigations with guided questioning engage students in authentic scientific practices, develop critical thinking skills, and make abstract concepts concrete and meaningful.",
    difficulty: 'medium',
    topic: 'Science Instruction',
    certifications: ['EC-6 Core Subjects', 'Science 4-8', 'Science 7-12']
  },
  {
    id: 11,
    content: "When working with parents as educational partners, which approach is most effective?",
    options: [
      "Communicating only when problems arise",
      "Maintaining regular, positive communication and collaboration",
      "Limiting communication to formal conferences only",
      "Focusing discussions solely on academic deficits"
    ],
    correct: 1,
    explanation: "Regular, positive communication and collaboration with families builds strong partnerships that support student success both at home and school.",
    difficulty: 'easy',
    topic: 'Family Engagement',
    certifications: ['EC-6 Core Subjects', 'PPR EC-12', 'ELA 4-8', 'Math 4-8', 'Science 4-8', 'Social Studies 4-8']
  },
  {
    id: 12,
    content: "Which instructional approach best supports students with different learning styles?",
    options: [
      "Using only visual aids and materials",
      "Incorporating multiple modalities (visual, auditory, kinesthetic)",
      "Relying primarily on lecture-style teaching",
      "Using only technology-based instruction"
    ],
    correct: 1,
    explanation: "Incorporating multiple modalities ensures that instruction reaches students with different learning preferences and strengthens understanding through various pathways.",
    difficulty: 'medium',
    topic: 'Learning Styles',
    certifications: ['EC-6 Core Subjects', 'PPR EC-12', 'Special Education EC-12', 'ELA 4-8', 'Math 4-8']
  },
  {
    id: 13,
    content: "What is the primary benefit of formative assessment in education?",
    options: [
      "Assigning final grades to students",
      "Comparing students to grade-level standards",
      "Providing ongoing feedback to guide instruction",
      "Meeting state testing requirements"
    ],
    correct: 2,
    explanation: "Formative assessment provides ongoing feedback that helps teachers adjust instruction in real-time and helps students understand their progress and areas for improvement.",
    difficulty: 'medium',
    topic: 'Assessment Strategies',
    certifications: ['EC-6 Core Subjects', 'PPR EC-12', 'ELA 4-8', 'Math 4-8', 'Science 4-8', 'Social Studies 4-8']
  },
  {
    id: 14,
    content: "Which approach best supports social-emotional learning in the classroom?",
    options: [
      "Focusing only on academic content",
      "Integrating SEL into daily routines and academic lessons",
      "Addressing SEL issues only when problems occur",
      "Using SEL as a separate, isolated curriculum"
    ],
    correct: 1,
    explanation: "Integrating social-emotional learning into daily routines and academic lessons creates authentic opportunities for students to develop these crucial life skills in meaningful contexts.",
    difficulty: 'medium',
    topic: 'Social-Emotional Learning',
    certifications: ['EC-6 Core Subjects', 'PPR EC-12', 'Special Education EC-12', 'ELA 4-8', 'Math 4-8']
  },
  {
    id: 15,
    content: "When teaching reading to early learners, which component is essential for building foundational skills?",
    options: [
      "Focusing only on sight word memorization",
      "Balancing phonemic awareness, phonics, fluency, vocabulary, and comprehension",
      "Using only whole language approaches",
      "Emphasizing spelling rules exclusively"
    ],
    correct: 1,
    explanation: "Effective reading instruction includes the five essential components: phonemic awareness, phonics, fluency, vocabulary, and comprehension, working together to build strong readers.",
    difficulty: 'medium',
    topic: 'Reading Instruction',
    certifications: ['EC-6 Core Subjects', 'ELA 4-8', 'STR Supplemental']
  }
];
