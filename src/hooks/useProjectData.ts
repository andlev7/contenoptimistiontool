import { useState, useEffect } from 'react';
import { serpDataService } from '../services/serp-data';
import { aiPromptsService } from '../services/ai-prompts';
import { aiResultsService } from '../services/ai-results';
import type { Database } from '../types/supabase';

type SerpData = Database['public']['Tables']['serp_data']['Row'];
type AiPrompt = Database['public']['Tables']['ai_prompts']['Row'];
type AiResult = Database['public']['Tables']['ai_results']['Row'];

export function useProjectData(projectId: string) {
  const [serpData, setSerpData] = useState<SerpData[]>([]);
  const [aiPrompts, setAiPrompts] = useState<AiPrompt[]>([]);
  const [aiResults, setAiResults] = useState<AiResult[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (projectId) {
      loadData();
    }
  }, [projectId]);

  async function loadData() {
    try {
      setLoading(true);
      const [serpResults, promptResults, resultResults] = await Promise.all([
        serpDataService.getByProject(projectId),
        aiPromptsService.getByProject(projectId),
        aiResultsService.getByProject(projectId)
      ]);

      setSerpData(serpResults);
      setAiPrompts(promptResults);
      setAiResults(resultResults);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to load project data'));
    } finally {
      setLoading(false);
    }
  }

  async function saveSerpData(type: 'headers' | 'texts', items: { content: string; position: number }[]) {
    try {
      const data = await serpDataService.create(projectId, type, items);
      setSerpData(prev => [...prev, ...data]);
      return data;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to save SERP data');
    }
  }

  async function saveAiPrompts(type: 'headers' | 'writing', prompts: { prompt: string; step: number }[]) {
    try {
      const data = await aiPromptsService.create(projectId, type, prompts);
      setAiPrompts(prev => [...prev, ...data]);
      return data;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to save AI prompts');
    }
  }

  async function saveAiResult(promptId: string, content: string) {
    try {
      const data = await aiResultsService.create(projectId, promptId, content);
      setAiResults(prev => [data, ...prev]);
      return data;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to save AI result');
    }
  }

  return {
    serpData,
    aiPrompts,
    aiResults,
    loading,
    error,
    saveSerpData,
    saveAiPrompts,
    saveAiResult,
    refresh: loadData
  };
}