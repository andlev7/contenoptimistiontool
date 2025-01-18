import React, { useState, useEffect } from 'react';
import { DataForSeoService } from '../services/data-for-seo';
import { supabase } from '../lib/supabase';

export function ApiTest() {
  const [credentials, setCredentials] = useState({
    login: '',
    password: ''
  });
  const [params, setParams] = useState({
    keyword: '',
    locationCode: '2840',
    languageCode: 'en',
    depth: 10
  });
  const [loading, setLoading] = useState(false);
  const [jsonResult, setJsonResult] = useState('');
  const [textResult, setTextResult] = useState('');
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadApiCredentials();
  }, []);

  const loadApiCredentials = async () => {
    try {
      const { data, error: credentialsError } = await supabase
        .from('api_services')
        .select('credentials')
        .eq('name', 'DataForSEO')
        .single();

      if (credentialsError) throw credentialsError;

      if (data?.credentials) {
        setCredentials({
          login: data.credentials.login || '',
          password: data.credentials.password || ''
        });
      }
    } catch (err) {
      console.error('Failed to load API credentials:', err);
      setError('Failed to load API credentials');
    }
  };

  const handleTest = async () => {
    try {
      setLoading(true);
      setError(null);
      setJsonResult('');
      setTextResult('');

      // Validate inputs
      if (!credentials.login || !credentials.password) {
        throw new Error('API credentials are required');
      }

      if (!params.keyword) {
        throw new Error('Keyword is required');
      }

      // Create new service instance with provided credentials
      const service = new DataForSeoService({
        login: credentials.login,
        password: credentials.password
      });

      // Make API call
      const result = await service.analyzeSERP(
        params.keyword,
        params.locationCode
      );

      // Set results
      setJsonResult(JSON.stringify(result, null, 2));
      
      // Extract text results
      const textResults = result.items.map(item => ({
        rank: item.rank_absolute,
        title: item.title,
        url: item.url,
        description: item.description,
        headers: item.headers
      }));
      
      setTextResult(JSON.stringify(textResults, null, 2));
    } catch (err) {
      console.error('API test failed:', err);
      setError(err instanceof Error ? err.message : 'API test failed');
      setJsonResult('');
      setTextResult('');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-6">DataForSEO API Test</h2>

          {/* Credentials Section */}
          <div className="space-y-4 mb-8">
            <div>
              <label htmlFor="login" className="block text-sm font-medium text-gray-700">
                API Login
              </label>
              <input
                type="text"
                id="login"
                value={credentials.login}
                readOnly
                className="mt-1 block w-full rounded-md border-gray-300 bg-gray-100 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                API Password
              </label>
              <input
                type="password"
                id="password"
                value={credentials.password}
                readOnly
                className="mt-1 block w-full rounded-md border-gray-300 bg-gray-100 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
            </div>
          </div>

          {/* Parameters Section */}
          <div className="space-y-4 mb-8">
            <div>
              <label htmlFor="keyword" className="block text-sm font-medium text-gray-700">
                Keyword
              </label>
              <input
                type="text"
                id="keyword"
                value={params.keyword}
                onChange={(e) => setParams(prev => ({ ...prev, keyword: e.target.value }))}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                required
              />
            </div>

            <div>
              <label htmlFor="locationCode" className="block text-sm font-medium text-gray-700">
                Location Code
              </label>
              <input
                type="text"
                id="locationCode"
                value={params.locationCode}
                onChange={(e) => setParams(prev => ({ ...prev, locationCode: e.target.value }))}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
            </div>

            <div>
              <label htmlFor="languageCode" className="block text-sm font-medium text-gray-700">
                Language Code
              </label>
              <input
                type="text"
                id="languageCode"
                value={params.languageCode}
                onChange={(e) => setParams(prev => ({ ...prev, languageCode: e.target.value }))}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
            </div>

            <div>
              <label htmlFor="depth" className="block text-sm font-medium text-gray-700">
                Depth
              </label>
              <input
                type="number"
                id="depth"
                value={params.depth}
                onChange={(e) => setParams(prev => ({ ...prev, depth: parseInt(e.target.value) || 10 }))}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
            </div>
          </div>

          {/* Test Button */}
          <button
            onClick={handleTest}
            disabled={loading || !credentials.login || !credentials.password || !params.keyword}
            className="w-full py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
          >
            {loading ? 'Testing...' : 'Get SERP'}
          </button>

          {/* Error Display */}
          {error && (
            <div className="mt-4 bg-red-50 p-4 rounded-md">
              <div className="text-sm text-red-700">{error}</div>
            </div>
          )}

          {/* Results Section */}
          <div className="mt-8 space-y-6">
            {(jsonResult || textResult) && (
              <>
                <div>
                  <h3 className="text-sm font-medium text-gray-700 mb-2">JSON Result</h3>
                  <pre className="bg-gray-50 p-4 rounded-lg overflow-auto max-h-96 text-sm">
                    {jsonResult || 'No results'}
                  </pre>
                </div>

                <div>
                  <h3 className="text-sm font-medium text-gray-700 mb-2">Text Result</h3>
                  <pre className="bg-gray-50 p-4 rounded-lg overflow-auto max-h-96 text-sm">
                    {textResult || 'No results'}
                  </pre>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}