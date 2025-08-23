'use client';

import React, { useState } from 'react';
import { getMoodMessage } from '../lib/adaptiveLearning';

interface MoodSelectorProps {
  onMoodSelect: (mood: string) => void;
  selectedMood?: string;
  className?: string;
}

const moods = [
  { 
    id: 'calm', 
    label: 'Calm', 
    icon: '🌊', 
    description: 'Peaceful and centered, ready for steady learning',
    color: 'from-blue-100 to-blue-200 text-blue-800'
  },
  { 
    id: 'tired', 
    label: 'Tired', 
    icon: '🌙', 
    description: 'Lower energy, seeking gentle and supportive practice',
    color: 'from-purple-100 to-purple-200 text-purple-800'
  },
  { 
    id: 'anxious', 
    label: 'Anxious', 
    icon: '🕊️', 
    description: 'Feeling nervous, needing calming and encouraging guidance',
    color: 'from-amber-100 to-amber-200 text-amber-800'
  },
  { 
    id: 'focused', 
    label: 'Focused', 
    icon: '💎', 
    description: 'Sharp and concentrated, ready for deep learning challenges',
    color: 'from-indigo-100 to-indigo-200 text-indigo-800'
  },
  { 
    id: 'energized', 
    label: 'Energized', 
    icon: '⚡', 
    description: 'High energy and enthusiasm, excited to tackle new concepts',
    color: 'from-green-100 to-green-200 text-green-800'
  }
];

const MoodSelector: React.FC<MoodSelectorProps> = ({ 
  onMoodSelect, 
  selectedMood,
  className = ''
}) => {
  const [isOpen, setIsOpen] = useState(!selectedMood);

  const handleMoodSelect = (moodId: string) => {
    onMoodSelect(moodId);
    setIsOpen(false);
  };

  const selectedMoodData = moods.find(m => m.id === selectedMood);

  return (
    <div className={`w-full max-w-2xl mx-auto ${className}`}>
      {/* Selected Mood Display */}
      {selectedMood && !isOpen && (
        <div className="mb-6 p-4 rounded-xl bg-gradient-to-r from-violet-50 to-purple-50 border border-violet-200">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <span className="text-2xl">{selectedMoodData?.icon}</span>
              <div>
                <h3 className="font-medium text-violet-900">
                  Today I&apos;m feeling: {selectedMoodData?.label}
                </h3>
                <p className="text-sm text-violet-700 mt-1">
                  {getMoodMessage(selectedMood)}
                </p>
              </div>
            </div>
            <button
              onClick={() => setIsOpen(true)}
              className="text-sm text-violet-600 hover:text-violet-800 underline"
            >
              Change
            </button>
          </div>
        </div>
      )}

      {/* Mood Selection Interface */}
      {isOpen && (
        <div className="space-y-4">
          <div className="text-center mb-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              How are you feeling today?
            </h2>
            <p className="text-sm text-gray-600">
              Your energy helps us create the perfect learning experience for you
            </p>
          </div>

          <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
            {moods.map((mood) => (
              <button
                key={mood.id}
                onClick={() => handleMoodSelect(mood.id)}
                className={`
                  p-4 rounded-xl border-2 transition-all duration-200 text-left
                  bg-gradient-to-br ${mood.color}
                  hover:scale-105 hover:shadow-md
                  ${selectedMood === mood.id ? 'ring-2 ring-violet-400 ring-offset-2' : 'border-transparent'}
                `}
              >
                <div className="flex items-start space-x-3">
                  <span className="text-2xl flex-shrink-0">{mood.icon}</span>
                  <div className="min-w-0 flex-1">
                    <h3 className="font-medium text-sm mb-1">{mood.label}</h3>
                    <p className="text-xs opacity-80 leading-relaxed">
                      {mood.description}
                    </p>
                  </div>
                </div>
              </button>
            ))}
          </div>

          {selectedMood && (
            <div className="flex justify-center pt-4">
              <button
                onClick={() => setIsOpen(false)}
                className="px-6 py-2 bg-violet-600 text-white rounded-lg hover:bg-violet-700 transition-colors"
              >
                Continue with {selectedMoodData?.label}
              </button>
            </div>
          )}
        </div>
      )}

      {/* Wisdom Integration */}
      {selectedMood && !isOpen && (
        <div className="mt-4 p-3 rounded-lg bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200">
          <div className="flex items-center space-x-2">
            <span className="text-amber-600">✨</span>
            <p className="text-sm text-amber-800 italic">
              &ldquo;Learning flows naturally when we honor our inner rhythms.&rdquo;
            </p>
          </div>
        </div>
      )}
    </div>
  );
};

export default MoodSelector;
