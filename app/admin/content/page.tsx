import { getDashboardData } from "@/lib/repository";
import { saveCmsAction, deleteCmsAction } from "@/app/admin/actions";
import { ImageUploader } from "@/app/components/admin/ImageUploader";

export default async function ContentPage() {
  const data = await getDashboardData();
  const content = data.cmsEntries.filter((entry) => 
    ["schedule", "announcement", "gallery", "volunteer_role"].includes(entry.section)
  );

  const sections = ["schedule", "announcement", "gallery", "volunteer_role"];

  return (
    <>
      <div className="sm:flex sm:items-center mb-8">
        <div className="sm:flex-auto">
          <h2 className="text-2xl font-bold leading-7 text-zinc-900 sm:truncate sm:text-3xl sm:tracking-tight">
            PWA Content Manager
          </h2>
          <p className="mt-2 text-sm text-zinc-700">
            Manage announcements, schedule, gallery, and volunteer roles.
          </p>
        </div>
      </div>

      <div className="grid gap-8 xl:grid-cols-[1fr_1fr]">
        <div className="space-y-6">
          {sections.map((sec) => {
            const sectionEntries = content.filter(e => e.section === sec);
            return (
              <div key={sec}>
                <h3 className="text-lg font-medium leading-6 text-zinc-900 mb-4 capitalize">{sec.replace("_", " ")}</h3>
                <div className="grid gap-4">
                  {sectionEntries.map((entry) => (
                    <div key={entry.id} className="flex gap-4 p-4 bg-white rounded-xl shadow-sm border border-zinc-200">
                      {entry.imageUrl && (
                        <img src={entry.imageUrl} alt="" className="w-20 h-20 object-cover rounded-lg shrink-0" />
                      )}
                      <div className="flex-1 min-w-0">
                        <div className="flex justify-between">
                          <h4 className="text-sm font-semibold text-zinc-900 truncate">{entry.title}</h4>
                          <form action={deleteCmsAction}>
                            <input type="hidden" name="id" value={entry.id} />
                            <button className="text-xs text-red-600 hover:text-red-500 font-medium">Delete</button>
                          </form>
                        </div>
                        <p className="text-xs text-zinc-500 mt-1 truncate">{entry.subtitle || entry.label}</p>
                        <p className="text-xs text-zinc-600 mt-2 line-clamp-2">{entry.body}</p>
                      </div>
                    </div>
                  ))}
                  {sectionEntries.length === 0 && (
                    <div className="text-sm text-zinc-500 py-4 italic">No items in this section</div>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        <div className="bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl p-6 h-fit sticky top-8">
          <h3 className="text-base font-semibold leading-6 text-zinc-900 border-b border-zinc-200 pb-4 mb-4">Add Content Item</h3>
          <form action={saveCmsAction} className="space-y-4">
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Section</label>
              <select name="section" className="mt-1 block w-full rounded-md border-0 py-1.5 pl-3 pr-8 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm">
                {sections.map(s => <option key={s} value={s}>{s.replace("_", " ")}</option>)}
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Title</label>
              <input required name="title" className="mt-1 block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm" />
            </div>

            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Subtitle / Label</label>
              <input name="subtitle" className="mt-1 block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm" />
            </div>

            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900">Body</label>
              <textarea name="body" rows={3} className="mt-1 block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm" />
            </div>

            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900 mb-2">Image</label>
              <ImageUploader />
            </div>

            <div className="flex items-center gap-3 mt-4">
              <input type="checkbox" name="isPublished" defaultChecked className="h-4 w-4 rounded border-zinc-300 text-indigo-600 focus:ring-indigo-600" />
              <label className="text-sm font-medium leading-6 text-zinc-900">Published</label>
            </div>

            <div className="mt-6">
              <button type="submit" className="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500">
                Save Content
              </button>
            </div>
          </form>
        </div>
      </div>
    </>
  );
}
