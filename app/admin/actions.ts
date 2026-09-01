"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { z } from "zod";
import {
  clearAdminSession,
  createAdminSession,
  isValidAdminPassword,
  requireAdmin,
} from "@/lib/auth";
import {
  createPayment,
  saveBlock,
  saveCmsEntry,
  updatePaymentStatus,
  deleteCmsEntry,
  deletePayment
} from "@/lib/repository";
import type { CmsEntry, PaymentProvider, PaymentStatus } from "@/lib/types";

const paymentProviders = ["upi_qr", "razorpay", "manual"] as const;
const paymentStatuses = ["created", "pending", "paid", "failed", "refunded"] as const;
const cmsSections = [
  "event",
  "schedule",
  "announcement",
  "gallery",
  "volunteer_role",
  "app_setting",
] as const;

function text(formData: FormData, key: string) {
  return String(formData.get(key) || "").trim();
}

function checked(formData: FormData, key: string) {
  return formData.get(key) === "on";
}

async function fileToDataUrl(file: File | null) {
  if (!file || file.size === 0) return "";
  if (file.size > 10 * 1024 * 1024) {
    throw new Error("Image is too large. Keep uploads under 10 MB.");
  }

  const buffer = Buffer.from(await file.arrayBuffer());
  return `data:${file.type || "application/octet-stream"};base64,${buffer.toString(
    "base64",
  )}`;
}

export async function loginAdmin(formData: FormData) {
  const password = text(formData, "password");
  if (!isValidAdminPassword(password)) {
    redirect("/admin?error=invalid");
  }

  await createAdminSession();
  redirect("/admin");
}

export async function logoutAdmin() {
  await clearAdminSession();
  redirect("/admin");
}

export async function saveBlockAction(prevState: unknown, formData: FormData) {
  await requireAdmin();

  const uploadedQr = await fileToDataUrl(formData.get("qrFile") as File | null);
  const provider = text(formData, "paymentProvider") as PaymentProvider;

  const parsed = z
    .object({
      id: z.string(),
      name: z.string().min(1),
      organizerName: z.string().optional(),
      organizerPhone: z.string().optional(),
      upiId: z.string().optional(),
      qrImageUrl: z.string().optional(),
      paymentProvider: z.enum(paymentProviders),
      razorpayKeyId: z.string().optional(),
      razorpayLink: z.string().optional(),
      isActive: z.boolean(),
    })
    .parse({
      id: text(formData, "id") || crypto.randomUUID(),
      name: text(formData, "name"),
      organizerName: text(formData, "organizerName"),
      organizerPhone: text(formData, "organizerPhone"),
      upiId: text(formData, "upiId"),
      qrImageUrl: uploadedQr || text(formData, "qrImageUrl"),
      paymentProvider: provider,
      razorpayKeyId: text(formData, "razorpayKeyId"),
      razorpayLink: text(formData, "razorpayLink"),
      isActive: checked(formData, "isActive"),
    });

  await saveBlock(parsed);
  revalidatePath("/admin", "layout");
  return { success: true };
}

export async function saveCmsAction(formData: FormData) {
  await requireAdmin();

  const file = formData.get("imageFile") as File | null;
  console.log("saveCmsAction: Received imageFile:", file?.name, file?.size, file?.type);
  const uploadedImage = await fileToDataUrl(file);
  const parsed = z
    .object({
      id: z.string().optional(),
      section: z.enum(cmsSections),
      title: z.string().min(1),
      subtitle: z.string().optional(),
      body: z.string().optional(),
      imageUrl: z.string().optional(),
      label: z.string().optional(),
      color: z.string().min(4),
      startsAt: z.string().optional(),
      venue: z.string().optional(),
      sortOrder: z.coerce.number().int(),
      isPublished: z.boolean(),
    })
    .parse({
      id: text(formData, "id") || undefined,
      section: text(formData, "section"),
      title: text(formData, "title"),
      subtitle: text(formData, "subtitle"),
      body: text(formData, "body"),
      imageUrl: uploadedImage || text(formData, "imageUrl"),
      label: text(formData, "label"),
      color: text(formData, "color") || "#8E1119",
      startsAt: text(formData, "startsAt"),
      venue: text(formData, "venue"),
      sortOrder: text(formData, "sortOrder") || "0",
      isPublished: checked(formData, "isPublished"),
    });

  await saveCmsEntry(parsed as Omit<CmsEntry, "id"> & { id?: string });
  revalidatePath("/admin", "layout");
}

export async function updatePaymentAction(formData: FormData) {
  await requireAdmin();

  const parsed = z
    .object({
      id: z.string().min(1),
      status: z.enum(paymentStatuses),
      referenceId: z.string().optional(),
    })
    .parse({
      id: text(formData, "id"),
      status: text(formData, "status"),
      referenceId: text(formData, "referenceId"),
    });

  await updatePaymentStatus(
    parsed.id,
    parsed.status as PaymentStatus,
    parsed.referenceId || "",
  );
  revalidatePath("/admin");
  revalidatePath("/admin/payments");
  revalidatePath("/admin", "layout");
  redirect("/admin/payments");
}

export async function createPaymentAction(formData: FormData) {
  await requireAdmin();

  const parsed = z
    .object({
      amount: z.coerce.number().int().min(1),
      blockId: z.string().min(1),
      residentName: z.string().min(1),
      email: z.string().optional(),
      phone: z.string().optional(),
      flatNumber: z.string().optional(),
      gotram: z.string().optional(),
      provider: z.enum(paymentProviders),
      status: z.enum(paymentStatuses),
      referenceId: z.string().optional(),
    })
    .parse({
      amount: text(formData, "amount"),
      blockId: text(formData, "blockId"),
      residentName: text(formData, "residentName"),
      email: text(formData, "email"),
      phone: text(formData, "phone"),
      flatNumber: text(formData, "flatNumber"),
      gotram: text(formData, "gotram"),
      provider: text(formData, "provider"),
      status: text(formData, "status"),
      referenceId: text(formData, "referenceId"),
    });

  await createPayment(parsed);
  revalidatePath("/admin", "layout");
}

export async function clearDemoDataAction() {
  await requireAdmin();
  const { clearDemoData } = await import("@/lib/repository");
  await clearDemoData();
  revalidatePath("/admin", "layout");
}

export async function deleteCmsAction(formData: FormData) {
  await requireAdmin();
  const id = text(formData, "id");
  if (id) {
    await deleteCmsEntry(id);
    revalidatePath("/admin/events");
    revalidatePath("/admin/content");
  }
}

export async function publishCmsAction(formData: FormData) {
  await requireAdmin();
  const id = text(formData, "id");
  if (id) {
    const { query } = await import("@/lib/db");
    const { clearMobileCache } = await import("@/lib/cache");
    await query("update cms_entries set is_published = true where id = $1", [id]);
    await clearMobileCache();
    revalidatePath("/admin/events");
    revalidatePath("/admin/content");
  }
}

export async function deletePaymentAction(formData: FormData) {
  await requireAdmin();
  const id = text(formData, "id");
  if (id) {
    await deletePayment(id);
    revalidatePath("/admin/payments");
  }
}
