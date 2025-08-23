'use client';

import React, { useState } from 'react';

interface EC6SubjectSelectorProps {
  onSubjectSelect: (subjects: string[]) => void;
  selectedSubjects?: string[];
  className?: string;
}

const ec6Subjects = [
  { 
    id: 'reading_language_arts', 
    label: 'Reading & Language Arts', 
    icon: '📚', 
    description: 'Comprehension, writing, vocabulary, and literature',
    color: 'from-blue-100 to-blue-200 text-blue-800'
  },
  { 
    id: 'mathematics', 
    label: 'Mathematics', 
    icon: '🔢', 
    description: 'Number operations, algebra, geometry, and data analysis',
    color: 'from-green-100 to-green-200 text-green-800'
  },
  { 
    id: 'social_studies', 
    label: 'Social Studies', 
    icon: '🌍', 
    description: 'History, geography, economics, and civics',
    color: 'from-amber-100 to-amber-200 text-amber-800'
  },
  { 
    id: 'science', 
    label: 'Science', 
    icon: '🔬', 
    description: 'Physical, life, earth, and space sciences',
    color: 'from-purple-100 to-purple-200 text-purple-800'
  },
  { 
    id: 'fine_arts_health_pe', 
    label: 'Fine Arts, Health & PE', 
    icon: '🎨', 
    description: 'Art, music, health education, and physical education',
    color: 'from-pink-100 to-pink-200 text-pink-800'
  }
];

const EC6SubjectSelector: React.FC<EC6SubjectSelectorProps> = ({ 
  onSubjectSelect, 
  selectedSubjects = [],
  className = ''
}) => {
  const [localSelected, setLocalSelected] = useState<string[]>(selectedSubjects);

  const handleSubjectToggle = (subjectId: string) => {
    const newSelected = localSelected.includes(subjectId)
      ? localSelected.filter(id => id !== subjectId)
      : [...localSelected, subjectId];
    
    setLocalSelected(newSelected);
    onSubjectSelect(newSelected);
  };

  const selectAll = () => {
    const allSubjects = ec6Subjects.map(s => s.id);
    setLocalSelected(allSubjects);
    onSubjectSelect(allSubjects);
  };

  const clearAll = () => {
    setLocalSelected([]);
    onSubjectSelect([]);
  };

  return (
    <div className={`w-full max-w-4xl mx-auto ${className}`}>
      <div className="text-center mb-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          EC-6 Focus Areas
        </h2>
        <p className="text-sm text-gray-600 mb-4">
          Choose which subject areas you&apos;d like to focus on for your retake preparation
        </p>
        
        <div className="flex justify-center space-x-3 mb-4">
          <button
            onClick={selectAll}
            className="px-4 py-2 text-sm bg-green-100 text-green-700 rounded-lg hover:bg-green-200 transition-colors"
          >
            Select All
          </button>
          <button
            onClick={clearAll}
            className="px-4 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
          >
            Clear All
          </button>
        </div>
      </div>

      <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
        {ec6Subjects.map((subject) => (
          <button
            key={subject.id}
            onClick={() => handleSubjectToggle(subject.id)}
            className={`
              p-4 rounded-xl border-2 transition-all duration-200 text-left
              bg-gradient-to-br ${subject.color}
              hover:scale-105 hover:shadow-md
              ${localSelected.includes(subject.id) 
                ? 'ring-2 ring-green-400 ring-offset-2 border-green-300' 
                : 'border-transparent'}
            `}
          >
            <div className="flex items-start space-x-3">
              <span className="text-2xl flex-shrink-0">{subject.icon}</span>
              <div className="min-w-0 flex-1">
                <h3 className="font-medium text-sm mb-1 flex items-center">
                  {subject.label}
                  {localSelected.includes(subject.id) && (
                    <span className="ml-2 text-green-600">✓</span>
                  )}
                </h3>
                <p className="text-xs opacity-80 leading-relaxed">
                  {subject.description}
                </p>
              </div>
            </div>
          </button>
        ))}
      </div>

      {localSelected.length > 0 && (
        <div className="mt-4 p-3 rounded-lg bg-gradient-to-r from-green-50 to-blue-50 border border-green-200">
          <div className="flex items-center space-x-2">
            <span className="text-green-600">✨</span>
            <p className="text-sm text-green-800">
              <strong>{localSelected.length}</strong> subject area{localSelected.length !== 1 ? 's' : ''} selected for focused practice
            </p>
          </div>
        </div>
      )}
    </div>
  );
};

export default EC6SubjectSelector;
