"use client";

import { useActionState, useEffect, useState } from "react";
import { saveBlockAction } from "./actions";
import type { Block } from "@/lib/types";

const providers = [
  ["upi_qr", "UPI / uploaded QR"],
  ["razorpay", "Razorpay integration"],
  ["manual", "Manual collection"],
];

function Input({
  name,
  label,
  type = "text",
  defaultValue = "",
  required = false,
}: {
  name: string;
  label: string;
  type?: string;
  defaultValue?: string | number;
  required?: boolean;
}) {
  return (
    <label className="block">
      <span className="label">{label}</span>
      <input
        className="input focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
        name={name}
        type={type}
        defaultValue={defaultValue}
        required={required}
      />
    </label>
  );
}

function Select({
  name,
  label,
  options,
  defaultValue,
}: {
  name: string;
  label: string;
  options: string[][] | readonly (readonly string[])[];
  defaultValue?: string;
}) {
  return (
    <label className="block">
      <span className="label">{label}</span>
      <select className="input focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500" name={name} defaultValue={defaultValue}>
        {options.map(([value, optionLabel]) => (
          <option key={value} value={value}>
            {optionLabel}
          </option>
        ))}
      </select>
    </label>
  );
}

export function BlockForm({ block }: { block: Block }) {
  const [state, formAction, isPending] = useActionState(saveBlockAction, null);
  const [showSuccess, setShowSuccess] = useState(false);

  useEffect(() => {
    if (state?.success) {
      setShowSuccess(true);
      const timer = setTimeout(() => setShowSuccess(false), 3000);
      return () => clearTimeout(timer);
    }
  }, [state]);

  return (
    <form
      action={formAction}
      className="relative rounded-xl border border-zinc-200 bg-white p-6 shadow-sm transition-shadow hover:shadow-md"
    >
      <input type="hidden" name="id" value={block.id} />
      
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-lg font-semibold text-zinc-900">{block.name}</h3>
          <p className="text-xs font-medium text-zinc-500">
            QR and payment destination
          </p>
        </div>
        <label className="flex items-center gap-2 text-sm font-medium text-zinc-700 cursor-pointer">
          <input
            type="checkbox"
            name="isActive"
            defaultChecked={block.isActive}
            className="rounded border-zinc-300 text-indigo-600 focus:ring-indigo-600 size-4 cursor-pointer"
          />
          Active
        </label>
      </div>

      <div className="mt-5 grid gap-4 sm:grid-cols-2">
        <Input name="name" label="Block name" defaultValue={block.name} required />
        <Select
          name="paymentProvider"
          label="Mode"
          defaultValue={block.paymentProvider}
          options={providers}
        />
        <Input
          name="organizerName"
          label="Organizer"
          defaultValue={block.organizerName}
        />
        <Input
          name="organizerPhone"
          label="Organizer phone"
          defaultValue={block.organizerPhone}
        />
        <Input name="upiId" label="UPI ID" defaultValue={block.upiId} />
        <Input
          name="qrImageUrl"
          label="QR image URL"
          defaultValue={block.qrImageUrl}
        />
        <Input
          name="razorpayKeyId"
          label="Razorpay key ID"
          defaultValue={block.razorpayKeyId}
        />
        <Input
          name="razorpayLink"
          label="Razorpay payment link"
          defaultValue={block.razorpayLink}
        />
      </div>

      <label className="mt-4 block">
        <span className="label">Upload custom QR image</span>
        <input className="file-input focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500" name="qrFile" type="file" accept="image/*" />
      </label>
      
      <div className="mt-6 flex items-center gap-4">
        <button 
          disabled={isPending}
          className="inline-flex min-h-11 items-center justify-center rounded-lg bg-indigo-600 px-5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:opacity-70 transition-colors"
        >
          {isPending ? 'Saving...' : 'Save block changes'}
        </button>
        {showSuccess && (
          <span className="text-sm font-medium text-emerald-600 flex items-center gap-1.5 animate-in fade-in slide-in-from-left-2">
            <svg className="size-4" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z" clipRule="evenodd" />
            </svg>
            Saved!
          </span>
        )}
      </div>
    </form>
  );
}
