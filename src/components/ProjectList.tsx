import React, { useState } from 'react';
import { useProjects } from '../hooks/useProjects';
import { Auth } from './Auth';
import type { Database } from '../types/supabase';

type Project = Database['public']['Tables']['projects']['Row'];

interface ProjectListProps {
  onProjectSelect: (projectId: string) => void;
}

export function ProjectList({ onProjectSelect }: ProjectListProps) {
  const { projects, loading, error, createProject } = useProjects();
  const [showAuth, setShowAuth] = useState(false);
  const [newProject, setNewProject] = useState({
    name: '',
    region: 'us USA'
  });
  const [isCreating, setIsCreating] = useState(false);

  const handleCreateProject = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setIsCreating(true);
      await createProject(
        newProject.name,
        '', // empty keyword
        '', // empty url
        newProject.region
      );
      setNewProject({ name: '', region: 'us USA' });
    } catch (err) {
      if (err instanceof Error && err.message === 'Please sign in to create a project') {
        setShowAuth(true);
      } else {
        console.error('Failed to create project:', err);
      }
    } finally {
      setIsCreating(false);
    }
  };

  if (showAuth) {
    return <Auth onSignIn={() => setShowAuth(false)} />;
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading projects...</div>
      </div>
    );
  }

  if (error?.message === 'Please sign in to view projects') {
    return <Auth onSignIn={() => setShowAuth(false)} />;
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
      {/* Create New Project Form */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Create New Project</h2>
        <form onSubmit={handleCreateProject} className="space-y-4">
          <div>
            <label htmlFor="name" className="block text-sm font-medium text-gray-700">
              Project Name
            </label>
            <input
              type="text"
              id="name"
              value={newProject.name}
              onChange={(e) => setNewProject(prev => ({ ...prev, name: e.target.value }))}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              required
            />
          </div>
          
          <div>
            <label htmlFor="region" className="block text-sm font-medium text-gray-700">
              Region
            </label>
            <select
              id="region"
              value={newProject.region}
              onChange={(e) => setNewProject(prev => ({ ...prev, region: e.target.value }))}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            >
              <option value="us USA">US (USA)</option>
              <option value="ua Ukraine">Ukraine (UA)</option>
            </select>
          </div>
          
          <button
            type="submit"
            disabled={isCreating}
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
          >
            {isCreating ? 'Creating...' : 'Create Project'}
          </button>
        </form>
      </div>

      {/* Projects List */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Your Projects</h2>
        </div>
        
        {projects.length === 0 ? (
          <div className="p-6 text-center text-gray-500">
            No projects yet. Create your first project above.
          </div>
        ) : (
          <ul className="divide-y divide-gray-200">
            {projects.map((project) => (
              <li key={project.id} className="hover:bg-gray-50">
                <div className="px-6 py-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="text-sm font-medium text-gray-900">{project.name}</h3>
                      <p className="text-sm text-gray-500 mt-1">Region: {project.region}</p>
                    </div>
                    <div className="flex items-center space-x-4">
                      <span className="text-xs text-gray-500">
                        {new Date(project.created_at).toLocaleDateString()}
                      </span>
                      <button
                        onClick={() => onProjectSelect(project.id)}
                        className="inline-flex items-center px-3 py-1 border border-transparent text-sm leading-4 font-medium rounded-md text-blue-700 bg-blue-100 hover:bg-blue-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                      >
                        Open
                      </button>
                    </div>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}