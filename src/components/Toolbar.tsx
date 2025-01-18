import React, { useState, useRef, useEffect } from 'react';
import { Editor } from '@tiptap/react';

interface ToolbarProps {
  editor: Editor | null;
}

const Toolbar: React.FC<ToolbarProps> = ({ editor }) => {
  const [showHeadingDropdown, setShowHeadingDropdown] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setShowHeadingDropdown(false);
      }
    }

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  if (!editor) {
    return null;
  }

  const headingLevels = [
    { level: 1, label: 'H1', className: 'text-2xl' },
    { level: 2, label: 'H2', className: 'text-xl' },
    { level: 3, label: 'H3', className: 'text-lg' },
    { level: 4, label: 'H4', className: 'text-base' },
    { level: 5, label: 'H5', className: 'text-sm' },
  ];

  return (
    <div className="border-b border-gray-200 p-2 flex items-center gap-1">
      <button
        onClick={() => editor.chain().focus().undo().run()}
        disabled={!editor.can().undo()}
        className="p-2 rounded hover:bg-gray-100 disabled:opacity-50"
        title="Undo"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="none" stroke="currentColor" strokeWidth="2" d="M3,7 L3,11 L7,11 M3,9 C7,4 13,4 16.5,7.5 C20,11 20,17 16.5,20.5 C13,24 7,24 3,19"></path>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().redo().run()}
        disabled={!editor.can().redo()}
        className="p-2 rounded hover:bg-gray-100 disabled:opacity-50"
        title="Redo"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="none" stroke="currentColor" strokeWidth="2" d="M21,7 L21,11 L17,11 M21,9 C17,4 11,4 7.5,7.5 C4,11 4,17 7.5,20.5 C11,24 17,24 21,19"></path>
        </svg>
      </button>

      <div className="w-px h-6 bg-gray-200 mx-1" />

      <button
        onClick={() => editor.chain().focus().toggleBold().run()}
        className={`p-2 rounded ${editor.isActive('bold') ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Bold"
      >
        <span className="font-bold">B</span>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleItalic().run()}
        className={`p-2 rounded ${editor.isActive('italic') ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Italic"
      >
        <span className="italic">i</span>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleUnderline().run()}
        className={`p-2 rounded ${editor.isActive('underline') ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Underline"
      >
        <span className="underline">U</span>
      </button>

      <div className="w-px h-6 bg-gray-200 mx-1" />

      <div className="relative" ref={dropdownRef}>
        <button
          onClick={() => setShowHeadingDropdown(!showHeadingDropdown)}
          className={`p-2 rounded hover:bg-gray-100 flex items-center gap-1`}
          title="Heading"
        >
          <span className="font-semibold">H</span>
          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M6 9l6 6 6-6"/>
          </svg>
        </button>
        
        {showHeadingDropdown && (
          <div className="absolute top-full left-0 mt-1 bg-white rounded-lg shadow-lg border border-gray-200 py-1 min-w-[100px] z-50">
            <button
              onClick={() => {
                editor.chain().focus().setParagraph().run();
                setShowHeadingDropdown(false);
              }}
              className={`w-full px-3 py-1 text-left hover:bg-gray-100 ${editor.isActive('paragraph') ? 'bg-gray-200' : ''}`}
            >
              Normal
            </button>
            {headingLevels.map(({ level, label, className }) => (
              <button
                key={level}
                onClick={() => {
                  editor.chain().focus().toggleHeading({ level }).run();
                  setShowHeadingDropdown(false);
                }}
                className={`w-full px-3 py-1 text-left hover:bg-gray-100 ${editor.isActive('heading', { level }) ? 'bg-gray-200' : ''} ${className}`}
              >
                {label}
              </button>
            ))}
          </div>
        )}
      </div>

      <div className="w-px h-6 bg-gray-200 mx-1" />

      <button
        onClick={() => editor.chain().focus().setTextAlign('left').run()}
        className={`p-2 rounded ${editor.isActive({ textAlign: 'left' }) ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Align Left"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M3 5h18v2H3V5zm0 4h12v2H3V9zm0 4h18v2H3v-2zm0 4h12v2H3v-2z"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().setTextAlign('center').run()}
        className={`p-2 rounded ${editor.isActive({ textAlign: 'center' }) ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Align Center"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M3 5h18v2H3V5zm3 4h12v2H6V9zm-3 4h18v2H3v-2zm3 4h12v2H6v-2z"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().setTextAlign('right').run()}
        className={`p-2 rounded ${editor.isActive({ textAlign: 'right' }) ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Align Right"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M3 5h18v2H3V5zm6 4h12v2H9V9zm-6 4h18v2H3v-2zm6 4h12v2H9v-2z"/>
        </svg>
      </button>

      <div className="w-px h-6 bg-gray-200 mx-1" />

      <button
        onClick={() => editor.chain().focus().toggleBulletList().run()}
        className={`p-2 rounded ${editor.isActive('bulletList') ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Bullet List"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M4 6a2 2 0 1 1 0-4 2 2 0 0 1 0 4zM4 14a2 2 0 1 1 0-4 2 2 0 0 1 0 4zM4 22a2 2 0 1 1 0-4 2 2 0 0 1 0 4zM9 5h12a1 1 0 0 1 0 2H9a1 1 0 0 1 0-2zm0 8h12a1 1 0 0 1 0 2H9a1 1 0 0 1 0-2zm0 8h12a1 1 0 0 1 0 2H9a1 1 0 0 1 0-2z"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleOrderedList().run()}
        className={`p-2 rounded ${editor.isActive('orderedList') ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Numbered List"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M3 4h2v2H3V4zm0 7h2v2H3v-2zm0 7h2v2H3v-2zM8 5h13v2H8V5zm0 7h13v2H8v-2zm0 7h13v2H8v-2z"/>
        </svg>
      </button>

      <div className="w-px h-6 bg-gray-200 mx-1" />

      <button
        onClick={() => {
          const url = window.prompt('Enter the link URL');
          if (url) {
            editor.chain().focus().setLink({ href: url }).run();
          }
        }}
        className={`p-2 rounded ${editor.isActive('link') ? 'bg-gray-200' : 'hover:bg-gray-100'}`}
        title="Add Link"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M13.06 8.11l1.415 1.415a7 7 0 0 1 0 9.9l-.354.353a7 7 0 0 1-9.9-9.9l1.415 1.415a5 5 0 1 0 7.07 7.07l.354-.353a5 5 0 0 0 0-7.07l-1.415-1.415 1.415-1.414zm6.718 6.011l-1.414-1.414a5 5 0 1 0-7.071-7.071l-.354.353a5 5 0 0 0 0 7.071l1.414 1.415-1.414 1.414-1.414-1.414a7 7 0 0 1 0-9.9l.353-.353a7 7 0 0 1 9.9 9.9z"/>
        </svg>
      </button>

      <button
        onClick={() => editor.chain().focus().unsetLink().run()}
        className={`p-2 rounded hover:bg-gray-100`}
        title="Remove Link"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M17.657 14.828l-1.414-1.414L17.657 12A4 4 0 1 0 12 6.343l-1.414 1.414-1.414-1.414 1.414-1.414a6 6 0 0 1 8.485 8.485l-1.414 1.414zm-2.829 2.829l-1.414 1.414a6 6 0 1 1-8.485-8.485l1.414-1.414 1.414 1.414L6.343 12A4 4 0 1 0 12 17.657l1.414-1.414 1.414 1.414zm0-9.9l1.415 1.415-7.071 7.071-1.415-1.415 7.071-7.071z"/>
        </svg>
      </button>

      <button
        onClick={() => {
          const url = window.prompt('Enter the image URL');
          if (url) {
            editor.chain().focus().setImage({ src: url }).run();
          }
        }}
        className="p-2 rounded hover:bg-gray-100"
        title="Add Image"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2zm0 2v10l4-4 4 4 4-4 4 4V6H4zm2 2a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/>
        </svg>
      </button>
    </div>
  );
};

export default Toolbar;