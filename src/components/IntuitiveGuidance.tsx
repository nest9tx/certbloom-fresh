'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { getUserProgress, UserProgress } from '@/lib/questionBank';

interface WisdomWhisper {
  message: string;
  energy: 'gentle' | 'encouraging' | 'celebrating' | 'guiding';
  icon: string;
  timing: 'morning' | 'afternoon' | 'evening' | 'anytime';
}

interface IntuitiveGuidanceProps {
  userId: string;
  certification: string;
  sessionTime?: 'morning' | 'afternoon' | 'evening';
}

export default function IntuitiveGuidance({ 
  userId, 
  certification, 
  sessionTime
}: IntuitiveGuidanceProps) {
  const [whisper, setWhisper] = useState<WisdomWhisper | null>(null);
  const [isVisible, setIsVisible] = useState(false);

  const generateWisdomWhisper = useCallback(async () => {
    try {
      const result = await getUserProgress(userId, certification);
      
      if (!result.success || !result.progress || result.progress.length === 0) {
        setWhisper({
          message: "Every journey begins with a single step. Trust in the wisdom that emerges through practice.",
          energy: 'gentle',
          icon: '🌱',
          timing: 'anytime'
        });
        return;
      }

      // Type assertion for the progress data
      const progressData = result.progress as UserProgress[];
      const whispers = await analyzeProgressPatterns(progressData, sessionTime || 'anytime');
      const selectedWhisper = whispers[Math.floor(Math.random() * whispers.length)];
      setWhisper(selectedWhisper);
    } catch (error) {
      console.error('Error generating wisdom whisper:', error);
    }
  }, [userId, certification, sessionTime]);

  useEffect(() => {
    generateWisdomWhisper();
    
    // Gentle fade-in like dawn breaking
    const timer = setTimeout(() => setIsVisible(true), 500);
    return () => clearTimeout(timer);
  }, [generateWisdomWhisper]);

  const analyzeProgressPatterns = async (
    progress: UserProgress[], 
    timeContext: string
  ): Promise<WisdomWhisper[]> => {
    const totalQuestions = progress.reduce((sum, p) => sum + p.questions_attempted, 0);
    const avgMastery = progress.reduce((sum, p) => sum + p.mastery_level, 0) / progress.length;
    const strongAreas = progress.filter(p => p.mastery_level >= 0.8);
    const growingAreas = progress.filter(p => p.mastery_level >= 0.5 && p.mastery_level < 0.8);
    const seedAreas = progress.filter(p => p.mastery_level < 0.5);
    const streakDays = Math.max(...progress.map(p => p.streak_days || 0));

    const whispers: WisdomWhisper[] = [];

    // Celebrating Mastery
    if (strongAreas.length > 0) {
      whispers.push({
        message: `Your ${strongAreas[0].topic.toLowerCase()} understanding radiates like sunlight. This strength illuminates your entire learning journey.`,
        energy: 'celebrating',
        icon: '🌟',
        timing: 'anytime'
      });
    }

    // Growth Recognition
    if (growingAreas.length > 0) {
      whispers.push({
        message: `Like a tree putting down deeper roots, your ${growingAreas[0].topic.toLowerCase()} knowledge grows stronger with each question.`,
        energy: 'encouraging',
        icon: '🌳',
        timing: 'anytime'
      });
    }

    // Gentle Challenge
    if (seedAreas.length > 0 && avgMastery > 0.4) {
      whispers.push({
        message: `${seedAreas[0].topic} holds seeds of breakthrough. Sometimes the most challenging areas become our greatest teachers.`,
        energy: 'guiding',
        icon: '💎',
        timing: 'anytime'
      });
    }

    // Consistency Recognition
    if (streakDays >= 3) {
      whispers.push({
        message: `${streakDays} days of practice shows the rhythm of dedication. Like ocean waves, consistency shapes the shore of mastery.`,
        energy: 'celebrating',
        icon: '🌊',
        timing: 'anytime'
      });
    }

    // Time-Sensitive Insights
    if (timeContext === 'morning' && totalQuestions > 10) {
      whispers.push({
        message: "Morning light reveals new possibilities. Your mind is fresh and ready to embrace today's learning discoveries.",
        energy: 'encouraging',
        icon: '🌅',
        timing: 'morning'
      });
    }

    if (timeContext === 'afternoon' && avgMastery > 0.6) {
      whispers.push({
        message: "The afternoon sun finds you growing in wisdom. Each question deepens your understanding like roots reaching toward water.",
        energy: 'gentle',
        icon: '☀️',
        timing: 'afternoon'
      });
    }

    if (timeContext === 'evening' && totalQuestions > 0) {
      whispers.push({
        message: "Evening's quiet wisdom reflects your day's growth. Let insights settle like stars emerging in the twilight sky.",
        energy: 'gentle',
        icon: '🌙',
        timing: 'evening'
      });
    }

    // Learning Journey Insights
    if (totalQuestions >= 20 && avgMastery < 0.5) {
      whispers.push({
        message: "Every master once struggled where you struggle now. The path of learning requires patience with your own becoming.",
        energy: 'encouraging',
        icon: '🕊️',
        timing: 'anytime'
      });
    }

    if (totalQuestions >= 50) {
      whispers.push({
        message: "Fifty questions have passed through your awareness, each one a teacher. Notice how understanding emerges not through force, but through gentle persistence.",
        energy: 'celebrating',
        icon: '🦋',
        timing: 'anytime'
      });
    }

    // Pattern Recognition
    const recentReviewNeeded = progress.filter(p => p.needs_review).length;
    if (recentReviewNeeded > 0 && recentReviewNeeded < progress.length * 0.5) {
      whispers.push({
        message: "Some concepts whisper for attention. Review is not regression—it's the spiral path of deepening understanding.",
        energy: 'guiding',
        icon: '🔄',
        timing: 'anytime'
      });
    }

    // Default wisdom if no patterns match
    if (whispers.length === 0) {
      whispers.push({
        message: "In this moment of practice, you join countless teachers who have walked this path before you. Their wisdom flows through each question.",
        energy: 'gentle',
        icon: '✨',
        timing: 'anytime'
      });
    }

    return whispers;
  };

  const getEnergyStyle = (energy: WisdomWhisper['energy']) => {
    switch (energy) {
      case 'gentle':
        return 'from-blue-50 to-purple-50 border-blue-200 text-blue-800';
      case 'encouraging':
        return 'from-green-50 to-emerald-50 border-green-200 text-green-800';
      case 'celebrating':
        return 'from-yellow-50 to-amber-50 border-yellow-200 text-amber-800';
      case 'guiding':
        return 'from-purple-50 to-indigo-50 border-purple-200 text-purple-800';
      default:
        return 'from-gray-50 to-slate-50 border-gray-200 text-gray-800';
    }
  };

  if (!whisper) return null;

  return (
    <div 
      className={`
        transition-all duration-1000 transform
        ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'}
        bg-gradient-to-br ${getEnergyStyle(whisper.energy)}
        border rounded-xl p-6 max-w-md mx-auto
        backdrop-blur-sm shadow-lg
      `}
    >
      <div className="flex items-start space-x-4">
        <div className="text-3xl animate-pulse">
          {whisper.icon}
        </div>
        <div className="flex-1">
          <div className="text-sm font-medium opacity-60 mb-2">
            Wisdom Whisper
          </div>
          <p className="text-sm leading-relaxed font-medium">
            {whisper.message}
          </p>
          {whisper.timing !== 'anytime' && (
            <div className="mt-3 text-xs opacity-50 italic">
              ~ {whisper.timing} reflection
            </div>
          )}
        </div>
      </div>
      
      {/* Gentle breathing animation */}
      <div className="mt-4 h-1 bg-white/50 rounded-full overflow-hidden">
        <div 
          className="h-full bg-white/80 rounded-full transition-all duration-2000"
          style={{
            width: `${50 + Math.sin(Date.now() / 2000) * 25}%`
          }}
        />
      </div>
    </div>
  );
}
