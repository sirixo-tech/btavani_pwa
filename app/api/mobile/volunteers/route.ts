import { z } from "zod";
import { createVolunteer } from "@/lib/repository";

export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  const parsed = z
    .object({
      name: z.string().min(2),
      flatNumber: z.string().min(1),
      mobile: z.string().min(10),
      roles: z.array(z.string()).min(1),
      note: z.string().optional().default(""),
    })
    .parse(await request.json());

  const volunteer = await createVolunteer(parsed);
  return Response.json({ volunteer }, { status: 201 });
}
