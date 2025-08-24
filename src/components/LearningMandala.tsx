'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { getUserProgress, UserProgress } from '@/lib/questionBank';

interface LearningMandalaPetal {
  topic: string;
  mastery: number;
  energy: 'dormant' | 'budding' | 'blooming' | 'radiant';
  color: string;
  angle: number;
}

interface LearningMandalaProps {
  userId: string;
  certification: string;
}

export default function LearningMandala({ userId, certification }: LearningMandalaProps) {
  const [petals, setPetals] = useState<LearningMandalaPetal[]>([]);
  const [centerEnergy, setCenterEnergy] = useState(0);
  const [breathPhase, setBreathPhase] = useState(0);
  const [lastRefresh, setLastRefresh] = useState(Date.now());

  const loadLearningGarden = useCallback(async () => {
    const result = await getUserProgress(userId, certification);
    
    if (!result.success || !result.progress || result.progress.length === 0) {
      // Seed mandala - ready for growth
      setPetals([]);
      setCenterEnergy(0);
      return;
    }

    // Type assertion for the progress data
    const progressData = result.progress as UserProgress[];

    // Transform progress data into mandala petals
    const gardenPetals: LearningMandalaPetal[] = progressData.map((p, index) => {
      const mastery = p.mastery_level;
      let energy: LearningMandalaPetal['energy'];
      let color: string;

      if (mastery < 0.3) {
        energy = 'dormant';
        color = '#E5E7EB'; // Gray - seeds waiting
      } else if (mastery < 0.6) {
        energy = 'budding';
        color = '#FEF3C7'; // Soft yellow - first sprouts
      } else if (mastery < 0.85) {
        energy = 'blooming';
        color = '#D1FAE5'; // Fresh green - growing strong
      } else {
        energy = 'radiant';
        color = '#FDE68A'; // Golden - fully realized
      }

      return {
        topic: p.topic,
        mastery,
        energy,
        color,
        angle: (360 / progressData.length) * index
      };
    });

    setPetals(gardenPetals);
    
    // Center energy represents overall learning vitality
    const avgMastery = progressData.reduce((sum, p) => sum + p.mastery_level, 0) / progressData.length;
    setCenterEnergy(avgMastery);
  }, [userId, certification]);

  useEffect(() => {
    loadLearningGarden();
    
    // Breathing animation - the mandala gently pulses like consciousness itself
    const breathInterval = setInterval(() => {
      setBreathPhase(prev => (prev + 1) % 100);
    }, 100);
    
    return () => clearInterval(breathInterval);
  }, [loadLearningGarden]);

  // Listen for window focus and session completion events
  useEffect(() => {
    const handleFocus = () => {
      const now = Date.now();
      if (now - lastRefresh > 10000) { // More frequent refresh (10 seconds)
        console.log('🔄 Mandala refreshing on window focus');
        setLastRefresh(now);
        loadLearningGarden();
      }
    };

    // Listen for localStorage changes (practice session completion)
    const handleStorageChange = (e: StorageEvent) => {
      if ((e.key === 'sessionCompleted' || e.key === 'lastSessionCompleted' || e.key === 'mandalaLastUpdate') && e.newValue) {
        console.log('🔄 Mandala refreshing due to session completion');
        setTimeout(() => {
          loadLearningGarden();
        }, 500);
      }
    };

    // Listen for custom events from practice session
    const handleSessionComplete = (event: CustomEvent) => {
      console.log('🔄 Mandala refreshing due to session completion event', event.detail);
      setTimeout(() => {
        loadLearningGarden();
      }, 1000);
    };

    // Listen for explicit mandala refresh events
    const handleMandalaRefresh = (event: CustomEvent) => {
      console.log('🔄 Mandala refreshing due to explicit refresh event', event.detail);
      setTimeout(() => {
        loadLearningGarden();
      }, 500);
    };

    // Check for existing session completion data on mount
    const checkExistingSession = () => {
      const lastSession = localStorage.getItem('lastSessionCompleted');
      const lastUpdate = localStorage.getItem('mandalaLastUpdate');
      
      if (lastSession || lastUpdate) {
        try {
          const sessionData = lastSession ? JSON.parse(lastSession) : null;
          console.log('🔄 Found existing session/update data on mandala mount:', { sessionData, lastUpdate });
          loadLearningGarden();
        } catch (e) {
          console.error('Error parsing session data:', e);
        }
      }
    };

    window.addEventListener('focus', handleFocus);
    window.addEventListener('storage', handleStorageChange);
    window.addEventListener('sessionCompleted', handleSessionComplete as EventListener);
    window.addEventListener('mandalaRefresh', handleMandalaRefresh as EventListener);
    
    // Check for existing data after a short delay
    setTimeout(checkExistingSession, 1000);

    return () => {
      window.removeEventListener('focus', handleFocus);
      window.removeEventListener('storage', handleStorageChange);
      window.removeEventListener('sessionCompleted', handleSessionComplete as EventListener);
      window.removeEventListener('mandalaRefresh', handleMandalaRefresh as EventListener);
    };
  }, [lastRefresh, loadLearningGarden]);

  const getBreathScale = () => {
    // Gentle breathing: inhale 1.0 -> 1.05 -> exhale 1.0
    const breath = Math.sin(breathPhase * 0.1) * 0.05 + 1;
    return breath;
  };

  const getCenterGlow = () => {
    const baseOpacity = centerEnergy * 0.6 + 0.2;
    const breathGlow = Math.sin(breathPhase * 0.08) * 0.2 + 0.8;
    return baseOpacity * breathGlow;
  };

  const getWisdomMessage = () => {
    if (petals.length === 0) return "Your learning garden awaits the first seeds of knowledge...";
    
    const radiantPetals = petals.filter(p => p.energy === 'radiant').length;
    const bloomingPetals = petals.filter(p => p.energy === 'blooming').length;
    const buddingPetals = petals.filter(p => p.energy === 'budding').length;
    
    if (radiantPetals >= petals.length * 0.8) {
      return "Your wisdom garden radiates with deep understanding. You are ready to share your light.";
    } else if (bloomingPetals >= petals.length * 0.6) {
      return "Beautiful growth unfolds in your learning garden. Each question deepens your roots.";
    } else if (buddingPetals >= petals.length * 0.4) {
      return "Seeds of understanding are sprouting. Trust the process of your growth.";
    } else {
      return "Every master was once a beginner. Your garden grows with each gentle step.";
    }
  };

  if (petals.length === 0) {
    return (
      <div className="flex flex-col items-center p-8 bg-gradient-to-br from-purple-50 to-blue-50 rounded-2xl">
        <div 
          className="w-32 h-32 rounded-full border-4 border-dashed border-purple-200 flex items-center justify-center mb-4"
          style={{ transform: `scale(${getBreathScale()})` }}
        >
          <div className="text-4xl opacity-50">🌱</div>
        </div>
        <p className="text-center text-purple-600 font-medium max-w-xs">
          {getWisdomMessage()}
        </p>
        <p className="text-sm text-purple-400 mt-2">Begin practicing to grow your learning mandala</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center p-8 bg-gradient-to-br from-purple-50 to-blue-50 rounded-2xl">
      {/* The Mandala */}
      <div className="relative w-64 h-64 mb-6">
        <svg width="256" height="256" className="absolute inset-0">
          {/* Center - The Source of Learning */}
          <circle
            cx="128"
            cy="128"
            r="24"
            fill="url(#centerGradient)"
            style={{ 
              opacity: getCenterGlow(),
              transform: `scale(${getBreathScale()})`,
              transformOrigin: '128px 128px'
            }}
          />
          
          {/* Petals - Each Domain of Knowledge */}
          {petals.map((petal) => {
            const x1 = 128 + Math.cos((petal.angle - 90) * Math.PI / 180) * 30;
            const y1 = 128 + Math.sin((petal.angle - 90) * Math.PI / 180) * 30;
            const x2 = 128 + Math.cos((petal.angle - 90) * Math.PI / 180) * 80;
            const y2 = 128 + Math.sin((petal.angle - 90) * Math.PI / 180) * 80;
            
            const petalScale = 0.8 + (petal.mastery * 0.4);
            const petalBreath = getBreathScale();
            
            return (
              <g key={petal.topic}>
                {/* Petal Path */}
                <path
                  d={`M ${x1} ${y1} Q ${x2} ${y2} ${x1} ${y1}`}
                  stroke={petal.color}
                  strokeWidth={8 * petalScale}
                  fill="none"
                  strokeLinecap="round"
                  style={{
                    filter: petal.energy === 'radiant' ? 'drop-shadow(0 0 8px rgba(251, 191, 36, 0.6))' : 'none',
                    transform: `scale(${petalBreath})`,
                    transformOrigin: '128px 128px'
                  }}
                />
                
                {/* Petal Bloom Indicator */}
                <circle
                  cx={x2}
                  cy={y2}
                  r={4 + (petal.mastery * 6)}
                  fill={petal.color}
                  style={{
                    opacity: 0.7 + (petal.mastery * 0.3),
                    transform: `scale(${petalBreath})`,
                    transformOrigin: '128px 128px'
                  }}
                />
              </g>
            );
          })}
          
          {/* Gradient Definitions */}
          <defs>
            <radialGradient id="centerGradient">
              <stop offset="0%" stopColor="#FEF3C7" />
              <stop offset="100%" stopColor="#F59E0B" />
            </radialGradient>
          </defs>
        </svg>
        
        {/* Floating Topic Labels */}
        {petals.map((petal) => {
          const labelX = 128 + Math.cos((petal.angle - 90) * Math.PI / 180) * 100;
          const labelY = 128 + Math.sin((petal.angle - 90) * Math.PI / 180) * 100;
          
          return (
            <div
              key={`label-${petal.topic}`}
              className="absolute text-xs font-medium text-gray-600 bg-white/80 px-2 py-1 rounded-lg backdrop-blur-sm border border-white/50"
              style={{
                left: `${labelX - 40}px`,
                top: `${labelY - 10}px`,
                width: '80px',
                textAlign: 'center',
                fontSize: '10px'
              }}
            >
              {petal.topic.split(' ')[0]}
              <div className="text-xs text-gray-400">
                {Math.round(petal.mastery * 100)}%
              </div>
            </div>
          );
        })}
      </div>
      
      {/* Wisdom Message */}
      <div className="text-center max-w-md">
        <p className="text-purple-700 font-medium mb-2">
          {getWisdomMessage()}
        </p>
        <div className="flex justify-center space-x-4 text-sm text-gray-500">
          <span className="flex items-center">
            <div className="w-3 h-3 bg-gray-200 rounded-full mr-1"></div>
            Dormant
          </span>
          <span className="flex items-center">
            <div className="w-3 h-3 bg-yellow-200 rounded-full mr-1"></div>
            Budding
          </span>
          <span className="flex items-center">
            <div className="w-3 h-3 bg-green-200 rounded-full mr-1"></div>
            Blooming
          </span>
          <span className="flex items-center">
            <div className="w-3 h-3 bg-yellow-300 rounded-full mr-1"></div>
            Radiant
          </span>
        </div>
      </div>
    </div>
  );
}
