import { getDashboardData } from "@/lib/repository";
import { createPaymentAction, updatePaymentAction, deletePaymentAction } from "@/app/admin/actions";

function money(value: number) {
  return `Rs ${new Intl.NumberFormat("en-IN").format(value)}`;
}

export default async function PaymentsPage() {
  const data = await getDashboardData();
  const statuses = ["created", "pending", "paid", "failed", "refunded"];
  const providers = [
    ["upi_qr", "UPI / uploaded QR"],
    ["razorpay", "Razorpay integration"],
    ["manual", "Manual collection"],
  ];

  return (
    <>
      <div className="sm:flex sm:items-center mb-8">
        <div className="sm:flex-auto">
          <h2 className="text-2xl font-bold leading-7 text-zinc-900 sm:truncate sm:text-3xl sm:tracking-tight">
            Payments Manager
          </h2>
          <p className="mt-2 text-sm text-zinc-700">
            Track and update all incoming contributions.
          </p>
        </div>
      </div>

      <div className="grid gap-8 lg:grid-cols-[1.3fr_0.7fr]">
        <div className="overflow-hidden bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl">
          <div className="border-b border-zinc-200 bg-zinc-50 px-4 py-4 sm:px-6">
            <h3 className="text-base font-semibold leading-6 text-zinc-900">Recent Transactions</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-white text-[11px] font-bold uppercase tracking-wider text-zinc-500 border-b border-zinc-200">
                <tr>
                  <th className="px-4 py-3">Resident</th>
                  <th className="px-4 py-3">Amount</th>
                  <th className="px-4 py-3">Status</th>
                  <th className="px-4 py-3">Update</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100">
                {data.payments.map((payment) => (
                  <tr key={payment.id} className="hover:bg-zinc-50/50">
                    <td className="px-4 py-3">
                      <p className="font-semibold text-zinc-900">
                        {payment.residentName}
                        {payment.screenshotUrl && (
                          <a href={payment.screenshotUrl} target="_blank" rel="noopener noreferrer" className="ml-2 text-indigo-600 hover:text-indigo-900 text-xs font-normal">
                            (View Screenshot)
                          </a>
                        )}
                      </p>
                      <p className="text-xs text-zinc-500">{payment.blockName} • {payment.flatNumber}</p>
                    </td>
                    <td className="px-4 py-3 font-semibold text-zinc-900">{money(payment.amount)}</td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset ${
                        payment.status === 'paid' ? 'bg-green-50 text-green-700 ring-green-600/20' : 
                        payment.status === 'pending' ? 'bg-yellow-50 text-yellow-800 ring-yellow-600/20' : 
                        'bg-red-50 text-red-700 ring-red-600/10'
                      }`}>
                        {payment.status}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <form action={updatePaymentAction} className="flex flex-wrap gap-2 items-center">
                        <input type="hidden" name="id" value={payment.id} />
                        <select name="status" defaultValue={payment.status} className="block rounded-md border-0 py-1 pl-3 pr-8 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-xs">
                          {statuses.map(s => <option key={s} value={s}>{s}</option>)}
                        </select>
                        <input name="referenceId" defaultValue={payment.referenceId} placeholder="Ref ID" className="block w-24 rounded-md border-0 py-1 px-2 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-xs" />
                        <button className="rounded-md bg-white px-2 py-1 text-xs font-semibold text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 hover:bg-zinc-50">Save</button>
                        <button formAction={deletePaymentAction} className="text-red-500 hover:text-red-700 ml-1">
                          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                        </button>
                      </form>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl p-6 h-fit sticky top-8">
          <h3 className="text-base font-semibold leading-6 text-zinc-900 border-b border-zinc-200 pb-4 mb-4">Record Manual Payment</h3>
          <form action={createPaymentAction} className="space-y-4">
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Resident Name</label>
              <input required name="residentName" className="mt-1 block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm" />
            </div>
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Amount</label>
              <input required type="number" name="amount" className="mt-1 block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm" />
            </div>
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Block</label>
              <select name="blockId" className="mt-1 block w-full rounded-md border-0 py-1.5 pl-3 pr-8 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm">
                {data.blocks.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Provider</label>
              <select name="provider" className="mt-1 block w-full rounded-md border-0 py-1.5 pl-3 pr-8 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm">
                {providers.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Status</label>
              <select name="status" className="mt-1 block w-full rounded-md border-0 py-1.5 pl-3 pr-8 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm">
                {statuses.map(s => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>
            <button type="submit" className="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 mt-6">
              Record Payment
            </button>
          </form>
        </div>
      </div>
    </>
  );
}
