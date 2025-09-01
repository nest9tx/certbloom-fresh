'use client';

import { useState } from 'react';
import { useAuth } from '../../lib/auth-context';

interface CertificationOption {
  id: string;
  name: string;
  description: string;
  category: 'elementary' | 'middle' | 'high' | 'supplemental';
  testCode?: string;
}

const certificationOptions: CertificationOption[] = [
  // Elementary (EC-6) - Most popular for new teachers
  {
    id: 'Math EC-6',
    name: 'TExES Core Subjects EC-6: Mathematics (902)',
    description: 'Early Childhood through 6th Grade Mathematics',
    category: 'elementary',
    testCode: '902'
  },
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
    description: 'Early Childhood through 6th Grade Fine Arts, Health and Physical Education',
    category: 'elementary',
    testCode: '905'
  },

  // Middle School (4-8)
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
    id: 'Math 7-12',
    name: 'TExES Mathematics 7-12 (235)',
    description: '7th through 12th Grade Mathematics',
    category: 'high',
    testCode: '235'
  },
  {
    id: 'English 7-12',
    name: 'TExES English Language Arts and Reading 7-12 (231)',
    description: '7th through 12th Grade English Language Arts',
    category: 'high',
    testCode: '231'
  },

  // Supplemental - Required
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
  }
];

const categoryLabels = {
  elementary: 'Elementary (EC-6)',
  middle: 'Middle School (4-8)', 
  high: 'High School (7-12)',
  supplemental: 'Supplemental Certifications'
};

interface CertificationGoalSelectorProps {
  isOpen: boolean;
  onClose: () => void;
  currentGoal?: string | null;
  onGoalUpdated: (newGoal: string) => void;
}

export default function CertificationGoalSelector({
  isOpen,
  onClose,
  currentGoal,
  onGoalUpdated
}: CertificationGoalSelectorProps) {
  const { user } = useAuth();
  const [selectedCertification, setSelectedCertification] = useState<string | null>(currentGoal || null);
  const [activeCategory, setActiveCategory] = useState<'elementary' | 'middle' | 'high' | 'supplemental'>('elementary');
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSave = async () => {
    if (!selectedCertification || !user) return;

    setIsSaving(true);
    setError(null);

    try {
      // Get the current session to get the access token
      const { supabase } = await import('../../lib/supabase');
      const { data: { session } } = await supabase.auth.getSession();
      
      if (!session?.access_token) {
        throw new Error('No valid session found');
      }

      const response = await fetch('/api/update-certification-goal', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${session.access_token}`
        },
        body: JSON.stringify({
          certificationGoal: selectedCertification
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to update certification goal');
      }

      const result = await response.json();
      console.log('✅ Certification goal updated:', result);

      onGoalUpdated(selectedCertification);
      onClose();
    } catch (error) {
      console.error('❌ Error updating certification goal:', error);
      setError(error instanceof Error ? error.message : 'Failed to update certification goal');
    } finally {
      setIsSaving(false);
    }
  };

  const categorizedOptions = certificationOptions.reduce((acc, option) => {
    if (!acc[option.category]) {
      acc[option.category] = [];
    }
    acc[option.category].push(option);
    return acc;
  }, {} as Record<string, CertificationOption[]>);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-green-600 to-blue-600 text-white p-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold">Choose Your Certification Goal</h2>
              <p className="text-green-100 mt-1">Select the TExES exam you&apos;re preparing for</p>
            </div>
            <button
              onClick={onClose}
              className="text-white hover:text-gray-200 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[calc(90vh-200px)]">
          {/* Category Tabs */}
          <div className="flex flex-wrap gap-2 mb-6">
            {Object.entries(categoryLabels).map(([category, label]) => (
              <button
                key={category}
                onClick={() => setActiveCategory(category as typeof activeCategory)}
                className={`px-4 py-2 rounded-lg font-medium transition-all duration-200 ${
                  activeCategory === category
                    ? 'bg-green-600 text-white shadow-lg'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                {label}
              </button>
            ))}
          </div>

          {/* Certification Options */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
            {categorizedOptions[activeCategory]?.map((option) => (
              <div
                key={option.id}
                onClick={() => setSelectedCertification(option.id)}
                className={`p-4 rounded-xl border-2 cursor-pointer transition-all duration-200 hover:shadow-lg ${
                  selectedCertification === option.id
                    ? 'border-green-500 bg-green-50 shadow-lg'
                    : 'border-gray-200 bg-white hover:border-green-300'
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-800 mb-2">
                      {option.name}
                    </h3>
                    <p className="text-gray-600 text-sm mb-3">
                      {option.description}
                    </p>
                    {option.testCode && (
                      <div className="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-xs font-medium">
                        Test Code: {option.testCode}
                      </div>
                    )}
                  </div>
                  <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${
                    selectedCertification === option.id
                      ? 'border-green-500 bg-green-500'
                      : 'border-gray-300'
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

          {/* Error Message */}
          {error && (
            <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
              {error}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 flex items-center justify-between border-t">
          <button
            onClick={onClose}
            className="px-6 py-2 text-gray-600 hover:text-gray-800 transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={!selectedCertification || isSaving}
            className={`px-6 py-2 rounded-lg font-medium transition-all duration-200 ${
              selectedCertification && !isSaving
                ? 'bg-green-600 text-white hover:bg-green-700 shadow-lg'
                : 'bg-gray-300 text-gray-500 cursor-not-allowed'
            }`}
          >
            {isSaving ? 'Saving...' : 'Save Goal'}
          </button>
        </div>
      </div>
    </div>
  );
}
