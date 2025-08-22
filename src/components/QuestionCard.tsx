import React from 'react';
import { Question, AnswerChoice } from '../lib/questionBankWorking';

interface QuestionCardProps {
  question: Question;
  selectedAnswer?: string;
  onAnswerSelect: (answerId: string) => void;
  showExplanation?: boolean;
  disabled?: boolean;
}

export default function QuestionCard({
  question,
  selectedAnswer,
  onAnswerSelect,
  showExplanation = false,
  disabled = false
}: QuestionCardProps) {
  if (!question.answer_choices || question.answer_choices.length === 0) {
    return (
      <div className="bg-white rounded-xl border border-red-200 p-6">
        <p className="text-red-600">Question has no answer choices</p>
      </div>
    );
  }

  const sortedChoices = question.answer_choices?.sort((a: AnswerChoice, b: AnswerChoice) => a.choice_order - b.choice_order) || [];

  return (
    <div className="bg-white rounded-xl border border-green-200 p-6 shadow-sm">
      {/* Question Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-3">
            <span className={`px-3 py-1 rounded-full text-xs font-medium ${
              question.difficulty_level === 'easy' 
                ? 'bg-green-100 text-green-700'
                : question.difficulty_level === 'medium'
                ? 'bg-yellow-100 text-yellow-700'
                : 'bg-red-100 text-red-700'
            }`}>
              {question.difficulty_level.charAt(0).toUpperCase() + question.difficulty_level.slice(1)}
            </span>
            {question.topic && (
              <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium">
                {question.topic.name}
              </span>
            )}
          </div>
          <div className="text-sm text-gray-500">
            {question.cognitive_level}
          </div>
        </div>
        
        <h3 className="text-lg font-medium text-gray-800 leading-relaxed">
          {question.question_text}
        </h3>
      </div>

      {/* Answer Choices */}
      <div className="space-y-3">
        {sortedChoices.map((choice: AnswerChoice, index: number) => {
          const choiceLetter = String.fromCharCode(65 + index); // A, B, C, D
          const isSelected = selectedAnswer === choice.id;
          const isCorrect = choice.is_correct;
          
          let choiceStyle = 'border-gray-200 hover:border-green-300 hover:bg-green-50';
          
          if (showExplanation) {
            if (isCorrect) {
              choiceStyle = 'border-green-500 bg-green-50';
            } else if (isSelected && !isCorrect) {
              choiceStyle = 'border-red-500 bg-red-50';
            } else {
              choiceStyle = 'border-gray-200';
            }
          } else if (isSelected) {
            choiceStyle = 'border-green-500 bg-green-50';
          }

          return (
            <button
              key={choice.id}
              onClick={() => !disabled && onAnswerSelect(choice.id)}
              disabled={disabled}
              className={`w-full text-left p-4 border-2 rounded-lg transition-all duration-200 ${choiceStyle} ${
                disabled ? 'cursor-not-allowed opacity-75' : 'cursor-pointer'
              }`}
            >
              <div className="flex items-start space-x-3">
                <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center text-sm font-medium ${
                  showExplanation && isCorrect
                    ? 'border-green-500 bg-green-500 text-white'
                    : showExplanation && isSelected && !isCorrect
                    ? 'border-red-500 bg-red-500 text-white'
                    : isSelected
                    ? 'border-green-500 bg-green-500 text-white'
                    : 'border-gray-300'
                }`}>
                  {showExplanation && isCorrect ? '✓' : 
                   showExplanation && isSelected && !isCorrect ? '✗' : 
                   choiceLetter}
                </div>
                <div className="flex-1">
                  <p className="text-gray-800">{choice.choice_text}</p>
                  {showExplanation && choice.explanation && (
                    <p className="text-sm text-gray-600 mt-2 italic">
                      {choice.explanation}
                    </p>
                  )}
                </div>
              </div>
            </button>
          );
        })}
      </div>

      {/* Question Explanation */}
      {showExplanation && question.explanation && (
        <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h4 className="font-medium text-blue-800 mb-2">Explanation:</h4>
          <p className="text-blue-700 text-sm leading-relaxed">
            {question.explanation}
          </p>
        </div>
      )}

      {/* Question Tags */}
      {question.tags && question.tags.length > 0 && (
        <div className="mt-4 flex flex-wrap gap-2">
          {question.tags.map((tag: string, index: number) => (
            <span
              key={index}
              className="px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs"
            >
              #{tag}
            </span>
          ))}
        </div>
      )}
    </div>
  );
}
