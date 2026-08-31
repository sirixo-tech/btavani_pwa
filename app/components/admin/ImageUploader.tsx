"use client";

import { useState } from "react";
import { PhotoIcon } from "@heroicons/react/24/outline";

export function ImageUploader({
  defaultImage,
  name = "imageFile",
}: {
  defaultImage?: string;
  name?: string;
}) {
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
      <div className="mt-2 flex justify-center rounded-lg border border-dashed border-zinc-900/25 px-6 py-10 transition-colors hover:bg-zinc-50">
        <div className="text-center">
          {preview ? (
            <div className="mx-auto flex flex-col items-center">
              <img src={preview} alt="Preview" className="h-40 w-auto rounded-md object-contain shadow-sm mb-4" />
              <label htmlFor="file-upload" className="cursor-pointer rounded-md bg-white px-3 py-2 text-sm font-semibold text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 hover:bg-zinc-50">
                Replace image
                <input id="file-upload" name={name} type="file" className="sr-only" accept="image/*" onChange={handleFileChange} />
              </label>
            </div>
          ) : (
            <>
              <PhotoIcon className="mx-auto h-12 w-12 text-zinc-300" aria-hidden="true" />
              <div className="mt-4 flex text-sm leading-6 text-zinc-600 justify-center">
                <label
                  htmlFor="file-upload"
                  className="relative cursor-pointer rounded-md bg-white font-semibold text-indigo-600 focus-within:outline-none focus-within:ring-2 focus-within:ring-indigo-600 focus-within:ring-offset-2 hover:text-indigo-500"
                >
                  <span>Upload a file</span>
                  <input id="file-upload" name={name} type="file" className="sr-only" accept="image/*" onChange={handleFileChange} />
                </label>
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
