import { z } from "zod";
import { createPayment } from "@/lib/repository";

export const dynamic = "force-dynamic";

function authorizeWrite(request: Request) {
  const token = process.env.MOBILE_API_TOKEN;
  if (!token) return true;
  return request.headers.get("authorization") === `Bearer ${token}`;
}

export async function POST(request: Request) {
  if (!authorizeWrite(request)) {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = await request.json();
  const parsed = z
    .object({
      amount: z.coerce.number().int().min(2000).max(99000),
      blockId: z.string().min(1),
      residentName: z.string().min(1),
      email: z.string().optional(),
      phone: z.string().optional(),
      flatNumber: z.string().optional(),
      gotram: z.string().optional(),
      provider: z.enum(["upi_qr", "razorpay", "manual"]).optional(),
      status: z.enum(["created", "pending", "paid", "failed", "refunded"]).optional(),
      referenceId: z.string().optional(),
    })
    .parse(body);

  const payment = await createPayment(parsed);
  return Response.json({ payment }, { status: 201 });
}
