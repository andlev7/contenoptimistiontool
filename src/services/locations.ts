import { supabase } from '../lib/supabase';

export interface Location {
  location_code: number;
  location_name: string;
  location_code_parent: number | null;
  country_iso_code: string;
  location_type: string;
  available_sources: string[];
  language_name: string;
  language_code: string;
  keywords: number;
  serps: number;
  created_at: string;
}

export class LocationsService {
  static async listLocations(): Promise<Location[]> {
    try {
      const { data, error } = await supabase
        .from('locations')
        .select('*')
        .order('location_name', { ascending: true });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Failed to list locations:', error);
      throw error;
    }
  }

  static async getLocationsByCountry(countryIsoCode: string): Promise<Location[]> {
    try {
      const { data, error } = await supabase
        .from('locations')
        .select('*')
        .eq('country_iso_code', countryIsoCode)
        .order('language_name', { ascending: true });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error(`Failed to get locations for country ${countryIsoCode}:`, error);
      throw error;
    }
  }

  static async getLocationsByLanguage(languageCode: string): Promise<Location[]> {
    try {
      const { data, error } = await supabase
        .from('locations')
        .select('*')
        .eq('language_code', languageCode)
        .order('location_name', { ascending: true });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error(`Failed to get locations for language ${languageCode}:`, error);
      throw error;
    }
  }

  static async getLocationByCode(locationCode: number): Promise<Location | null> {
    try {
      const { data, error } = await supabase
        .from('locations')
        .select('*')
        .eq('location_code', locationCode)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error(`Failed to get location ${locationCode}:`, error);
      throw error;
    }
  }

  static async searchLocations(query: string): Promise<Location[]> {
    try {
      const { data, error } = await supabase
        .from('locations')
        .select('*')
        .or(`location_name.ilike.%${query}%,country_iso_code.ilike.%${query}%`)
        .order('location_name', { ascending: true });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error(`Failed to search locations with query "${query}":`, error);
      throw error;
    }
  }
}