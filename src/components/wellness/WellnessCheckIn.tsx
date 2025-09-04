import React, { useState } from 'react';

interface WellnessCheckInProps {
  onComplete: (data: WellnessData) => void;
  onSkip: () => void;
}

interface WellnessData {
  anxietyLevel: number;
  studyGoalMinutes: number;
  needsSupport: boolean;
  selectedWellnessTools: string[];
}

const WellnessCheckIn: React.FC<WellnessCheckInProps> = ({ onComplete, onSkip }) => {
  const [anxietyLevel, setAnxietyLevel] = useState(3);
  const [studyGoalMinutes, setStudyGoalMinutes] = useState(30);
  const [selectedTools, setSelectedTools] = useState<string[]>([]);
  const [currentStep, setCurrentStep] = useState(1);

  const wellnessTools = [
    { id: 'breathing', label: 'Breathing Exercise', duration: '3 min', desc: 'Calm your mind before studying' },
    { id: 'affirmation', label: 'Confidence Boost', duration: '2 min', desc: 'Positive reminders about your abilities' },
    { id: 'gentle-start', label: 'Gentle Study Pace', duration: 'Ongoing', desc: 'Take your time, no rush' },
    { id: 'break-reminders', label: 'Break Reminders', duration: 'Every 25 min', desc: 'Gentle nudges to rest' }
  ];

  const anxietyLabels = [
    'Very calm and ready',
    'Mostly calm',
    'Neutral',
    'A bit nervous',
    'Very anxious'
  ];

  const toggleTool = (toolId: string) => {
    setSelectedTools(prev => 
      prev.includes(toolId) 
        ? prev.filter(id => id !== toolId)
        : [...prev, toolId]
    );
  };

  const handleComplete = () => {
    onComplete({
      anxietyLevel,
      studyGoalMinutes,
      needsSupport: anxietyLevel >= 4 || selectedTools.length > 0,
      selectedWellnessTools: selectedTools
    });
  };

  const getEncouragementMessage = () => {
    if (anxietyLevel <= 2) return "Wonderful! You're feeling confident and ready to learn.";
    if (anxietyLevel === 3) return "You're in a good place to start learning. Trust yourself!";
    if (anxietyLevel === 4) return "It's completely normal to feel nervous. We'll take this at your pace.";
    return "Remember: You're capable of learning this. Let's start gently and build confidence together.";
  };

  if (currentStep === 1) {
    return (
      <div className="max-w-md mx-auto bg-white rounded-lg shadow-lg p-6">
        <div className="text-center mb-6">
          <div className="mx-auto mb-4 w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
            ❤️
          </div>
          <h2 className="text-xl font-semibold text-gray-900">How are you feeling today?</h2>
          <p className="text-gray-600 mt-2">
            Let&apos;s check in with yourself before we start studying. There are no wrong answers.
          </p>
        </div>
        
        <div className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-3">
              Anxiety level about studying (1 = very calm, 5 = very anxious)
            </label>
            <div className="px-3">
              <input
                type="range"
                min="1"
                max="5"
                value={anxietyLevel}
                onChange={(e) => setAnxietyLevel(parseInt(e.target.value))}
                className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
              />
              <div className="flex justify-between text-xs text-gray-500 mt-2">
                <span>Very calm</span>
                <span>Very anxious</span>
              </div>
            </div>
            <div className="mt-3 p-3 bg-blue-50 rounded-lg border border-blue-200">
              <p className="text-sm text-blue-800 font-medium">
                {anxietyLabels[anxietyLevel - 1]}
              </p>
              <p className="text-sm text-blue-600 mt-1">
                {getEncouragementMessage()}
              </p>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-3">
              How long would you like to study today? ({studyGoalMinutes} minutes)
            </label>
            <div className="px-3">
              <input
                type="range"
                min="10"
                max="120"
                step="10"
                value={studyGoalMinutes}
                onChange={(e) => setStudyGoalMinutes(parseInt(e.target.value))}
                className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
              />
              <div className="flex justify-between text-xs text-gray-500 mt-2">
                <span>10 min</span>
                <span>2 hours</span>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-6">
          <button 
            onClick={() => setCurrentStep(2)} 
            className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Continue
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto bg-white rounded-lg shadow-lg p-6">
      <div className="text-center mb-6">
        <div className="mx-auto mb-4 w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
          ✨
        </div>
        <h2 className="text-xl font-semibold text-gray-900">Choose your wellness tools</h2>
        <p className="text-gray-600 mt-2">
          Select any tools that might help you feel more confident and focused today.
        </p>
      </div>
      
      <div className="space-y-3 mb-6">
        {wellnessTools.map((tool) => {
          const isSelected = selectedTools.includes(tool.id);
          
          return (
            <button
              key={tool.id}
              onClick={() => toggleTool(tool.id)}
              className={`w-full p-3 rounded-lg border text-left transition-colors ${
                isSelected 
                  ? 'border-blue-500 bg-blue-50 text-blue-900' 
                  : 'border-gray-200 hover:border-gray-300'
              }`}
            >
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium">{tool.label}</div>
                  <div className="text-sm text-gray-500">{tool.desc}</div>
                  <div className="text-xs text-gray-400">{tool.duration}</div>
                </div>
                {isSelected && (
                  <div className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs font-medium">
                    Selected
                  </div>
                )}
              </div>
            </button>
          );
        })}
      </div>

      <div className="flex space-x-3">
        <button 
          onClick={onSkip} 
          className="flex-1 border border-gray-300 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-50 transition-colors"
        >
          Skip for now
        </button>
        <button 
          onClick={handleComplete} 
          className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition-colors"
        >
          Start studying
        </button>
      </div>
    </div>
  );
};

export default WellnessCheckIn;
