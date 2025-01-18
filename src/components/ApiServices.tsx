import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../hooks/useAuth';

interface ApiService {
  id: string;
  name: string;
  credentials: Record<string, string>;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export function ApiServices() {
  const { isAdmin } = useAuth();
  const [services, setServices] = useState<ApiService[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editingService, setEditingService] = useState<ApiService | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    loadServices();
  }, []);

  async function loadServices() {
    try {
      console.log('Loading services...');
      const { data, error: servicesError } = await supabase
        .from('api_services')
        .select('*')
        .order('name');

      if (servicesError) {
        console.error('Load error:', servicesError);
        throw servicesError;
      }
      
      console.log('Services loaded:', data);
      setServices(data || []);
    } catch (err) {
      console.error('Load error:', err);
      setError(err instanceof Error ? err.message : 'Failed to load services');
    } finally {
      setLoading(false);
    }
  }

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    if (!editingService?.name) return;

    try {
      setSaving(true);
      console.log('Saving service:', editingService);

      const serviceData = {
        name: editingService.name,
        credentials: {
          login: editingService.credentials.login || '',
          password: editingService.credentials.password || ''
        },
        is_active: true
      };

      console.log('Service data to save:', serviceData);

      let query = supabase.from('api_services');
      
      if (editingService.id) {
        // Оновлюємо існуючий сервіс
        query = query
          .update(serviceData)
          .eq('id', editingService.id);
      } else {
        // Створюємо новий сервіс
        query = query.insert(serviceData);
      }

      const { data, error: saveError } = await query.select().single();

      if (saveError) {
        console.error('Save error:', saveError);
        throw saveError;
      }

      console.log('Service saved successfully:', data);
      await loadServices();
      setEditingService(null);
    } catch (err) {
      console.error('Save error:', err);
      setError(err instanceof Error ? err.message : 'Failed to save');
    } finally {
      setSaving(false);
    }
  }

  if (!isAdmin) {
    return <div>Access denied</div>;
  }

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="p-4">
      <div className="flex justify-between mb-4">
        <h1 className="text-xl font-bold">API Services</h1>
        <button
          onClick={() => setEditingService({
            id: '',
            name: 'DataForSEO',
            credentials: { login: '', password: '' },
            is_active: true,
            created_at: '',
            updated_at: ''
          })}
          className="px-4 py-2 bg-blue-500 text-white rounded"
        >
          Add Service
        </button>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-100 text-red-700 rounded">
          {error}
        </div>
      )}

      <div className="space-y-4">
        {services.map(service => (
          <div key={service.id} className="p-4 border rounded">
            <div className="flex justify-between items-center">
              <div>
                <h3 className="font-medium">{service.name}</h3>
                <p className="text-sm text-gray-500">
                  Last updated: {new Date(service.updated_at).toLocaleString()}
                </p>
              </div>
              <button
                onClick={() => setEditingService(service)}
                className="px-3 py-1 bg-gray-100 rounded"
              >
                Edit
              </button>
            </div>
          </div>
        ))}
      </div>

      {editingService && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
          <form onSubmit={handleSave} className="bg-white rounded-lg p-6 max-w-md w-full">
            <h2 className="text-lg font-medium mb-4">
              {editingService.id ? 'Edit Service' : 'Add Service'}
            </h2>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Name</label>
                <input
                  type="text"
                  value={editingService.name}
                  onChange={e => setEditingService(prev => ({
                    ...prev!,
                    name: e.target.value
                  }))}
                  className="w-full p-2 border rounded"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Login</label>
                <input
                  type="text"
                  value={editingService.credentials.login || ''}
                  onChange={e => setEditingService(prev => ({
                    ...prev!,
                    credentials: {
                      ...prev!.credentials,
                      login: e.target.value
                    }
                  }))}
                  className="w-full p-2 border rounded"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Password</label>
                <input
                  type="password"
                  value={editingService.credentials.password || ''}
                  onChange={e => setEditingService(prev => ({
                    ...prev!,
                    credentials: {
                      ...prev!.credentials,
                      password: e.target.value
                    }
                  }))}
                  className="w-full p-2 border rounded"
                  required
                />
              </div>

              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => setEditingService(null)}
                  className="px-4 py-2 border rounded"
                  disabled={saving}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50"
                  disabled={saving}
                >
                  {saving ? 'Saving...' : 'Save'}
                </button>
              </div>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}