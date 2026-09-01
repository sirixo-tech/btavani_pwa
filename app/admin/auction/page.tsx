import { getDashboardData } from "@/lib/repository";
import { revalidatePath } from "next/cache";
import { query } from "@/lib/db";
import { requireAdmin } from "@/lib/auth";

export const dynamic = "force-dynamic";

function money(value: number) {
  return `Rs ${new Intl.NumberFormat("en-IN").format(value)}`;
}

async function updateBidAction(formData: FormData) {
  "use server";
  await requireAdmin();
  const id = formData.get("id") as string;
  const status = formData.get("status") as string;
  if (id && status) {
    await query("update auction_bids set status = $2 where id = $1", [id, status]);
    revalidatePath("/admin/auction");
  }
}

export default async function AuctionPage() {
  const data = await getDashboardData();
  const bids = data.bids;

  return (
    <>
      <div className="sm:flex sm:items-center mb-8">
        <div className="sm:flex-auto">
          <h2 className="text-2xl font-bold leading-7 text-zinc-900 sm:truncate sm:text-3xl sm:tracking-tight">
            Laddoo Auction Manager
          </h2>
          <p className="mt-2 text-sm text-zinc-700">
            Track and manage bids for the Laddoo Auction.
          </p>
        </div>
      </div>

      <div className="overflow-hidden bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl">
        <div className="border-b border-zinc-200 bg-zinc-50 px-4 py-4 sm:px-6">
          <h3 className="text-base font-semibold leading-6 text-zinc-900">Current Bids</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-white text-[11px] font-bold uppercase tracking-wider text-zinc-500 border-b border-zinc-200">
              <tr>
                <th className="px-4 py-3">Bidder</th>
                <th className="px-4 py-3">Amount</th>
                <th className="px-4 py-3">Flat</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {bids.map((bid) => (
                <tr key={bid.id} className="hover:bg-zinc-50/50">
                  <td className="px-4 py-4 font-medium text-zinc-900">
                    <div>{bid.bidderName}</div>
                    <div className="text-xs text-zinc-500">{bid.mobile}</div>
                  </td>
                  <td className="px-4 py-4 text-zinc-600 font-semibold">{money(bid.amount)}</td>
                  <td className="px-4 py-4 text-zinc-600">{bid.flatNumber}</td>
                  <td className="px-4 py-4">
                    <span className={`inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset ${
                      bid.status === 'leading' ? 'bg-green-50 text-green-700 ring-green-600/20' : 
                      bid.status === 'outbid' ? 'bg-yellow-50 text-yellow-800 ring-yellow-600/20' : 
                      'bg-red-50 text-red-700 ring-red-600/10'
                    }`}>
                      {bid.status}
                    </span>
                  </td>
                  <td className="px-4 py-4">
                    <form action={updateBidAction} className="flex gap-2 items-center">
                      <input type="hidden" name="id" value={bid.id} />
                      <select 
                        name="status" 
                        defaultValue={bid.status}
                        className="block w-24 rounded-md border-0 py-1 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-xs sm:leading-6"
                      >
                        <option value="leading">Leading</option>
                        <option value="outbid">Outbid</option>
                        <option value="cancelled">Cancelled</option>
                      </select>
                      <button type="submit" className="text-xs text-indigo-600 hover:text-indigo-900 font-semibold">
                        Save
                      </button>
                    </form>
                  </td>
                </tr>
              ))}
              {bids.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-4 py-8 text-center text-zinc-500">No bids yet</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
