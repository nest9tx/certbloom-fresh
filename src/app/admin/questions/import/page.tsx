'use client';

import { useAuth } from '../../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';

interface ImportResult {
  success: boolean;
  importedCount: number;
  errors: string[];
  skippedCount: number;
}

export default function ImportQuestionsPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [importResult, setImportResult] = useState<ImportResult | null>(null);
  const [dragActive, setDragActive] = useState(false);

  const isAdmin = user?.email === 'admin@certbloom.com' || user?.email?.includes('@luminanova.com');

  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    } else if (!loading && user && !isAdmin) {
      router.push('/dashboard');
    }
  }, [user, loading, isAdmin, router]);

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      setSelectedFile(e.dataTransfer.files[0]);
    }
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setSelectedFile(e.target.files[0]);
    }
  };

  const downloadTemplate = () => {
    const csvContent = `question_text,certification_id,domain,concept,difficulty_level,question_type,option_a,option_b,option_c,option_d,option_e,correct_answer,explanation
"What is 2 + 2?","Math EC-6","Number Concepts","Basic Addition","foundation","multiple_choice","3","4","5","6","","4","Two plus two equals four. This is a fundamental arithmetic operation that involves combining two quantities."
"If a rectangle has a length of 8 units and width of 5 units, what is its area?","Math EC-6","Geometry and Measurement","Area Calculation","application","multiple_choice","13 square units","40 square units","25 square units","35 square units","","40 square units","Area of a rectangle = length × width = 8 × 5 = 40 square units."
"True or False: The sum of angles in any triangle is 180 degrees","Math EC-6","Geometry and Measurement","Triangle Properties","foundation","true_false","","","","","","True","In Euclidean geometry, the sum of the three angles in any triangle always equals 180 degrees."
"Solve for x: 3x + 7 = 22","Math EC-6","Patterns and Algebra","Linear Equations","application","short_answer","","","","","","5","3x + 7 = 22, so 3x = 15, therefore x = 5. Subtract 7 from both sides, then divide by 3."`;

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = url;
    a.download = 'certbloom_question_template.csv';
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      alert('Please select a file first');
      return;
    }

    setIsUploading(true);
    setImportResult(null);

    try {
      const formData = new FormData();
      formData.append('file', selectedFile);

      const response = await fetch('/api/admin/questions/import', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer admin'
        },
        body: formData
      });

      const result = await response.json();
      
      if (response.ok) {
        setImportResult(result);
      } else {
        alert(`Upload failed: ${result.error}`);
      }
    } catch (error) {
      console.error('Error uploading file:', error);
      alert('Error uploading file. Please try again.');
    } finally {
      setIsUploading(false);
    }
  };

  const clearResults = () => {
    setImportResult(null);
    setSelectedFile(null);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Loading import sanctuary...</p>
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
            <div className="text-2xl font-light text-green-800 tracking-wide">Bulk Import</div>
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
          <h1 className="text-3xl font-bold text-green-800 mb-2">Bulk Question Import</h1>
          <p className="text-green-600">Upload multiple questions from CSV or Excel files</p>
        </div>

        {/* Vision Section */}
        <div className="bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl p-8 border border-blue-200/60 shadow-lg mb-8">
          <h2 className="text-xl font-semibold text-blue-800 mb-4">🎯 Question Bank Vision</h2>
          <div className="grid md:grid-cols-5 gap-4">
            <div className="text-center p-4 bg-white/70 rounded-xl">
              <div className="text-2xl mb-2">📐</div>
              <div className="font-medium text-blue-700">Math EC-6</div>
              <div className="text-sm text-blue-600">~450 questions</div>
              <div className="text-xs text-gray-500">5 domains × 90 each</div>
            </div>
            <div className="text-center p-4 bg-white/70 rounded-xl">
              <div className="text-2xl mb-2">📚</div>
              <div className="font-medium text-green-700">ELA EC-6</div>
              <div className="text-sm text-green-600">~400 questions</div>
              <div className="text-xs text-gray-500">Reading, Writing, Language</div>
            </div>
            <div className="text-center p-4 bg-white/70 rounded-xl">
              <div className="text-2xl mb-2">🔬</div>
              <div className="font-medium text-purple-700">Science EC-6</div>
              <div className="text-sm text-purple-600">~350 questions</div>
              <div className="text-xs text-gray-500">Life, Physical, Earth</div>
            </div>
            <div className="text-center p-4 bg-white/70 rounded-xl">
              <div className="text-2xl mb-2">🌍</div>
              <div className="font-medium text-orange-700">Social Studies</div>
              <div className="text-sm text-orange-600">~350 questions</div>
              <div className="text-xs text-gray-500">History, Geography, Civics</div>
            </div>
            <div className="text-center p-4 bg-white/70 rounded-xl">
              <div className="text-2xl mb-2">🎓</div>
              <div className="font-medium text-gray-700">Core Subjects</div>
              <div className="text-sm text-gray-600">~300 questions</div>
              <div className="text-xs text-gray-500">Integrated assessments</div>
            </div>
          </div>
          <div className="mt-4 text-center">
            <div className="text-lg font-semibold text-blue-800">Total Vision: ~1,850 questions</div>
            <div className="text-sm text-blue-600">Sufficient depth for adaptive learning across all certification areas</div>
          </div>
        </div>

        {/* Template Download */}
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg mb-8">
          <h2 className="text-xl font-semibold text-green-800 mb-4">📝 Download Template</h2>
          <p className="text-green-600 mb-6">
            Start with our CSV template that includes the proper format and example questions for each question type.
          </p>
          
          <div className="bg-green-50 rounded-lg p-4 mb-6">
            <h3 className="font-medium text-green-800 mb-2">Template includes:</h3>
            <ul className="text-sm text-green-700 space-y-1">
              <li>• Multiple choice question example</li>
              <li>• True/false question example</li>
              <li>• Short answer question example</li>
              <li>• All required fields and proper formatting</li>
              <li>• Domain and concept organization</li>
            </ul>
          </div>

          <button
            onClick={downloadTemplate}
            className="w-full py-3 bg-gradient-to-r from-green-600 to-blue-600 text-white rounded-xl hover:from-green-700 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-[1.02] font-medium"
          >
            📥 Download CSV Template
          </button>
        </div>

        {/* File Upload */}
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg mb-8">
          <h2 className="text-xl font-semibold text-green-800 mb-4">📤 Upload Questions</h2>
          
          {!importResult ? (
            <>
              <div
                className={`border-2 border-dashed rounded-xl p-8 text-center transition-all ${
                  dragActive 
                    ? 'border-green-500 bg-green-50' 
                    : 'border-gray-300 hover:border-green-400'
                }`}
                onDragEnter={handleDrag}
                onDragLeave={handleDrag}
                onDragOver={handleDrag}
                onDrop={handleDrop}
              >
                <div className="text-4xl mb-4">📁</div>
                <div className="text-lg font-medium text-gray-700 mb-2">
                  {selectedFile ? selectedFile.name : 'Drop your CSV file here'}
                </div>
                <div className="text-sm text-gray-500 mb-4">
                  or click to browse files
                </div>
                <input
                  type="file"
                  accept=".csv,.xlsx,.xls"
                  onChange={handleFileSelect}
                  className="hidden"
                  id="file-upload"
                />
                <label
                  htmlFor="file-upload"
                  className="inline-flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors cursor-pointer"
                >
                  Choose File
                </label>
              </div>

              {selectedFile && (
                <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="font-medium text-blue-800">{selectedFile.name}</div>
                      <div className="text-sm text-blue-600">
                        {(selectedFile.size / 1024).toFixed(1)} KB
                      </div>
                    </div>
                    <button
                      onClick={() => setSelectedFile(null)}
                      className="text-red-600 hover:text-red-800"
                    >
                      Remove
                    </button>
                  </div>
                </div>
              )}

              <div className="mt-6 flex space-x-4">
                <button
                  onClick={handleUpload}
                  disabled={!selectedFile || isUploading}
                  className="flex-1 py-3 bg-gradient-to-r from-green-600 to-blue-600 text-white rounded-xl hover:from-green-700 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-[1.02] font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isUploading ? '⏳ Uploading...' : '🚀 Upload Questions'}
                </button>
                <Link
                  href="/admin/questions"
                  className="px-6 py-3 border border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors text-center"
                >
                  Cancel
                </Link>
              </div>
            </>
          ) : (
            /* Import Results */
            <div className="space-y-6">
              <div className={`p-6 rounded-xl border-2 ${
                importResult.success 
                  ? 'border-green-200 bg-green-50' 
                  : 'border-red-200 bg-red-50'
              }`}>
                <div className="text-center mb-4">
                  <div className="text-4xl mb-2">
                    {importResult.success ? '✅' : '❌'}
                  </div>
                  <h3 className={`text-xl font-semibold ${
                    importResult.success ? 'text-green-800' : 'text-red-800'
                  }`}>
                    Import {importResult.success ? 'Completed' : 'Failed'}
                  </h3>
                </div>

                <div className="grid md:grid-cols-3 gap-4 mb-4">
                  <div className="text-center p-3 bg-white/70 rounded-lg">
                    <div className="text-2xl font-bold text-green-700">{importResult.importedCount}</div>
                    <div className="text-sm text-green-600">Imported</div>
                  </div>
                  <div className="text-center p-3 bg-white/70 rounded-lg">
                    <div className="text-2xl font-bold text-orange-700">{importResult.skippedCount}</div>
                    <div className="text-sm text-orange-600">Skipped</div>
                  </div>
                  <div className="text-center p-3 bg-white/70 rounded-lg">
                    <div className="text-2xl font-bold text-red-700">{importResult.errors.length}</div>
                    <div className="text-sm text-red-600">Errors</div>
                  </div>
                </div>

                {importResult.errors.length > 0 && (
                  <div className="bg-white/70 rounded-lg p-4">
                    <h4 className="font-medium text-red-800 mb-2">Errors:</h4>
                    <ul className="text-sm text-red-700 space-y-1 max-h-32 overflow-y-auto">
                      {importResult.errors.map((error, index) => (
                        <li key={index}>• {error}</li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>

              <div className="flex space-x-4">
                <button
                  onClick={clearResults}
                  className="flex-1 py-3 bg-gradient-to-r from-green-600 to-blue-600 text-white rounded-xl hover:from-green-700 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-[1.02] font-medium"
                >
                  Import More Questions
                </button>
                <Link
                  href="/admin/questions"
                  className="px-6 py-3 border border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors text-center"
                >
                  View Questions
                </Link>
              </div>
            </div>
          )}
        </div>

        {/* Format Guide */}
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg">
          <h2 className="text-xl font-semibold text-green-800 mb-4">📋 Format Guide</h2>
          
          <div className="space-y-4">
            <div>
              <h3 className="font-medium text-gray-800 mb-2">Required Fields:</h3>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• <strong>question_text</strong>: The main question content</li>
                <li>• <strong>certification_id</strong>: Math EC-6, ELA EC-6, Science EC-6, Social Studies EC-6, or EC-6 Core Subjects</li>
                <li>• <strong>domain</strong>: Subject area (e.g., Number Concepts, Geometry and Measurement)</li>
                <li>• <strong>concept</strong>: Specific concept being tested</li>
                <li>• <strong>difficulty_level</strong>: foundation, application, or advanced</li>
                <li>• <strong>question_type</strong>: multiple_choice, true_false, or short_answer</li>
                <li>• <strong>correct_answer</strong>: The correct answer</li>
                <li>• <strong>explanation</strong>: Detailed explanation of the correct answer</li>
              </ul>
            </div>

            <div>
              <h3 className="font-medium text-gray-800 mb-2">Optional Fields:</h3>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• <strong>option_a, option_b, option_c, option_d, option_e</strong>: Answer choices for multiple choice</li>
              </ul>
            </div>

            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
              <h3 className="font-medium text-yellow-800 mb-2">💡 Tips:</h3>
              <ul className="text-sm text-yellow-700 space-y-1">
                <li>• Use quotes around text fields that contain commas</li>
                <li>• For true/false questions, leave option fields empty</li>
                <li>• For short answer, put the answer in correct_answer field</li>
                <li>• Keep explanations detailed but concise</li>
                <li>• Use consistent domain names within each certification</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
