import { z } from "zod";
import { createRegistration } from "@/lib/repository";

export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  const parsed = z
    .object({
      eventTitle: z.string().min(1),
      participantName: z.string().min(2),
      flatNumber: z.string().min(1),
      ageGroup: z.string(), // We'll keep this optional/empty string for backward compatibility
      mobile: z.string(),
      personType: z.string(),
      kidsName: z.string().optional().default(""),
      kidsAge: z.string().optional().default(""),
      parentAdultPhone: z.string().optional().default(""),
      otherPerformanceDetails: z.string().optional().default(""),
    })
    .parse(await request.json());

  const registration = await createRegistration(parsed);
  return Response.json({ registration }, { status: 201 });
}
