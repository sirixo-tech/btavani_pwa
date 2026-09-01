"use client";

import { useState } from "react";

export function ScreenshotViewer({ url }: { url: string }) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button 
        type="button" 
        onClick={() => setOpen(true)}
        className="inline-block border border-zinc-200 rounded p-1 hover:border-indigo-500 transition-colors bg-white mt-1 cursor-pointer"
      >
        <img src={url} alt="Payment Screenshot" className="h-16 w-auto object-contain rounded-sm" />
      </button>

      {open && (
        <div 
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80"
          onClick={() => setOpen(false)}
        >
          <div className="relative max-w-3xl max-h-full w-full flex justify-center">
            <button 
              className="absolute -top-10 right-0 text-white hover:text-zinc-300 font-bold p-2"
              onClick={() => setOpen(false)}
            >
              Close
            </button>
            <img 
              src={url} 
              alt="Payment Screenshot Full" 
              className="max-h-[85vh] w-auto object-contain rounded bg-white"
              onClick={(e) => e.stopPropagation()}
            />
          </div>
        </div>
      )}
    </>
  );
}
