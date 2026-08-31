import { getDashboardData } from "@/lib/repository";

export default async function MembersPage() {
  const data = await getDashboardData();

  return (
    <>
      <div className="sm:flex sm:items-center mb-8">
        <div className="sm:flex-auto">
          <h2 className="text-2xl font-bold leading-7 text-zinc-900 sm:truncate sm:text-3xl sm:tracking-tight">
            Members & Volunteers
          </h2>
          <p className="mt-2 text-sm text-zinc-700">
            View all app registrations, volunteers, and auction bids.
          </p>
        </div>
      </div>

      <div className="space-y-12">
        <div>
          <h3 className="text-lg font-medium leading-6 text-zinc-900 mb-4">Event Registrations</h3>
          <div className="overflow-hidden bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-zinc-50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 border-b border-zinc-200">
                  <tr>
                    <th className="px-4 py-3">Participant</th>
                    <th className="px-4 py-3">Event</th>
                    <th className="px-4 py-3">Flat</th>
                    <th className="px-4 py-3">Mobile</th>
                    <th className="px-4 py-3">Age Group</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100">
                  {data.registrations.map((item) => (
                    <tr key={item.id} className="hover:bg-zinc-50/50">
                      <td className="px-4 py-3 font-medium text-zinc-900">{item.participantName}</td>
                      <td className="px-4 py-3 text-zinc-600">{item.eventTitle}</td>
                      <td className="px-4 py-3 text-zinc-600">{item.flatNumber}</td>
                      <td className="px-4 py-3 text-zinc-600">{item.mobile}</td>
                      <td className="px-4 py-3 text-zinc-600">{item.ageGroup}</td>
                    </tr>
                  ))}
                  {data.registrations.length === 0 && (
                    <tr><td colSpan={5} className="px-4 py-8 text-center text-zinc-500">No registrations found</td></tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div>
          <h3 className="text-lg font-medium leading-6 text-zinc-900 mb-4">Volunteers</h3>
          <div className="overflow-hidden bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-zinc-50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 border-b border-zinc-200">
                  <tr>
                    <th className="px-4 py-3">Name</th>
                    <th className="px-4 py-3">Flat</th>
                    <th className="px-4 py-3">Mobile</th>
                    <th className="px-4 py-3">Roles</th>
                    <th className="px-4 py-3">Notes</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100">
                  {data.volunteers.map((item) => (
                    <tr key={item.id} className="hover:bg-zinc-50/50">
                      <td className="px-4 py-3 font-medium text-zinc-900">{item.name}</td>
                      <td className="px-4 py-3 text-zinc-600">{item.flatNumber}</td>
                      <td className="px-4 py-3 text-zinc-600">{item.mobile}</td>
                      <td className="px-4 py-3 text-zinc-600">{item.roles.join(", ")}</td>
                      <td className="px-4 py-3 text-zinc-600 max-w-xs truncate">{item.note}</td>
                    </tr>
                  ))}
                  {data.volunteers.length === 0 && (
                    <tr><td colSpan={5} className="px-4 py-8 text-center text-zinc-500">No volunteers found</td></tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div>
          <h3 className="text-lg font-medium leading-6 text-zinc-900 mb-4">Auction Bids</h3>
          <div className="overflow-hidden bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-zinc-50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 border-b border-zinc-200">
                  <tr>
                    <th className="px-4 py-3">Bidder</th>
                    <th className="px-4 py-3">Amount</th>
                    <th className="px-4 py-3">Item</th>
                    <th className="px-4 py-3">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100">
                  {data.bids.map((item) => (
                    <tr key={item.id} className="hover:bg-zinc-50/50">
                      <td className="px-4 py-3 font-medium text-zinc-900">{item.bidderName || "Anonymous"} <span className="text-xs text-zinc-500">({item.flatNumber})</span></td>
                      <td className="px-4 py-3 font-semibold text-zinc-900">Rs {item.amount}</td>
                      <td className="px-4 py-3 text-zinc-600">{item.itemTitle}</td>
                      <td className="px-4 py-3">
                        <span className={`inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset ${
                          item.status === 'leading' ? 'bg-indigo-50 text-indigo-700 ring-indigo-600/20' : 'bg-zinc-50 text-zinc-600 ring-zinc-500/20'
                        }`}>
                          {item.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                  {data.bids.length === 0 && (
                    <tr><td colSpan={4} className="px-4 py-8 text-center text-zinc-500">No bids found</td></tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
