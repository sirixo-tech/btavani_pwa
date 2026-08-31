import { getDashboardData } from "@/lib/repository";
import { BlockForm } from "@/app/admin/BlockForm";

export default async function BlocksPage() {
  const data = await getDashboardData();

  return (
    <>
      <div className="sm:flex sm:items-center mb-8">
        <div className="sm:flex-auto">
          <h2 className="text-2xl font-bold leading-7 text-zinc-900 sm:truncate sm:text-3xl sm:tracking-tight">
            Blocks & QR Configuration
          </h2>
          <p className="mt-2 text-sm text-zinc-700">
            Configure payment providers and QR codes for each block.
          </p>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2 2xl:grid-cols-3">
        {data.blocks.map((block) => (
          <BlockForm key={block.id} block={block} />
        ))}
      </div>
    </>
  );
}
