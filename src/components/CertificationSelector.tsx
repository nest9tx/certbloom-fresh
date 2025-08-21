'use client';

import { useState } from 'react';

interface CertificationOption {
  id: string;
  name: string;
  description: string;
  category: 'elementary' | 'middle' | 'high' | 'supplemental';
}

const certificationOptions: CertificationOption[] = [
  {
    id: 'EC-6 Core Subjects',
    name: 'EC-6 Core Subjects',
    description: 'Early Childhood through 6th Grade - All core subjects',
    category: 'elementary'
  },
  {
    id: 'ELA 4-8',
    name: 'English Language Arts 4-8',
    description: '4th through 8th Grade English Language Arts',
    category: 'middle'
  },
  {
    id: 'Math 4-8',
    name: 'Mathematics 4-8',
    description: '4th through 8th Grade Mathematics',
    category: 'middle'
  },
  {
    id: 'Science 4-8',
    name: 'Science 4-8',
    description: '4th through 8th Grade Science',
    category: 'middle'
  },
  {
    id: 'Social Studies 4-8',
    name: 'Social Studies 4-8',
    description: '4th through 8th Grade Social Studies',
    category: 'middle'
  },
  {
    id: 'Math 7-12',
    name: 'Mathematics 7-12',
    description: '7th through 12th Grade Mathematics',
    category: 'high'
  },
  {
    id: 'English 7-12',
    name: 'English Language Arts 7-12',
    description: '7th through 12th Grade English',
    category: 'high'
  },
  {
    id: 'Science 7-12',
    name: 'Science 7-12',
    description: '7th through 12th Grade Science',
    category: 'high'
  },
  {
    id: 'Social Studies 7-12',
    name: 'Social Studies 7-12',
    description: '7th through 12th Grade Social Studies',
    category: 'high'
  },
  {
    id: 'PPR EC-12',
    name: 'Pedagogy & Professional Responsibilities',
    description: 'Required for all teaching certifications',
    category: 'supplemental'
  },
  {
    id: 'STR Supplemental',
    name: 'Science of Teaching Reading',
    description: 'Required for EC-6 and ELA certifications',
    category: 'supplemental'
  },
  {
    id: 'ESL Supplemental',
    name: 'English as a Second Language',
    description: 'Supplemental certification for ESL instruction',
    category: 'supplemental'
  },
  {
    id: 'Special Education EC-12',
    name: 'Special Education EC-12',
    description: 'Early Childhood through 12th Grade Special Education',
    category: 'supplemental'
  },
  {
    id: 'Bilingual Education Supplemental',
    name: 'Bilingual Education',
    description: 'Supplemental certification for bilingual instruction',
    category: 'supplemental'
  }
];

interface CertificationSelectorProps {
  selectedCertification?: string;
  onSelect: (certification: string) => void;
  className?: string;
}

export default function CertificationSelector({
  selectedCertification,
  onSelect,
  className = ''
}: CertificationSelectorProps) {
  const [selectedCategory, setSelectedCategory] = useState<string>('elementary');

  const categories = {
    elementary: {
      title: '🌱 Elementary',
      description: 'Early Childhood through 6th Grade'
    },
    middle: {
      title: '🌿 Middle School',
      description: '4th through 8th Grade Subjects'
    },
    high: {
      title: '🌳 High School',
      description: '7th through 12th Grade Subjects'
    },
    supplemental: {
      title: '✨ Supplemental',
      description: 'Required & Additional Certifications'
    }
  };

  const filteredOptions = certificationOptions.filter(
    option => option.category === selectedCategory
  );

  return (
    <div className={`bg-white rounded-2xl p-8 border border-green-200/60 shadow-lg ${className}`}>
      <div className="text-center mb-8">
        <h2 className="text-3xl font-light text-green-800 mb-2">Choose Your Certification Path</h2>
        <p className="text-green-600">
          Select the TExES certification you&apos;re studying for to get personalized practice questions
        </p>
      </div>

      {/* Category Tabs */}
      <div className="flex flex-wrap justify-center gap-2 mb-8">
        {Object.entries(categories).map(([key, category]) => (
          <button
            key={key}
            onClick={() => setSelectedCategory(key)}
            className={`px-4 py-2 rounded-xl transition-all duration-200 ${
              selectedCategory === key
                ? 'bg-green-600 text-white shadow-lg'
                : 'bg-green-100 text-green-700 hover:bg-green-200'
            }`}
          >
            <div className="text-sm font-medium">{category.title}</div>
            <div className="text-xs opacity-90">{category.description}</div>
          </button>
        ))}
      </div>

      {/* Certification Options */}
      <div className="space-y-3">
        {filteredOptions.map((option) => (
          <button
            key={option.id}
            onClick={() => onSelect(option.id)}
            className={`w-full p-4 text-left rounded-xl border-2 transition-all duration-200 ${
              selectedCertification === option.id
                ? 'border-green-500 bg-green-50 text-green-800'
                : 'border-green-200/60 hover:border-green-400 hover:bg-green-50 text-gray-800 hover:text-green-800'
            }`}
          >
            <div className="font-medium text-lg mb-1">{option.name}</div>
            <div className="text-sm opacity-75">{option.description}</div>
          </button>
        ))}
      </div>

      {selectedCertification && (
        <div className="mt-6 p-4 bg-blue-50 rounded-xl">
          <div className="text-center">
            <div className="text-2xl mb-2">🎯</div>
            <div className="text-green-800 font-medium">
              Selected: {certificationOptions.find(opt => opt.id === selectedCertification)?.name}
            </div>
            <div className="text-green-600 text-sm mt-1">
              Your practice sessions will be customized for this certification
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
