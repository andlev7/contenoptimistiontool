export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      projects: {
        Row: {
          id: string
          user_id: string
          name: string
          keyword: string
          url: string | null
          region: string
          content: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          name: string
          keyword: string
          url?: string | null
          region?: string
          content?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          name?: string
          keyword?: string
          url?: string | null
          region?: string
          content?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      serp_data: {
        Row: {
          id: string
          project_id: string
          type: 'headers' | 'texts'
          content: string
          enabled: boolean
          position: number
          created_at: string
        }
        Insert: {
          id?: string
          project_id: string
          type: 'headers' | 'texts'
          content?: string
          enabled?: boolean
          position: number
          created_at?: string
        }
        Update: {
          id?: string
          project_id?: string
          type?: 'headers' | 'texts'
          content?: string
          enabled?: boolean
          position?: number
          created_at?: string
        }
      }
      ai_prompts: {
        Row: {
          id: string
          project_id: string
          type: 'headers' | 'writing'
          step: number
          prompt: string
          enabled: boolean
          created_at: string
        }
        Insert: {
          id?: string
          project_id: string
          type: 'headers' | 'writing'
          step?: number
          prompt: string
          enabled?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          project_id?: string
          type?: 'headers' | 'writing'
          step?: number
          prompt?: string
          enabled?: boolean
          created_at?: string
        }
      }
      ai_results: {
        Row: {
          id: string
          project_id: string
          prompt_id: string
          content: string
          created_at: string
        }
        Insert: {
          id?: string
          project_id: string
          prompt_id: string
          content: string
          created_at?: string
        }
        Update: {
          id?: string
          project_id?: string
          prompt_id?: string
          content?: string
          created_at?: string
        }
      }
    }
  }
}