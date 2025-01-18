import React, { useState } from 'react';
import { ProjectList } from './components/ProjectList';
import { ProjectDetails } from './components/ProjectDetails';
import { ApiTest } from './components/ApiTest';
import { ApiServices } from './components/ApiServices';

function App() {
  const [selectedProjectId, setSelectedProjectId] = useState<string | null>(null);
  const [showAnalysis, setShowAnalysis] = useState(false);
  const [showApiTest, setShowApiTest] = useState(false);
  const [showApiServices, setShowApiServices] = useState(false);

  if (showApiServices) {
    return (
      <div>
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <button
            onClick={() => setShowApiServices(false)}
            className="flex items-center text-gray-600 hover:text-gray-900"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back
          </button>
        </div>
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <ApiServices />
        </div>
      </div>
    );
  }

  if (showApiTest) {
    return (
      <div>
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <button
            onClick={() => setShowApiTest(false)}
            className="flex items-center text-gray-600 hover:text-gray-900"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back
          </button>
        </div>
        <ApiTest />
      </div>
    );
  }

  if (!selectedProjectId || !showAnalysis) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          {!selectedProjectId ? (
            <>
              <div className="flex justify-end mb-6 space-x-4">
                <button
                  onClick={() => setShowApiServices(true)}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700"
                >
                  API Services
                </button>
                <button
                  onClick={() => setShowApiTest(true)}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
                >
                  Test API
                </button>
              </div>
              <ProjectList onProjectSelect={setSelectedProjectId} />
            </>
          ) : (
            <ProjectDetails 
              projectId={selectedProjectId}
              onBack={() => setSelectedProjectId(null)}
              onCreateAnalysis={() => setShowAnalysis(true)}
            />
          )}
        </div>
      </div>
    );
  }

  // Rest of your existing App component code...
  return null;
}

export default App;