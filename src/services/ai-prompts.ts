import { supabase } from '../lib/supabase';
import type { Database } from '../types/supabase';

type AiPrompt = Database['public']['Tables']['ai_prompts']['Row'];
type AiPromptInsert = Database['public']['Tables']['ai_prompts']['Insert'];
type AiPromptUpdate = Database['public']['Tables']['ai_prompts']['Update'];

export const aiPromptsService = {
  async create(projectId: string, type: 'headers' | 'writing', prompts: { prompt: string; step: number }[]) {
    const { data, error } = await supabase
      .from('ai_prompts')
      .insert(
        prompts.map(item => ({
          project_id: projectId,
          type,
          prompt: item.prompt,
          step: item.step
        }))
      )
      .select();

    if (error) throw error;
    return data;
  },

  async update(id: string, data: AiPromptUpdate) {
    const { data: updatedData, error } = await supabase
      .from('ai_prompts')
      .update(data)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return updatedData;
  },

  async getByProject(projectId: string) {
    const { data, error } = await supabase
      .from('ai_prompts')
      .select('*')
      .eq('project_id', projectId)
      .order('step', { ascending: true });

    if (error) throw error;
    return data;
  }
};