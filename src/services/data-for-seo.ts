import { supabase } from '../lib/supabase';

interface DataForSeoConfig {
  login: string;
  password: string;
}

interface SerpResult {
  keyword: string;
  location_code: string;
  items: Array<{
    type: string;
    rank_absolute: number;
    title: string;
    url: string;
    description: string;
    breadcrumb: string[];
    headers?: {
      h1?: string[];
      h2?: string[];
      h3?: string[];
      h4?: string[];
    };
    content_info?: {
      content_words: number;
      content_chars: number;
    };
  }>;
}

export class DataForSeoService {
  private config: DataForSeoConfig | null = null;
  private baseUrl = 'https://api.dataforseo.com/v3';

  constructor(config?: DataForSeoConfig) {
    if (config) {
      this.setConfig(config);
    }
  }

  setConfig(config: DataForSeoConfig) {
    if (!config.login || !config.password) {
      throw new Error('DataForSEO credentials are required');
    }
    this.config = config;
  }

  private getAuthHeaders() {
    if (!this.config) {
      throw new Error('DataForSEO service not configured. Call setConfig first.');
    }

    return {
      'Authorization': 'Basic ' + btoa(`${this.config.login}:${this.config.password}`),
      'Content-Type': 'application/json'
    };
  }

  async analyzeSERP(keyword: string, locationCode: string = '2840'): Promise<SerpResult> {
    if (!this.config) {
      throw new Error('DataForSEO service not configured. Call setConfig first.');
    }

    if (!keyword) {
      throw new Error('Keyword is required');
    }

    try {
      const response = await fetch(`${this.baseUrl}/serp/google/organic/live/advanced`, {
        method: 'POST',
        headers: this.getAuthHeaders(),
        body: JSON.stringify([{
          keyword,
          location_code: locationCode,
          language_code: "en",
          depth: 10,
          calculate_rectangles: false
        }])
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => null);
        throw new Error(
          errorData?.error?.message || 
          `HTTP error! status: ${response.status}`
        );
      }

      const data = await response.json();
      
      if (data.status_code !== 20000) {
        throw new Error(data.status_message || 'API returned an error');
      }

      if (!data.tasks?.[0]?.result?.[0]?.items?.length) {
        throw new Error('No results found');
      }

      return this.processSerpResponse(data, keyword, locationCode);
    } catch (error) {
      console.error('Failed to fetch SERP data:', error);
      throw error instanceof Error 
        ? error 
        : new Error('Failed to fetch SERP data');
    }
  }

  private processSerpResponse(data: any, keyword: string, locationCode: string): SerpResult {
    const items = data.tasks?.[0]?.result?.[0]?.items || [];
    
    return {
      keyword,
      location_code: locationCode,
      items: items.map((item: any) => ({
        type: item.type || 'unknown',
        rank_absolute: item.rank_absolute || 0,
        title: item.title || '',
        url: item.url || '',
        description: item.description || '',
        breadcrumb: item.breadcrumb || [],
        headers: item.extracted_headers || {},
        content_info: item.extracted_content?.content_info || null
      }))
    };
  }

  async saveSerpResults(projectId: string, results: SerpResult) {
    if (!this.config) {
      throw new Error('DataForSEO service not configured. Call setConfig first.');
    }

    if (!projectId) {
      throw new Error('Project ID is required');
    }

    try {
      // Save SERP results
      const { data: serpData, error: serpError } = await supabase
        .from('serp_data')
        .insert(
          results.items.map((item, index) => ({
            project_id: projectId,
            type: 'headers',
            content: JSON.stringify({
              title: item.title,
              headers: item.headers,
              url: item.url
            }),
            position: index + 1,
            enabled: true
          }))
        )
        .select();

      if (serpError) throw serpError;

      // Save content data
      const { data: contentData, error: contentError } = await supabase
        .from('serp_data')
        .insert(
          results.items.map((item, index) => ({
            project_id: projectId,
            type: 'texts',
            content: JSON.stringify({
              description: item.description,
              content_info: item.content_info,
              url: item.url
            }),
            position: index + 1,
            enabled: true
          }))
        )
        .select();

      if (contentError) throw contentError;

      return {
        serpData,
        contentData
      };
    } catch (error) {
      console.error('Failed to save SERP results:', error);
      throw error instanceof Error 
        ? error 
        : new Error('Failed to save SERP results');
    }
  }

  async getProjectSerpData(projectId: string) {
    if (!projectId) {
      throw new Error('Project ID is required');
    }

    try {
      const { data: headers, error: headersError } = await supabase
        .from('serp_data')
        .select('*')
        .eq('project_id', projectId)
        .eq('type', 'headers')
        .order('position', { ascending: true });

      if (headersError) throw headersError;

      const { data: texts, error: textsError } = await supabase
        .from('serp_data')
        .select('*')
        .eq('project_id', projectId)
        .eq('type', 'texts')
        .order('position', { ascending: true });

      if (textsError) throw textsError;

      return {
        headers: headers.map(h => ({
          ...h,
          content: JSON.parse(h.content)
        })),
        texts: texts.map(t => ({
          ...t,
          content: JSON.parse(t.content)
        }))
      };
    } catch (error) {
      console.error('Failed to get project SERP data:', error);
      throw error instanceof Error 
        ? error 
        : new Error('Failed to get project SERP data');
    }
  }
}

// Create singleton instance without initial config
export const dataForSeoService = new DataForSeoService();