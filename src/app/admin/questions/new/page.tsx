'use client';

import { useAuth } from '../../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';

interface QuestionFormData {
  question_text: string;
  certification_id: string;
  domain: string;
  concept: string;
  difficulty_level: 'foundation' | 'application' | 'advanced';
  question_type: 'multiple_choice' | 'true_false' | 'short_answer';
  options: string[];
  correct_answer: string;
  explanation: string;
  tags: string[];
}

const CERTIFICATION_OPTIONS = [
  'Math EC-6',
  'ELA EC-6', 
  'Science EC-6',
  'Social Studies EC-6',
  'EC-6 Core Subjects'
];

const MATH_DOMAINS = [
  'Number Concepts',
  'Patterns and Algebra',
  'Geometry and Measurement',
  'Probability and Statistics',
  'Mathematical Processes'
];

const DIFFICULTY_LEVELS = [
  { value: 'foundation', label: 'Foundation', description: 'Basic concepts and definitions' },
  { value: 'application', label: 'Application', description: 'Applying concepts to solve problems' },
  { value: 'advanced', label: 'Advanced', description: 'Complex analysis and synthesis' }
];

export default function NewQuestionPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState<QuestionFormData>({
    question_text: '',
    certification_id: 'Math EC-6',
    domain: '',
    concept: '',
    difficulty_level: 'foundation',
    question_type: 'multiple_choice',
    options: ['', '', '', ''],
    correct_answer: '',
    explanation: '',
    tags: []
  });

  const isAdmin = user?.email === 'admin@certbloom.com' || user?.email?.includes('@luminanova.com');

  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    } else if (!loading && user && !isAdmin) {
      router.push('/dashboard');
    }
  }, [user, loading, isAdmin, router]);

  const handleInputChange = (field: keyof QuestionFormData, value: string | string[]) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleOptionChange = (index: number, value: string) => {
    const newOptions = [...formData.options];
    newOptions[index] = value;
    setFormData(prev => ({
      ...prev,
      options: newOptions
    }));
  };

  const addOption = () => {
    if (formData.options.length < 6) {
      setFormData(prev => ({
        ...prev,
        options: [...prev.options, '']
      }));
    }
  };

  const removeOption = (index: number) => {
    if (formData.options.length > 2) {
      const newOptions = formData.options.filter((_, i) => i !== index);
      setFormData(prev => ({
        ...prev,
        options: newOptions
      }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      // Validate form data
      if (!formData.question_text.trim()) {
        alert('Please enter a question');
        return;
      }

      if (formData.question_type === 'multiple_choice') {
        const filledOptions = formData.options.filter(opt => opt.trim());
        if (filledOptions.length < 2) {
          alert('Please provide at least 2 options for multiple choice questions');
          return;
        }
        if (!formData.correct_answer.trim()) {
          alert('Please specify the correct answer');
          return;
        }
      }

      if (!formData.explanation.trim()) {
        alert('Please provide an explanation');
        return;
      }

      // Prepare data for submission
      const submissionData = {
        ...formData,
        options: formData.question_type === 'multiple_choice' 
          ? formData.options.filter(opt => opt.trim())
          : [],
        tags: formData.tags.filter(tag => tag.trim())
      };

      const response = await fetch('/api/admin/questions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer admin`
        },
        body: JSON.stringify(submissionData)
      });

      if (response.ok) {
        alert('Question created successfully!');
        router.push('/admin/questions');
      } else {
        const error = await response.json();
        alert(`Failed to create question: ${error.error}`);
      }
    } catch (error) {
      console.error('Error creating question:', error);
      alert('Error creating question. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Loading question creator...</p>
        </div>
      </div>
    );
  }

  if (!user || !isAdmin) {
    return null;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-green-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/admin/questions" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">Question Creator</div>
          </Link>
          <div className="flex items-center space-x-4">
            <Link href="/admin/questions" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              ← Back to Questions
            </Link>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8 max-w-4xl">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-green-800 mb-2">Create New Question</h1>
          <p className="text-green-600">Add a new question to your adaptive learning system</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Basic Information */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg">
            <h2 className="text-xl font-semibold text-green-800 mb-6">📋 Basic Information</h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Certification</label>
                <select
                  value={formData.certification_id}
                  onChange={(e) => handleInputChange('certification_id', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                >
                  {CERTIFICATION_OPTIONS.map(cert => (
                    <option key={cert} value={cert}>{cert}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Domain</label>
                <select
                  value={formData.domain}
                  onChange={(e) => handleInputChange('domain', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                >
                  <option value="">Select Domain</option>
                  {MATH_DOMAINS.map(domain => (
                    <option key={domain} value={domain}>{domain}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Concept</label>
                <input
                  type="text"
                  value={formData.concept}
                  onChange={(e) => handleInputChange('concept', e.target.value)}
                  placeholder="e.g., Fractions, Decimals, Place Value"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Question Type</label>
                <select
                  value={formData.question_type}
                  onChange={(e) => handleInputChange('question_type', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                >
                  <option value="multiple_choice">Multiple Choice</option>
                  <option value="true_false">True/False</option>
                  <option value="short_answer">Short Answer</option>
                </select>
              </div>
            </div>

            <div className="mt-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">Difficulty Level</label>
              <div className="grid md:grid-cols-3 gap-4">
                {DIFFICULTY_LEVELS.map(level => (
                  <div
                    key={level.value}
                    className={`p-4 border rounded-lg cursor-pointer transition-all ${
                      formData.difficulty_level === level.value
                        ? 'border-green-500 bg-green-50'
                        : 'border-gray-300 hover:border-green-300'
                    }`}
                    onClick={() => handleInputChange('difficulty_level', level.value)}
                  >
                    <div className="font-medium text-gray-900">{level.label}</div>
                    <div className="text-sm text-gray-600">{level.description}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Question Content */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg">
            <h2 className="text-xl font-semibold text-green-800 mb-6">❓ Question Content</h2>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Question Text</label>
              <textarea
                value={formData.question_text}
                onChange={(e) => handleInputChange('question_text', e.target.value)}
                placeholder="Enter your question here..."
                rows={4}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                required
              />
            </div>

            {/* Options for Multiple Choice */}
            {formData.question_type === 'multiple_choice' && (
              <div className="mt-6">
                <div className="flex justify-between items-center mb-4">
                  <label className="block text-sm font-medium text-gray-700">Answer Options</label>
                  <button
                    type="button"
                    onClick={addOption}
                    disabled={formData.options.length >= 6}
                    className="px-3 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Add Option
                  </button>
                </div>
                
                <div className="space-y-3">
                  {formData.options.map((option, index) => (
                    <div key={index} className="flex gap-3">
                      <span className="flex-shrink-0 w-6 h-6 bg-gray-100 rounded-full flex items-center justify-center text-sm font-medium text-gray-600">
                        {String.fromCharCode(65 + index)}
                      </span>
                      <input
                        type="text"
                        value={option}
                        onChange={(e) => handleOptionChange(index, e.target.value)}
                        placeholder={`Option ${String.fromCharCode(65 + index)}`}
                        className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                      />
                      {formData.options.length > 2 && (
                        <button
                          type="button"
                          onClick={() => removeOption(index)}
                          className="text-red-600 hover:text-red-800 px-2"
                        >
                          ✕
                        </button>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Correct Answer */}
            <div className="mt-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">Correct Answer</label>
              {formData.question_type === 'multiple_choice' ? (
                <select
                  value={formData.correct_answer}
                  onChange={(e) => handleInputChange('correct_answer', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                >
                  <option value="">Select the correct answer</option>
                  {formData.options.map((option, index) => (
                    option.trim() && (
                      <option key={index} value={option}>
                        {String.fromCharCode(65 + index)}: {option}
                      </option>
                    )
                  ))}
                </select>
              ) : formData.question_type === 'true_false' ? (
                <select
                  value={formData.correct_answer}
                  onChange={(e) => handleInputChange('correct_answer', e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                >
                  <option value="">Select the correct answer</option>
                  <option value="True">True</option>
                  <option value="False">False</option>
                </select>
              ) : (
                <input
                  type="text"
                  value={formData.correct_answer}
                  onChange={(e) => handleInputChange('correct_answer', e.target.value)}
                  placeholder="Enter the correct answer"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  required
                />
              )}
            </div>

            {/* Explanation */}
            <div className="mt-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">Explanation</label>
              <textarea
                value={formData.explanation}
                onChange={(e) => handleInputChange('explanation', e.target.value)}
                placeholder="Explain why this answer is correct and provide learning context..."
                rows={4}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                required
              />
            </div>
          </div>

          {/* Submit Actions */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg">
            <div className="flex justify-between items-center">
              <Link
                href="/admin/questions"
                className="px-6 py-3 border border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors"
              >
                Cancel
              </Link>
              <button
                type="submit"
                disabled={isSubmitting}
                className="px-8 py-3 bg-gradient-to-r from-green-600 to-blue-600 text-white rounded-xl hover:from-green-700 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSubmitting ? 'Creating Question...' : '✨ Create Question'}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
}
