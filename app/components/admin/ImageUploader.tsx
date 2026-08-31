"use client";

import React, { useState } from "react";
import { PhotoIcon } from "@heroicons/react/24/outline";

export function ImageUploader({
  defaultImage,
  name = "imageFile",
}: {
  defaultImage?: string;
  name?: string;
}) {
  const inputId = React.useId();
  const [preview, setPreview] = useState<string | null>(defaultImage || null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        alert("Image must be smaller than 10MB");
        e.target.value = "";
        return;
      }
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    } else {
      setPreview(defaultImage || null);
    }
  };

  return (
    <div className="col-span-full">
      <div className="mt-2 flex justify-center rounded-lg border border-dashed border-zinc-900/25 px-6 py-10 transition-colors hover:bg-zinc-50 relative">
        <input 
          id={inputId} 
          name={name} 
          type="file" 
          className="absolute inset-0 w-full h-full opacity-0 cursor-pointer" 
          accept="image/*" 
          onChange={handleFileChange} 
        />
        <div className="text-center pointer-events-none">
          {preview ? (
            <div className="mx-auto flex flex-col items-center">
              <img src={preview} alt="Preview" className="h-40 w-auto rounded-md object-contain shadow-sm mb-4" />
              <div className="cursor-pointer rounded-md bg-white px-3 py-2 text-sm font-semibold text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300">
                Replace image
              </div>
            </div>
          ) : (
            <>
              <PhotoIcon className="mx-auto h-12 w-12 text-zinc-300" aria-hidden="true" />
              <div className="mt-4 flex text-sm leading-6 text-zinc-600 justify-center">
                <span className="relative rounded-md bg-white font-semibold text-indigo-600">
                  Upload a file
                </span>
                <p className="pl-1">or drag and drop</p>
              </div>
              <p className="text-xs leading-5 text-zinc-500">PNG, JPG, GIF up to 10MB</p>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
