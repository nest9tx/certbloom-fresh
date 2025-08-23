// Adaptive Recommendations Component
// This shows how to use existing progress data for smart suggestions

import { getUserProgress, UserProgress } from '@/lib/questionBank';

export default async function AdaptiveRecommendations({ userId }: { userId: string }) {
  const result = await getUserProgress(userId);
  
  if (!result.success || !result.progress || result.progress.length === 0) {
    return (
      <div className="bg-blue-50 p-4 rounded-lg">
        <h3 className="font-semibold text-blue-800">Start Your Adaptive Journey</h3>
        <p className="text-blue-600">Take a few practice questions to unlock personalized recommendations!</p>
      </div>
    );
  }

  // Type assertion for the progress data
  const progress = result.progress as UserProgress[];

  // Analyze progress for recommendations
  const weakAreas = progress.filter(p => p.mastery_level < 0.7);
  const strongAreas = progress.filter(p => p.mastery_level >= 0.8);
  const needsReview = progress.filter(p => p.needs_review);

  // Calculate overall readiness
  const avgMastery = progress.reduce((sum, p) => sum + p.mastery_level, 0) / progress.length;
  const readinessScore = Math.round(avgMastery * 100);

  return (
    <div className="space-y-4">
      {/* Exam Readiness Score */}
      <div className="bg-gradient-to-r from-green-50 to-blue-50 p-6 rounded-xl border">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-800">Exam Readiness</h3>
            <p className="text-gray-600">Based on your practice performance</p>
          </div>
          <div className="text-right">
            <div className="text-3xl font-bold text-green-600">{readinessScore}%</div>
            <div className="text-sm text-gray-500">
              {readinessScore >= 80 ? 'Exam Ready!' : 
               readinessScore >= 60 ? 'Almost There' : 'Keep Practicing'}
            </div>
          </div>
        </div>
      </div>

      {/* Weak Areas Alert */}
      {weakAreas.length > 0 && (
        <div className="bg-red-50 p-4 rounded-lg border border-red-200">
          <h4 className="font-semibold text-red-800 flex items-center">
            ⚠️ Focus Areas ({weakAreas.length} topics)
          </h4>
          <div className="mt-2 space-y-1">
            {weakAreas.slice(0, 3).map(area => (
              <div key={area.topic} className="flex justify-between text-sm">
                <span className="text-red-700">{area.topic}</span>
                <span className="text-red-600 font-medium">
                  {Math.round(area.mastery_level * 100)}% mastery
                </span>
              </div>
            ))}
          </div>
          <p className="text-red-600 text-sm mt-2">
            💡 Spend 60% of study time on these topics
          </p>
        </div>
      )}

      {/* Strong Areas Recognition */}
      {strongAreas.length > 0 && (
        <div className="bg-green-50 p-4 rounded-lg border border-green-200">
          <h4 className="font-semibold text-green-800 flex items-center">
            ✅ Strengths ({strongAreas.length} topics)
          </h4>
          <div className="mt-2 space-y-1">
            {strongAreas.slice(0, 3).map(area => (
              <div key={area.topic} className="flex justify-between text-sm">
                <span className="text-green-700">{area.topic}</span>
                <span className="text-green-600 font-medium">
                  {Math.round(area.mastery_level * 100)}% mastery
                </span>
              </div>
            ))}
          </div>
          <p className="text-green-600 text-sm mt-2">
            🎯 Use these for confidence building
          </p>
        </div>
      )}

      {/* Review Recommendations */}
      {needsReview.length > 0 && (
        <div className="bg-yellow-50 p-4 rounded-lg border border-yellow-200">
          <h4 className="font-semibold text-yellow-800 flex items-center">
            📚 Ready for Review ({needsReview.length} topics)
          </h4>
          <p className="text-yellow-600 text-sm mt-1">
            Perfect timing to reinforce these concepts for long-term retention
          </p>
        </div>
      )}

      {/* Smart Study Suggestions */}
      <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
        <h4 className="font-semibold text-blue-800">🧠 Today&apos;s Study Plan</h4>
        <div className="mt-2 space-y-2 text-sm">
          {weakAreas.length > 0 && (
            <div className="flex items-center">
              <span className="w-2 h-2 bg-red-400 rounded-full mr-2"></span>
              <span>Focus: {weakAreas[0].topic} (15-20 questions)</span>
            </div>
          )}
          {strongAreas.length > 0 && (
            <div className="flex items-center">
              <span className="w-2 h-2 bg-green-400 rounded-full mr-2"></span>
              <span>Confidence: {strongAreas[0].topic} (5-10 questions)</span>
            </div>
          )}
          {needsReview.length > 0 && (
            <div className="flex items-center">
              <span className="w-2 h-2 bg-yellow-400 rounded-full mr-2"></span>
              <span>Review: {needsReview[0].topic} (3-5 questions)</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
