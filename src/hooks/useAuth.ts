import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { User } from '@supabase/supabase-js';

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<'admin' | 'client' | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let mounted = true;

    const checkAuth = async () => {
      try {
        const { data: { session }, error: authError } = await supabase.auth.getSession();
        if (authError) throw authError;

        if (session?.user && mounted) {
          setUser(session.user);
          await fetchUserRole(session.user.id);
        }
      } catch (err) {
        console.error('Auth error:', err);
        if (mounted) {
          setError(err instanceof Error ? err : new Error('Authentication error'));
        }
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    };

    const fetchUserRole = async (userId: string) => {
      try {
        const { data: roleData, error: roleError } = await supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .maybeSingle();

        if (roleError) throw roleError;
        
        if (mounted) {
          setRole(roleData?.role as 'admin' | 'client' || 'client');
        }
      } catch (err) {
        console.error('Failed to fetch user role:', err);
        if (mounted) {
          setRole('client'); // Default to client role on error
        }
      }
    };

    checkAuth();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (session?.user && mounted) {
        setUser(session.user);
        await fetchUserRole(session.user.id);
      } else if (mounted) {
        setUser(null);
        setRole(null);
      }
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  const isAdmin = role === 'admin';

  return {
    user,
    role,
    isAdmin,
    loading,
    error
  };
}