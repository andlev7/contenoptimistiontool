import React from 'react';
import { useProjectData } from '../hooks/useProjectData';

interface ProjectDetailsProps {
  projectId: string;
  onBack: () => void;
  onCreateAnalysis: () => void;
}

export function ProjectDetails({ projectId, onBack, onCreateAnalysis }: ProjectDetailsProps) {
  const { loading, error } = useProjectData(projectId);

  const keywords = [
    { id: 1, name: 'Keywords 1' },
    { id: 2, name: 'Keywords 2' },
    { id: 3, name: 'Keywords 3' },
    { id: 4, name: 'Keywords 4' },
    { id: 5, name: 'Keywords 5' }
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading project details...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 p-4 rounded-lg">
        <div className="text-red-700">Error: {error.message}</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <button
          onClick={onBack}
          className="flex items-center text-gray-600 hover:text-gray-900"
        >
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Back to Projects
        </button>
      </div>

      {/* Create New Analysis Button */}
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-semibold text-gray-900">Text Analysis</h2>
          <button
            onClick={onCreateAnalysis}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
            Create New Analysis
          </button>
        </div>
      </div>

      {/* Keywords List */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Keywords Analysis</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {keywords.map((keyword) => (
            <div key={keyword.id} className="px-6 py-4 flex items-center justify-between">
              <span className="text-sm font-medium text-gray-900">{keyword.name}</span>
              <button
                className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                onClick={() => console.log(`Running analysis for ${keyword.name}`)}
              >
                Go
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}