import React, { useState } from 'react';

const Sidebar: React.FC = () => {
  const [activeTab, setActiveTab] = useState('keywords');
  const [keywordsText, setKeywordsText] = useState('');

  const recommendedWords = [
    'concrete', 'drilling', 'project', 'applications', 'equipment',
    'services', 'structure', 'safety', 'quality', 'expertise'
  ];

  const competitors = [
    { name: 'ABC Drilling', url: 'abcdrilling.com' },
    { name: 'CoreTech Solutions', url: 'coretechsolutions.com' },
    { name: 'DrillMaster Pro', url: 'drillmasterpro.com' }
  ];

  const tabs = [
    { id: 'keywords', label: 'Keywords' },
    { id: 'competitors', label: 'Competitors' },
    { id: 'tips', label: 'Tips' }
  ];

  const renderTabContent = () => {
    switch (activeTab) {
      case 'keywords':
        return (
          <div className="space-y-4">
            <div>
              <h3 className="font-medium text-gray-700 mb-2">Words</h3>
              <div className="flex flex-wrap gap-1.5 sm:gap-2">
                {recommendedWords.map((word, index) => (
                  <span
                    key={index}
                    className="px-2 py-1 rounded-full text-xs sm:text-sm bg-green-100 text-green-800"
                  >
                    {word}
                  </span>
                ))}
              </div>
            </div>
            <div>
              <h3 className="font-medium text-gray-700 mb-2">Keywords</h3>
              <textarea
                value={keywordsText}
                onChange={(e) => setKeywordsText(e.target.value)}
                placeholder="Enter your keywords..."
                className="w-full p-2 border border-gray-300 rounded-lg text-sm resize-y min-h-[100px]"
              />
            </div>
          </div>
        );
      case 'competitors':
        return (
          <ul className="space-y-2 text-sm">
            {competitors.map((competitor, index) => (
              <li key={index} className="flex items-center justify-between p-2 rounded bg-gray-50">
                <span className="font-medium text-gray-700">{competitor.name}</span>
                <span className="text-xs text-gray-500">{competitor.url}</span>
              </li>
            ))}
          </ul>
        );
      case 'tips':
        return (
          <ul className="space-y-1.5 text-sm text-gray-600">
            <li>• Use keywords naturally throughout the text</li>
            <li>• Keep paragraphs short and focused</li>
            <li>• Include relevant industry terms</li>
            <li>• Maintain a professional tone</li>
          </ul>
        );
      default:
        return null;
    }
  };

  return (
    <div className="bg-white rounded-lg shadow">
      <div className="border-b border-gray-200">
        <nav className="flex -mb-px">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex-1 py-3 px-1 text-center text-sm font-medium border-b-2 transition-colors
                ${activeTab === tab.id
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
            >
              {tab.label}
            </button>
          ))}
        </nav>
      </div>
      <div className="p-3 sm:p-4">
        {renderTabContent()}
      </div>
    </div>
  );
};

export default Sidebar;