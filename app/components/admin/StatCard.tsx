export function StatCard({
  title,
  value,
  trend,
  icon: Icon,
}: {
  title: string;
  value: string;
  trend?: string;
  icon?: any;
}) {
  return (
    <div className="overflow-hidden rounded-xl bg-white px-4 py-5 shadow-sm border border-zinc-200 sm:p-6">
      <div className="flex items-center gap-4">
        {Icon && (
          <div className="rounded-lg bg-indigo-50 p-3">
            <Icon className="h-6 w-6 text-indigo-600" />
          </div>
        )}
        <div>
          <p className="truncate text-sm font-medium text-zinc-500">{title}</p>
          <div className="mt-1 flex items-baseline gap-2">
            <p className="text-2xl font-semibold text-zinc-900">{value}</p>
            {trend && (
              <p className="text-sm font-medium text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">{trend}</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
