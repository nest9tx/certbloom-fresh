'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';

interface CertificationOption {
  id: string;
  name: string;
  description: string;
  category: 'elementary' | 'middle' | 'high' | 'supplemental';
  testCode?: string;
}

const certificationOptions: CertificationOption[] = [
  // Elementary (EC-6)
  {
    id: 'EC-6 Core Subjects',
    name: 'TExES Core Subjects EC-6 (391)',
    description: 'Early Childhood through 6th Grade - All core subjects',
    category: 'elementary',
    testCode: '391'
  },
  {
    id: 'ELA EC-6',
    name: 'TExES Core Subjects EC-6: English Language Arts (901)',
    description: 'Early Childhood through 6th Grade English Language Arts',
    category: 'elementary',
    testCode: '901'
  },
  {
    id: 'Math EC-6',
    name: 'TExES Core Subjects EC-6: Mathematics (902)',
    description: 'Early Childhood through 6th Grade Mathematics',
    category: 'elementary',
    testCode: '902'
  },
  {
    id: 'Social Studies EC-6',
    name: 'TExES Core Subjects EC-6: Social Studies (903)',
    description: 'Early Childhood through 6th Grade Social Studies',
    category: 'elementary',
    testCode: '903'
  },
  {
    id: 'Science EC-6',
    name: 'TExES Core Subjects EC-6: Science (904)',
    description: 'Early Childhood through 6th Grade Science',
    category: 'elementary',
    testCode: '904'
  },
  {
    id: 'Fine Arts EC-6',
    name: 'TExES Core Subjects EC-6: Fine Arts, Health and PE (905)',
    description: 'Early Childhood through 6th Grade Fine Arts, Health and PE',
    category: 'elementary',
    testCode: '905'
  },

  // Middle School (4-8)
  {
    id: 'Core Subjects 4-8',
    name: 'TExES Core Subjects 4-8 (211)',
    description: '4th through 8th Grade - All core subjects',
    category: 'middle',
    testCode: '211'
  },
  {
    id: 'ELA 4-8',
    name: 'TExES 4-8: ELAR & Social Studies (113)',
    description: '4th through 8th Grade English Language Arts & Social Studies',
    category: 'middle',
    testCode: '113'
  },
  {
    id: 'Math Science 4-8',
    name: 'TExES 4-8: Mathematics & Science (114)',
    description: '4th through 8th Grade Mathematics & Science',
    category: 'middle',
    testCode: '114'
  },
  {
    id: 'Math 4-8',
    name: 'TExES 4-8: Mathematics (115)',
    description: '4th through 8th Grade Mathematics',
    category: 'middle',
    testCode: '115'
  },
  {
    id: 'Science 4-8',
    name: 'TExES 4-8: Science (116)',
    description: '4th through 8th Grade Science',
    category: 'middle',
    testCode: '116'
  },
  {
    id: 'Social Studies 4-8',
    name: 'TExES 4-8: Social Studies (118)',
    description: '4th through 8th Grade Social Studies',
    category: 'middle',
    testCode: '118'
  },

  // High School (7-12)
  {
    id: 'ELA 7-12',
    name: 'TExES 7-12: English Language Arts and Reading (331)',
    description: '7th through 12th Grade English Language Arts and Reading',
    category: 'high',
    testCode: '331'
  },
  {
    id: 'Social Studies 7-12',
    name: 'TExES 7-12: Social Studies (232)',
    description: '7th through 12th Grade Social Studies',
    category: 'high',
    testCode: '232'
  },
  {
    id: 'History 7-12',
    name: 'TExES 7-12: History (233)',
    description: '7th through 12th Grade History',
    category: 'high',
    testCode: '233'
  },
  {
    id: 'Math 7-12',
    name: 'TExES 7-12: Mathematics (235)',
    description: '7th through 12th Grade Mathematics',
    category: 'high',
    testCode: '235'
  },
  {
    id: 'Science 7-12',
    name: 'TExES 7-12: Science (236)',
    description: '7th through 12th Grade Science',
    category: 'high',
    testCode: '236'
  },
  {
    id: 'Life Science 7-12',
    name: 'TExES 7-12: Life Science (238)',
    description: '7th through 12th Grade Life Science',
    category: 'high',
    testCode: '238'
  },
  {
    id: 'Chemistry 7-12',
    name: 'TExES 7-12: Chemistry (240)',
    description: '7th through 12th Grade Chemistry',
    category: 'high',
    testCode: '240'
  },
  {
    id: 'Physics 7-12',
    name: 'TExES Physics/Mathematics 7-12 (243)',
    description: '7th through 12th Grade Physics and Mathematics',
    category: 'high',
    testCode: '243'
  },

  // Supplemental
  {
    id: 'PPR EC-12',
    name: 'TExES Pedagogy and Professional Responsibilities EC-12 (160)',
    description: 'Required for all teaching certificates',
    category: 'supplemental',
    testCode: '160'
  },
  {
    id: 'STR Supplemental',
    name: 'TExES Science of Teaching Reading (293)',
    description: 'Required for EC-6 and some 4-8 certifications',
    category: 'supplemental',
    testCode: '293'
  },
  {
    id: 'ESL Supplemental',
    name: 'TExES English as a Second Language Supplemental (154)',
    description: 'ESL supplemental certification',
    category: 'supplemental',
    testCode: '154'
  },
  {
    id: 'Special Education EC-12',
    name: 'TExES Special Education EC-12 (161)',
    description: 'Special Education certification',
    category: 'supplemental',
    testCode: '161'
  },
  {
    id: 'Bilingual Education',
    name: 'TExES Bilingual Education Supplemental (164)',
    description: 'Bilingual Education supplemental certification',
    category: 'supplemental',
    testCode: '164'
  }
];

const categoryLabels = {
  elementary: 'Elementary (EC-6)',
  middle: 'Middle School (4-8)', 
  high: 'High School (7-12)',
  supplemental: 'Supplemental Certifications'
};

export default function SelectCertificationPage() {
  const [selectedCertification, setSelectedCertification] = useState<string | null>(null);
  const [activeCategory, setActiveCategory] = useState<'elementary' | 'middle' | 'high' | 'supplemental'>('elementary');
  const router = useRouter();

  const handleCertificationSelect = (certificationId: string) => {
    setSelectedCertification(certificationId);
  };

  const handleContinue = () => {
    if (selectedCertification) {
      // Store the selected certification in localStorage temporarily
      localStorage.setItem('selectedCertification', selectedCertification);
      // Redirect to auth page with certification context
      router.push('/auth?certification=' + encodeURIComponent(selectedCertification));
    }
  };

  const categorizedOptions = certificationOptions.reduce((acc, option) => {
    if (!acc[option.category]) {
      acc[option.category] = [];
    }
    acc[option.category].push(option);
    return acc;
  }, {} as Record<string, CertificationOption[]>);

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      {/* Navigation */}
      <nav className="relative z-10 bg-white/80 backdrop-blur-md border-b border-green-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom</div>
          </Link>
          <Link href="/" className="text-green-600 hover:text-green-700 font-medium">
            ← Back to Home
          </Link>
        </div>
      </nav>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-12">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="text-center mb-12">
            <div className="text-6xl mb-6">🎯</div>
            <h1 className="text-4xl font-light text-green-800 mb-4">
              Choose Your TExES Certification Path
            </h1>
            <p className="text-xl text-green-600 mb-2">
              Select your certification goal to create your personalized adaptive study program
            </p>
            <p className="text-sm text-green-500 italic">
              Supporting your journey to pass the TExES and fund educational pods in the four corners region 🌱
            </p>
          </div>

          {/* Category Tabs */}
          <div className="flex flex-wrap justify-center gap-2 mb-8">
            {Object.entries(categoryLabels).map(([category, label]) => (
              <button
                key={category}
                onClick={() => setActiveCategory(category as typeof activeCategory)}
                className={`px-6 py-3 rounded-xl font-medium transition-all duration-200 ${
                  activeCategory === category
                    ? 'bg-green-600 text-white shadow-lg'
                    : 'bg-white/80 text-green-600 hover:bg-green-50 border border-green-200'
                }`}
              >
                {label}
              </button>
            ))}
          </div>

          {/* Certification Options */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
            {categorizedOptions[activeCategory]?.map((option) => (
              <div
                key={option.id}
                onClick={() => handleCertificationSelect(option.id)}
                className={`p-6 rounded-xl border-2 cursor-pointer transition-all duration-200 hover:shadow-lg ${
                  selectedCertification === option.id
                    ? 'border-green-500 bg-green-50 shadow-lg'
                    : 'border-green-200 bg-white/80 hover:border-green-300'
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-green-800 mb-2">
                      {option.name}
                    </h3>
                    <p className="text-green-600 text-sm mb-3">
                      {option.description}
                    </p>
                    {option.testCode && (
                      <div className="inline-flex items-center px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-xs font-medium">
                        Test Code: {option.testCode}
                      </div>
                    )}
                  </div>
                  <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${
                    selectedCertification === option.id
                      ? 'border-green-500 bg-green-500'
                      : 'border-green-300'
                  }`}>
                    {selectedCertification === option.id && (
                      <svg className="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Continue Button */}
          <div className="text-center">
            <button
              onClick={handleContinue}
              disabled={!selectedCertification}
              className={`px-8 py-4 rounded-xl font-medium text-lg transition-all duration-200 ${
                selectedCertification
                  ? 'bg-gradient-to-r from-green-600 to-green-700 text-white hover:from-green-700 hover:to-green-800 shadow-lg hover:shadow-xl transform hover:scale-105'
                  : 'bg-gray-300 text-gray-500 cursor-not-allowed'
              }`}
            >
              {selectedCertification ? '🚀 Create My Study Program' : 'Select a Certification to Continue'}
            </button>

            {selectedCertification && (
              <p className="mt-4 text-sm text-green-600">
                Ready to begin your personalized adaptive learning journey for{' '}
                <span className="font-semibold">
                  {certificationOptions.find(opt => opt.id === selectedCertification)?.name}
                </span>
                ! 🌟
              </p>
            )}
          </div>

          {/* Mission Statement */}
          <div className="mt-16 text-center">
            <div className="bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-xl p-8">
              <h3 className="text-2xl font-semibold text-green-800 mb-4">🌱 Our Mission</h3>
              <p className="text-green-600 leading-relaxed">
                Every CertBloom subscription helps fund educational pods and learning communities 
                in the four corners region and Peru. Your success becomes a catalyst for 
                transformative education that honors both traditional wisdom and innovative learning approaches.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
