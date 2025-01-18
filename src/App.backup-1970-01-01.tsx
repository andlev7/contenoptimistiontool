import React, { useState, useCallback } from 'react';
import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Link from '@tiptap/extension-link';
import Underline from '@tiptap/extension-underline';
import TextAlign from '@tiptap/extension-text-align';
import Toolbar from './components/Toolbar';
import Sidebar from './components/Sidebar';
import { ProjectList } from './components/ProjectList';
import { ProjectDetails } from './components/ProjectDetails';

interface AiPrompt {
  enabled: boolean;
  text: string;
}

interface AiPrompts {
  prompt1: AiPrompt;
  prompt2: AiPrompt;
  prompt3: AiPrompt;
}

interface SerpItem {
  enabled: boolean;
  content: string;
}

function App() {
  const [selectedProjectId, setSelectedProjectId] = useState<string | null>(null);
  const [showAnalysis, setShowAnalysis] = useState(false);
  const [wordCount, setWordCount] = useState(0);
  const [keyword, setKeyword] = useState('');
  const [url, setUrl] = useState('');
  const [region, setRegion] = useState('us USA');
  const [isLoading, setIsLoading] = useState(false);
  const [activeSerpTab, setActiveSerpTab] = useState('headers');
  const [showAllBlocks, setShowAllBlocks] = useState(false);
  const [metrics, setMetrics] = useState({
    unique: '0% ',
    h2Count: '0/0',
    h3Count: '0/0',
    h4Count: '0/0',
  });

  const [serpData, setSerpData] = useState({
    headers: Array(10).fill('').map(() => ({ enabled: true, content: '' } as SerpItem)),
    texts: Array(10).fill('').map(() => ({ enabled: true, content: '' } as SerpItem)),
    aiHeaders: '',
    aiWriting: ''
  });

  const [aiPrompts, setAiPrompts] = useState<AiPrompts>({
    prompt1: {
      enabled: true,
      text: 'Generate SEO-optimized headers for the given topic that target search intent'
    },
    prompt2: {
      enabled: true,
      text: 'Create engaging subheadings that maintain user interest and improve readability'
    },
    prompt3: {
      enabled: true,
      text: 'Develop headers that address the main search intent and related questions'
    }
  });

  const [aiWritingSteps, setAiWritingSteps] = useState([
    { enabled: true, prompt: '', result: '' },
    { enabled: true, prompt: '', result: '' },
    { enabled: true, prompt: '', result: '' }
  ]);
  
  const editor = useEditor({
    extensions: [
      StarterKit,
      Link.configure({
        openOnClick: false,
      }),
      Underline,
      TextAlign.configure({
        types: ['paragraph', 'heading'],
      }),
    ],
    content: '<p>Start writing your content here...</p>',
    onUpdate: ({ editor }) => {
      const text = editor.getText();
      const words = text.trim().split(/\s+/);
      setWordCount(words.length);
      
      const doc = editor.getJSON();
      const h2Count = doc.content?.filter(node => node.type === 'heading' && node.attrs.level === 2).length || 0;
      const h3Count = doc.content?.filter(node => node.type === 'heading' && node.attrs.level === 3).length || 0;
      const h4Count = doc.content?.filter(node => node.type === 'heading' && node.attrs.level === 4).length || 0;
      
      setMetrics({
        ...metrics,
        h2Count: `${h2Count}/6`,
        h3Count: `${h3Count}/3`,
        h4Count: `${h4Count}/3`,
      });
    },
  });

  const handleParseSERP = async () => {
    if (!keyword.trim()) return;
    
    setIsLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      setMetrics(prev => ({
        ...prev,
        unique: '0% - not checked yet',
      }));
    } catch (err) {
      console.error('Error parsing SERP:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleUpdateMetrics = () => {
    setMetrics(prev => ({
      ...prev,
      unique: '14%',
    }));
  };

  const handlePromptChange = (promptId: keyof AiPrompts, field: keyof AiPrompt, value: string | boolean) => {
    setAiPrompts(prev => ({
      ...prev,
      [promptId]: {
        ...prev[promptId],
        [field]: value
      }
    }));
  };

  const handleSerpItemChange = (type: 'headers' | 'texts', index: number, field: keyof SerpItem, value: string | boolean) => {
    setSerpData(prev => ({
      ...prev,
      [type]: prev[type].map((item, i) => 
        i === index 
          ? { ...item, [field]: value }
          : item
      )
    }));
  };

  const handleGenerateHeaders = async () => {
    setIsLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 1500));
      const enabledPrompts = Object.entries(aiPrompts)
        .filter(([_, prompt]) => prompt.enabled)
        .map(([_, prompt]) => prompt.text);
      
      setSerpData(prev => ({
        ...prev,
        aiHeaders: 'Generated headers based on prompts:\n\n' + enabledPrompts.join('\n\n')
      }));
    } catch (err) {
      console.error('Error generating headers:', err);
    } finally {
      setIsLoading(false);
    }
  };

  if (!selectedProjectId || !showAnalysis) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          {!selectedProjectId ? (
            <ProjectList onProjectSelect={setSelectedProjectId} />
          ) : (
            <ProjectDetails 
              projectId={selectedProjectId}
              onBack={() => setSelectedProjectId(null)}
              onCreateAnalysis={() => setShowAnalysis(true)}
            />
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <div className="flex flex-col space-y-4">
            <div className="flex items-center justify-between">
              <h1 className="text-2xl font-bold text-gray-900">Content Optimization Tool</h1>
              <button
                onClick={() => setShowAnalysis(false)}
                className="flex items-center text-gray-600 hover:text-gray-900"
              >
                <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
                Back to Project
              </button>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-12 gap-4">
              {/* Keyword Input */}
              <div className="md:col-span-4">
                <label className="block text-sm text-gray-600 mb-1">Enter your keyword here:</label>
                <input
                  type="text"
                  value={keyword}
                  onChange={(e) => setKeyword(e.target.value)}
                  placeholder="keyword"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                />
              </div>

              {/* URL Input */}
              <div className="md:col-span-4">
                <label className="block text-sm text-gray-600 mb-1">Compare your url here (optional):</label>
                <input
                  type="text"
                  value={url}
                  onChange={(e) => setUrl(e.target.value)}
                  placeholder="https:// ..."
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                />
              </div>

              {/* Region Select and Buttons */}
              <div className="md:col-span-4 flex items-end gap-2">
                <div className="flex-1">
                  <label className="block text-sm text-gray-600 mb-1">Select Region:</label>
                  <select
                    value={region}
                    onChange={(e) => setRegion(e.target.value)}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors appearance-none bg-white"
                  >
                    <option value="us USA">us USA</option>
                    <option value="ua Ukraine">ua Ukraine</option>
                  </select>
                </div>
                <button
                  onClick={handleParseSERP}
                  disabled={isLoading || !keyword.trim()}
                  className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50"
                >
                  Submit
                </button>
                <button className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
                  Save
                </button>
              </div>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-2 py-4 sm:px-4 md:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-12 gap-4 md:gap-6">
          {/* Score Section */}
          <div className="md:col-span-2 order-1 md:order-1">
            <div className="bg-white p-3 sm:p-4 rounded-lg shadow">
              <div className="text-center">
                <div className="relative inline-block">
                  <svg className="w-24 sm:w-32 h-24 sm:h-32" viewBox="0 0 36 36">
                    <path
                      d="M18 2.0845
                        a 15.9155 15.9155 0 0 1 0 31.831
                        a 15.9155 15.9155 0 0 1 0 -31.831"
                      fill="none"
                      stroke="#E5E7EB"
                      strokeWidth="3"
                    />
                    <path
                      d="M18 2.0845
                        a 15.9155 15.9155 0 0 1 0 31.831
                        a 15.9155 15.9155 0 0 1 0 -31.831"
                      fill="none"
                      stroke="#10B981"
                      strokeWidth="3"
                      strokeDasharray={`${Math.min(100, Math.max(0, wordCount / 10))}, 100`}
                    />
                  </svg>
                  <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                    <span className="text-2xl sm:text-3xl font-bold">{Math.round(Math.min(100, Math.max(0, wordCount / 10)))}</span>
                  </div>
                </div>
                <p className="mt-2 text-sm text-gray-600">Quick Score</p>
                <p className="mt-1 text-xs text-gray-400">Normal Mode</p>
              </div>
              
              <div className="mt-4">
                <div className="bg-gray-50 p-2 rounded">
                  <div className="flex justify-between items-center text-xs sm:text-sm">
                    <span className="text-gray-600">Unique</span>
                    <div className="flex items-center gap-2">
                      <span className="font-medium">{metrics.unique}</span>
                      <button
                        onClick={handleUpdateMetrics}
                        className="px-2 py-1 text-xs bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
                      >
                        Update
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div className="border-t border-gray-200 my-4"></div>
              
              <div className="mt-4 sm:mt-6">
                <p className="text-sm text-gray-600 mb-3">Metric (Yours/Avg)</p>
                <div className="space-y-2 sm:space-y-3">
                  <div className="bg-gray-50 p-2 rounded">
                    <div className="flex justify-between text-xs sm:text-sm">
                      <span className="text-gray-600">Word Count</span>
                      <span className="font-medium">{wordCount}/806</span>
                    </div>
                  </div>
                  <div className="bg-gray-50 p-2 rounded">
                    <div className="flex justify-between text-xs sm:text-sm">
                      <span className="text-gray-600">H2</span>
                      <span className="font-medium">{metrics.h2Count}</span>
                    </div>
                  </div>
                  <div className="bg-gray-50 p-2 rounded">
                    <div className="flex justify-between text-xs sm:text-sm">
                      <span className="text-gray-600">H3</span>
                      <span className="font-medium">{metrics.h3Count}</span>
                    </div>
                  </div>
                  <div className="bg-gray-50 p-2 rounded">
                    <div className="flex justify-between text-xs sm:text-sm">
                      <span className="text-gray-600">H4</span>
                      <span className="font-medium">{metrics.h4Count}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Editor and SERP Section */}
          <div className="md:col-span-7 order-3 md:order-2">
            <div className="bg-white rounded-lg shadow flex flex-col">
              <Toolbar editor={editor} />
              <div className="p-2 sm:p-4 h-[500px] min-h-[300px] max-h-[800px] resize-y overflow-auto">
                <EditorContent editor={editor} className="prose max-w-none h-full" />
              </div>

              {/* SERP Data Section with Tabs */}
              <div className="border-t border-gray-200">
                {/* Tabs */}
                <div className="border-b border-gray-200">
                  <nav className="flex -mb-px">
                    <button
                      onClick={() => setActiveSerpTab('headers')}
                      className={`flex-1 py-3 px-4 text-center text-sm font-medium border-b-2 transition-colors
                        ${activeSerpTab === 'headers'
                          ? 'border-blue-500 text-blue-600'
                          : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                        }`}
                    >
                      SERP Headers
                    </button>
                    <button
                      onClick={() => setActiveSerpTab('text')}
                      className={`flex-1 py-3 px-4 text-center text-sm font-medium border-b-2 transition-colors
                        ${activeSerpTab === 'text'
                          ? 'border-blue-500 text-blue-600'
                          : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                        }`}
                    >
                      SERP Text
                    </button>
                    <button
                      onClick={() => setActiveSerpTab('aiHeaders')}
                      className={`flex-1 py-3 px-4 text-center text-sm font-medium border-b-2 transition-colors
                        ${activeSerpTab === 'aiHeaders'
                          ? 'border-blue-500 text-blue-600'
                          : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                        }`}
                    >
                      AI Headers
                    </button>
                    <button
                      onClick={() => setActiveSerpTab('aiWriting')}
                      className={`flex-1 py-3 px-4 text-center text-sm font-medium border-b-2 transition-colors
                        ${activeSerpTab === 'aiWriting'
                          ? 'border-blue-500 text-blue-600'
                          : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                        }`}
                    >
                      AI Writing
                    </button>
                  </nav>
                </div>

                {/* Tab Content */}
                <div className="p-4 h-[400px] min-h-[200px] max-h-[600px] resize-y overflow-auto">
                  {activeSerpTab === 'headers' && (
                    <div className="space-y-2">
                      {serpData.headers.slice(0, showAllBlocks ? 10 : 3).map((header, index) => (
                        <div key={`header-${index}`} className="relative">
                          <div className="flex items-center gap-2 mb-2">
                            <input
                              type="checkbox"
                              checked={header.enabled}
                              onChange={(e) => handleSerpItemChange('headers', index, 'enabled', e.target.checked)}
                              className="w-4 h-4 text-blue-600 rounded border-gray-300 focus:ring-blue-500"
                            />
                            <span className="text-sm font-medium text-gray-700">Competitor #{index + 1}</span>
                          </div>
                          <textarea
                            value={header.content}
                            onChange={(e) => handleSerpItemChange('headers', index, 'content', e.target.value)}
                            placeholder={`Competitor ${index + 1} Headers`}
                            className="w-full h-[200px] p-3 border border-gray-300 rounded-lg resize-y 
                                     focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                                     transition-colors text-sm"
                          />
                        </div>
                      ))}
                      {!showAllBlocks && serpData.headers.length > 3 && (
                        <button
                          onClick={() => setShowAllBlocks(true)}
                          className="w-full py-2 mt-2 text-sm font-medium text-blue-600 hover:text-blue-700 
                                   bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors"
                        >
                          Show More
                        </button>
                      )}
                      {showAllBlocks && (
                        <button
                          onClick={() => setShowAllBlocks(false)}
                          className="w-full py-2 mt-2 text-sm font-medium text-blue-600 hover:text-blue-700 
                                   bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors"
                        >
                          Show Less
                        </button>
                      )}
                    </div>
                  )}

                  {activeSerpTab === 'text' && (
                    <div className="space-y-2">
                      {serpData.texts.slice(0, showAllBlocks ? 10 : 3).map((text, index) => (
                        <div key={`text-${index}`} className="relative">
                          <div className="flex items-center gap-2 mb-2">
                            <input
                              type="checkbox"
                              checked={text.enabled}
                              onChange={(e) => handleSerpItemChange('texts', index, 'enabled', e.target.checked)}
                              className="w-4 h-4 text-blue-600 rounded border-gray-300 focus:ring-blue-500"
                            />
                            <span className="text-sm font-medium text-gray-700">Competitor #{index + 1}</span>
                          </div>
                          <textarea
                            value={text.content}
                            onChange={(e) => handleSerpItemChange('texts', index, 'content', e.target.value)}
                            placeholder={`Competitor ${index + 1} Text`}
                            className="w-full h-[200px] p-3 border border-gray-300 rounded-lg resize-y 
                                     focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                                     transition-colors text-sm"
                          />
                        </div>
                      ))}
                      {!showAllBlocks && serpData.texts.length > 3 && (
                        <button
                          onClick={() => setShowAllBlocks(true)}
                          className="w-full py-2 mt-2 text-sm font-medium text-blue-600 hover:text-blue-700 
                                   bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors"
                        >
                          Show More
                        </button>
                      )}
                      {showAllBlocks && (
                        <button
                          onClick={() => setShowAllBlocks(false)}
                          className="w-full py-2 mt-2 text-sm font-medium text-blue-600 hover:text-blue-700 
                                   bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors"
                        >
                          Show Less
                        </button>
                      )}
                    </div>
                  )}

                  {activeSerpTab === 'aiHeaders' && (
                    <div className="space-y-4">
                      {/* Prompt Customization Section */}
                      <div className="space-y-4 mb-6">
                        {/* Prompt 1 */}
                        <div className="space-y-2">
                          <div className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              checked={aiPrompts.prompt1.enabled}
                              onChange={(e) => handlePromptChange('prompt1', 'enabled', e.target.checked)}
                              className="w-4 h-4 text-blue-600 rounded border-gray-300 focus:ring-blue-500"
                            />
                            <label className="text-sm font-medium text-gray-700">Prompt_1</label>
                          </div>
                          <textarea
                            value={aiPrompts.prompt1.text}
                            onChange={(e) => handlePromptChange('prompt1', 'text', e.target.value)}
                            placeholder="Enter your prompt for SEO-optimized headers..."
                            className="w-full h-[40px] p-2 border border-gray-300 rounded-lg resize-y 
                                     focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                                     transition-colors text-sm"
                          />
                        </div>

                        {/* Prompt 2 */}
                        <div className="space-y-2">
                          <div className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              checked={aiPrompts.prompt2.enabled}
                              onChange={(e) => handlePromptChange('prompt2', 'enabled', e.target.checked)}
                              className="w-4 h-4 text-blue-600 rounded border-gray-300 focus:ring-blue-500"
                            />
                            <label className="text-sm font-medium text-gray-700">Prompt_2</label>
                          </div>
                          <textarea
                            value={aiPrompts.prompt2.text}
                            onChange={(e) => handlePromptChange('prompt2', 'text', e.target.value)}
                            placeholder="Enter your prompt for engaging subheadings..."
                            className="w-full h-[40px] p-2 border border-gray-300 rounded-lg resize-y 
                                     focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                                     transition-colors text-sm"
                          />
                        </div>

                        {/* Prompt 3 */}
                        <div className="space-y-2">
                          <div className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              checked={aiPrompts.prompt3.enabled}
                              onChange={(e) => handlePromptChange('prompt3', 'enabled', e.target.checked)}
                              className="w-4 h-4 text-blue-600 rounded border-gray-300 focus:ring-blue-500"
                            />
                            <label className="text-sm font-medium text-gray-700">Prompt_3</label>
                          </div>
                          <textarea
                            value={aiPrompts.prompt3.text}
                            onChange={(e) => handlePromptChange('prompt3', 'text', e.target.value)}
                            placeholder="Enter your prompt for search intent-focused headers..."
                            className="w-full h-[40px] p-2 border border-gray-300 rounded-lg resize-y 
                                     focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                                     transition-colors text-sm"
                          />
                        </div>
                      </div>

                      {/* Output Section */}
                      <div className="space-y-4">
                        <textarea
                          value={serpData.aiHeaders}
                          onChange={(e) => setSerpData(prev => ({ ...prev, aiHeaders: e.target.value }))}
                          placeholder="AI generated headers will appear here..."
                          className="w-full h-[200px] p-3 border border-gray-300 rounded-lg resize-y 
                                   focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                                   transition-colors text-sm"
                        />
                        <button
                          onClick={handleGenerateHeaders}
                          disabled={isLoading}
                          className="w-full py-2 text-sm font-medium text-white bg-blue-500 hover:bg-blue-600 
                                   rounded-lg transition-colors disabled:opacity-50"
                        >
                          {isLoading ? 'Generating...' : 'Generate Headers'}
                        </button>
                      </div>
                    </div>
                  )}

                  {activeSerpTab === 'aiWriting' && (
                    <div className="space-y-4">
                      <textarea
                        value={serpData.aiWriting}
                        onChange={(e) => setSerpData(prev => ({ ...prev, aiWriting: e.target.value }))}
                        placeholder="AI generated content will appear here..."
                        className="w-full h-[400px] p-3 border border-gray-300 rounded-lg resize-y 
                                 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                                 transition-colors text-sm"
                      />
                      <button
                        className="w-full py-2 text-sm font-medium text-white bg-blue-500 hover:bg-blue-600 
                                 rounded-lg transition-colors"
                      >
                        Generate Content
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="md:col-span-3 order-2 md:order-3">
            <Sidebar />
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;