import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { Database } from '../types/supabase';

type Project = Database['public']['Tables']['projects']['Row'];

export function useProjects() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const checkAuthAndLoadProjects = async () => {
      try {
        setLoading(true);
        setError(null);

        // Check if user is authenticated
        const { data: { session }, error: authError } = await supabase.auth.getSession();
        if (authError) throw authError;
        
        if (!session) {
          setError(new Error('Please sign in to view projects'));
          return;
        }

        // Load projects
        const { data, error: projectsError } = await supabase
          .from('projects')
          .select('*')
          .order('created_at', { ascending: false });

        if (projectsError) throw projectsError;

        setProjects(data || []);
      } catch (err) {
        console.error('Failed to load projects:', err);
        if (err instanceof Error) {
          setError(err);
        } else {
          setError(new Error('Failed to load projects'));
        }
      } finally {
        setLoading(false);
      }
    };

    checkAuthAndLoadProjects();

    // Subscribe to auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session) {
        checkAuthAndLoadProjects();
      } else {
        setProjects([]);
        setError(new Error('Please sign in to view projects'));
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  async function createProject(name: string, keyword: string, url?: string, region: string = 'us USA') {
    try {
      setError(null);
      
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      if (sessionError) throw sessionError;
      
      if (!session) {
        throw new Error('Please sign in to create a project');
      }

      const { data, error: createError } = await supabase
        .from('projects')
        .insert([{
          name,
          keyword,
          url,
          region,
          user_id: session.user.id
        }])
        .select()
        .single();

      if (createError) throw createError;
      if (!data) throw new Error('Failed to create project');

      setProjects(prev => [data, ...prev]);
      return data;
    } catch (err) {
      console.error('Failed to create project:', err);
      throw err instanceof Error ? err : new Error('Failed to create project');
    }
  }

  async function updateProject(id: string, data: Partial<Project>) {
    try {
      setError(null);
      
      const { error: updateError } = await supabase
        .from('projects')
        .update({ ...data, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();

      if (updateError) throw updateError;

      // Refresh projects after update
      await loadProjects();
    } catch (err) {
      console.error('Failed to update project:', err);
      throw err instanceof Error ? err : new Error('Failed to update project');
    }
  }

  async function deleteProject(id: string) {
    try {
      setError(null);
      
      const { error: deleteError } = await supabase
        .from('projects')
        .delete()
        .eq('id', id);

      if (deleteError) throw deleteError;

      setProjects(prev => prev.filter(p => p.id !== id));
    } catch (err) {
      console.error('Failed to delete project:', err);
      throw err instanceof Error ? err : new Error('Failed to delete project');
    }
  }

  async function loadProjects() {
    try {
      setLoading(true);
      setError(null);
      
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      if (sessionError) throw sessionError;
      
      if (!session) {
        throw new Error('Please sign in to view projects');
      }

      const { data, error: projectsError } = await supabase
        .from('projects')
        .select('*')
        .order('created_at', { ascending: false });

      if (projectsError) throw projectsError;

      setProjects(data || []);
    } catch (err) {
      console.error('Failed to load projects:', err);
      throw err instanceof Error ? err : new Error('Failed to load projects');
    } finally {
      setLoading(false);
    }
  }

  return {
    projects,
    loading,
    error,
    createProject,
    updateProject,
    deleteProject,
    refresh: loadProjects
  };
}