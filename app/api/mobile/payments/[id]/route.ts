import { z } from "zod";
import { updatePaymentPartial } from "@/lib/repository";

export const dynamic = "force-dynamic";

function authorizeWrite(request: Request) {
  const token = process.env.MOBILE_API_TOKEN;
  if (!token) return true;
  return request.headers.get("authorization") === `Bearer ${token}`;
}

export async function PUT(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  if (!authorizeWrite(request)) {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
  }

  let body: Record<string, unknown> = {};
  if (request.headers.get("content-type")?.includes("multipart/form-data")) {
    const formData = await request.formData();
    for (const [key, value] of formData.entries()) {
      if (key === "screenshot" && value instanceof File) {
        const buffer = await value.arrayBuffer();
        const base64 = Buffer.from(buffer).toString("base64");
        body.screenshotUrl = `data:${value.type};base64,${base64}`;
      } else {
        body[key] = value instanceof File ? value.name : value;
      }
    }
  } else {
    body = await request.json();
  }

  const parsed = z
    .object({
      status: z.enum(["created", "pending", "paid", "failed", "refunded"]).optional(),
      referenceId: z.string().optional(),
      screenshotUrl: z.string().optional(),
      provider: z.enum(["upi_qr", "razorpay", "manual"]).optional(),
    })
    .parse(body);

  const resolvedParams = await params;
  await updatePaymentPartial(resolvedParams.id, parsed);
  return Response.json({ success: true });
}
