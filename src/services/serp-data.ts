import { supabase } from '../lib/supabase';
import type { Database } from '../types/supabase';

type SerpData = Database['public']['Tables']['serp_data']['Row'];
type SerpDataInsert = Database['public']['Tables']['serp_data']['Insert'];
type SerpDataUpdate = Database['public']['Tables']['serp_data']['Update'];

export const serpDataService = {
  async create(projectId: string, type: 'headers' | 'texts', items: { content: string; position: number }[]) {
    const { data, error } = await supabase
      .from('serp_data')
      .insert(
        items.map(item => ({
          project_id: projectId,
          type,
          content: item.content,
          position: item.position
        }))
      )
      .select();

    if (error) throw error;
    return data;
  },

  async update(id: string, data: SerpDataUpdate) {
    const { data: updatedData, error } = await supabase
      .from('serp_data')
      .update(data)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return updatedData;
  },

  async getByProject(projectId: string) {
    const { data, error } = await supabase
      .from('serp_data')
      .select('*')
      .eq('project_id', projectId)
      .order('position', { ascending: true });

    if (error) throw error;
    return data;
  }
};