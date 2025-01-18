import { supabase } from '../lib/supabase';
import type { Database } from '../types/supabase';

type AiResult = Database['public']['Tables']['ai_results']['Row'];
type AiResultInsert = Database['public']['Tables']['ai_results']['Insert'];

export const aiResultsService = {
  async create(projectId: string, promptId: string, content: string) {
    const { data, error } = await supabase
      .from('ai_results')
      .insert([{
        project_id: projectId,
        prompt_id: promptId,
        content
      }])
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  async getByProject(projectId: string) {
    const { data, error } = await supabase
      .from('ai_results')
      .select(`
        *,
        ai_prompts (
          type,
          step,
          prompt
        )
      `)
      .eq('project_id', projectId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }
};