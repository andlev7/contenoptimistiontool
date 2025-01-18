import { supabase } from '../lib/supabase';

interface ApiService {
  id: string;
  name: string;
  credentials: Record<string, string>;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export class ApiServicesManager {
  static async listServices(): Promise<ApiService[]> {
    const { data, error } = await supabase
      .from('api_services')
      .select('*')
      .order('name', { ascending: true });

    if (error) throw error;
    return data || [];
  }

  static async updateService(name: string, credentials: Record<string, string>): Promise<ApiService> {
    const { data, error } = await supabase
      .from('api_services')
      .upsert({
        name,
        credentials,
        is_active: true,
        updated_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new Error('Failed to update service');
    return data;
  }

  // Решта методів залишається без змін...
}