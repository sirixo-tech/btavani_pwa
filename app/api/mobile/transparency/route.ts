import { getDashboardData } from "@/lib/repository";

export const dynamic = "force-dynamic";

export async function GET() {
  const data = await getDashboardData();
  
  // Aggregate collections by block
  const blockMap = new Map<string, { block_name: string, total_payments: number, total_amount: number }>();
  
  for (const block of data.blocks) {
    blockMap.set(block.id, {
      block_name: block.name,
      total_payments: 0,
      total_amount: 0,
    });
  }

  for (const payment of data.payments) {
    if (payment.status === "paid" || payment.status === "pending") { // Could be just paid, let's include both for transparency or just paid. Wait, transparency usually shows actual paid amount.
      if (payment.status === "paid") {
        const blockStats = blockMap.get(payment.blockId);
        if (blockStats) {
          blockStats.total_payments += 1;
          blockStats.total_amount += payment.amount;
        }
      }
    }
  }

  const blocks = Array.from(blockMap.values()).filter(b => b.total_payments > 0);

  return Response.json({ blocks }, { status: 200 });
}
