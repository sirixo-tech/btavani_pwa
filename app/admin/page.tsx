import { getDashboardData } from "@/lib/repository";
import { StatCard } from "@/app/components/admin/StatCard";
import {
  UsersIcon,
  BanknotesIcon,
  CheckBadgeIcon
} from "@heroicons/react/24/outline";

function money(value: number) {
  return `Rs ${new Intl.NumberFormat("en-IN").format(value)}`;
}

export default async function AdminDashboardPage() {
  const data = await getDashboardData();
  const events = data.cmsEntries.filter((entry) => entry.section === "event");

  return (
    <>
      <div className="md:flex md:items-center md:justify-between border-b border-zinc-200 pb-5">
        <div className="min-w-0 flex-1">
          <h2 className="text-3xl font-bold leading-7 text-zinc-900 sm:truncate sm:tracking-tight">
            Dashboard Overview
          </h2>
          <p className="mt-2 text-sm text-zinc-500">
            A summary of your collections, payments, and events.
          </p>
        </div>
      </div>

      <dl className="mt-8 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Collected"
          value={money(data.totals.collected)}
          icon={BanknotesIcon}
        />
        <StatCard
          title="Pending Payments"
          value={money(data.totals.pending)}
          icon={BanknotesIcon}
        />
        <StatCard
          title="Registrations"
          value={String(data.totals.registrations)}
          icon={UsersIcon}
          trend={`${events.length} events`}
        />
        <StatCard
          title="Volunteers"
          value={String(data.totals.volunteers)}
          icon={CheckBadgeIcon}
        />
      </dl>

      {/* Recent Activity Table */}
      <div className="mt-10 flex items-center justify-between">
        <h3 className="text-xl font-semibold leading-6 text-zinc-900">Recent Payments</h3>
        <a href="/admin/payments" className="text-sm font-semibold text-indigo-600 hover:text-indigo-500 transition-colors">
          View all <span aria-hidden="true">&rarr;</span>
        </a>
      </div>
      <div className="mt-6 flex flex-col">
        <div className="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
            <div className="overflow-hidden shadow-sm ring-1 ring-zinc-200 md:rounded-xl">
              <table className="min-w-full divide-y divide-zinc-200">
                <thead className="bg-zinc-50 border-b border-zinc-200">
                  <tr>
                    <th scope="col" className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-zinc-900 sm:pl-6">Resident Name</th>
                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-zinc-900">Amount</th>
                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-zinc-900">Block</th>
                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-zinc-900">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-200 bg-white">
                  {data.payments.slice(0, 5).map((payment) => (
                    <tr key={payment.id}>
                      <td className="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-zinc-900 sm:pl-6">{payment.residentName}</td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm text-zinc-500">{money(payment.amount)}</td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm text-zinc-500">{payment.blockName}</td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm text-zinc-500">
                        <span className={`inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset ${
                          payment.status === 'paid' ? 'bg-green-50 text-green-700 ring-green-600/20' : 
                          payment.status === 'pending' ? 'bg-yellow-50 text-yellow-800 ring-yellow-600/20' : 
                          'bg-red-50 text-red-700 ring-red-600/10'
                        }`}>
                          {payment.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                  {data.payments.length === 0 && (
                    <tr>
                      <td colSpan={4} className="whitespace-nowrap py-4 pl-4 pr-3 text-sm text-center text-zinc-500 sm:pl-6">No recent payments</td>
                    </tr>
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
