import { getDashboardData } from "@/lib/repository";
import { updateRegistrationAction, deleteRegistrationAction } from "@/app/admin/actions";

export const dynamic = "force-dynamic";

export default async function RegistrationsPage({
  searchParams,
}: {
  searchParams?: Promise<{ q?: string; status?: string }>;
}) {
  const data = await getDashboardData();
  const statuses = ["new", "confirmed", "waitlisted", "cancelled"];
  
  const params = await searchParams;
  const q = params?.q?.toLowerCase() || "";
  const statusFilter = params?.status || "";
  
  const registrations = data.registrations.filter((reg) => {
    if (statusFilter && reg.status !== statusFilter) return false;
    if (q) {
      return reg.participantName.toLowerCase().includes(q) ||
             reg.flatNumber.toLowerCase().includes(q) ||
             reg.mobile.toLowerCase().includes(q) ||
             reg.eventTitle.toLowerCase().includes(q) ||
             reg.kidsName.toLowerCase().includes(q);
    }
    return true;
  });

  return (
    <>
      <div className="sm:flex sm:items-center mb-8">
        <div className="sm:flex-auto">
          <h2 className="text-2xl font-bold leading-7 text-zinc-900 sm:truncate sm:text-3xl sm:tracking-tight">
            Event Registrations
          </h2>
          <p className="mt-2 text-sm text-zinc-700">
            Manage registrations for events.
          </p>
        </div>
        
        <form className="mt-4 sm:ml-16 sm:mt-0 sm:flex-none flex flex-wrap gap-2 items-center">
          <input 
            name="q" 
            defaultValue={q} 
            placeholder="Search name, flat..." 
            className="block rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm"
          />
          <select 
            name="status" 
            defaultValue={statusFilter} 
            className="block rounded-md border-0 py-1.5 pl-3 pr-8 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm"
          >
            <option value="">All Statuses</option>
            {statuses.map(s => <option key={s} value={s}>{s}</option>)}
          </select>
          <button type="submit" className="rounded-md bg-white px-3 py-1.5 text-sm font-semibold text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 hover:bg-zinc-50">Filter</button>
        </form>
      </div>

      <div className="overflow-hidden bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-white text-[11px] font-bold uppercase tracking-wider text-zinc-500 border-b border-zinc-200">
              <tr>
                <th className="px-4 py-3">Participant</th>
                <th className="px-4 py-3">Details</th>
                <th className="px-4 py-3">Contact</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Update</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {registrations.map((reg) => (
                <tr key={reg.id} className="hover:bg-zinc-50/50">
                  <td className="px-4 py-3">
                    <p className="font-semibold text-zinc-900">
                      {reg.participantName}
                    </p>
                    <p className="text-xs text-zinc-500 mb-1">{reg.flatNumber}</p>
                    <span className="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-600/20">
                      {reg.personType}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <p className="font-medium text-zinc-900">{reg.eventTitle}</p>
                    {reg.kidsName && (
                      <p className="text-xs text-zinc-600 mt-1">Child: {reg.kidsName} ({reg.kidsAge})</p>
                    )}
                    {reg.otherPerformanceDetails && (
                      <p className="text-xs text-zinc-600 mt-1 line-clamp-2 max-w-xs">{reg.otherPerformanceDetails}</p>
                    )}
                  </td>
                  <td className="px-4 py-3 text-zinc-600">
                    <p>{reg.mobile}</p>
                    {reg.parentAdultPhone && <p className="text-xs mt-1">Alt: {reg.parentAdultPhone}</p>}
                  </td>
                  <td className="px-4 py-3">
                    <span className={`inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset ${
                      reg.status === 'confirmed' ? 'bg-green-50 text-green-700 ring-green-600/20' : 
                      reg.status === 'new' ? 'bg-yellow-50 text-yellow-800 ring-yellow-600/20' : 
                      reg.status === 'waitlisted' ? 'bg-orange-50 text-orange-800 ring-orange-600/20' :
                      'bg-red-50 text-red-700 ring-red-600/10'
                    }`}>
                      {reg.status}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <form action={updateRegistrationAction} className="flex flex-wrap gap-2 items-center" key={`${reg.id}-${reg.status}`}>
                      <input type="hidden" name="id" value={reg.id} />
                      <select name="status" defaultValue={reg.status} className="block rounded-md border-0 py-1 pl-3 pr-8 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-xs">
                        {statuses.map(s => <option key={s} value={s}>{s}</option>)}
                      </select>
                      <button className="rounded-md bg-white px-2 py-1 text-xs font-semibold text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 hover:bg-zinc-50">Save</button>
                      <button formAction={deleteRegistrationAction} className="text-red-500 hover:text-red-700 ml-1">
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
    </>
  );
}
