import { z } from "zod";
import { createAuctionBid } from "@/lib/repository";

export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  const parsed = z
    .object({
      itemTitle: z.string().optional().default("Laddoo Auction"),
      amount: z.coerce.number().int().min(1),
      bidderName: z.string().optional().default(""),
      flatNumber: z.string().min(1),
      mobile: z.string().optional().default(""),
    })
    .parse(await request.json());

  const bid = await createAuctionBid(parsed);
  return Response.json({ bid }, { status: 201 });
}
