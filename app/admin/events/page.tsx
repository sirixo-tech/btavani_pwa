import { getDashboardData } from "@/lib/repository";
import { saveCmsAction, deleteCmsAction } from "@/app/admin/actions";
import { ImageUploader } from "@/app/components/admin/ImageUploader";

function formatDate(dateStr: string) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleString("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

export default async function EventsPage() {
  const data = await getDashboardData();
  const events = data.cmsEntries.filter((entry) => entry.section === "event");

  return (
    <>
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h2 className="text-2xl font-bold leading-7 text-zinc-900 sm:truncate sm:text-3xl sm:tracking-tight">
            Events Manager
          </h2>
          <p className="mt-2 text-sm text-zinc-700">
            Create, edit, and delete events shown in the Flutter PWA.
          </p>
        </div>
      </div>

      <div className="mt-8 grid gap-8 xl:grid-cols-[1.2fr_0.8fr]">
        <div className="space-y-4">
          <h3 className="text-lg font-medium leading-6 text-zinc-900">Upcoming Events</h3>
          <div className="grid gap-6">
            {events.map((event) => (
              <div key={event.id} className="overflow-hidden bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl">
                <div className="flex border-b border-zinc-200 bg-zinc-50 px-4 py-4 sm:px-6 items-center justify-between">
                  <h3 className="text-base font-semibold leading-6 text-zinc-900">{event.title}</h3>
                  <div className="flex gap-2">
                    <span className={`inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset ${
                      event.isPublished ? 'bg-green-50 text-green-700 ring-green-600/20' : 'bg-yellow-50 text-yellow-800 ring-yellow-600/20'
                    }`}>
                      {event.isPublished ? 'Published' : 'Draft'}
                    </span>
                    <form action={deleteCmsAction}>
                      <input type="hidden" name="id" value={event.id} />
                      <button className="text-sm font-semibold text-red-600 hover:text-red-500">Delete</button>
                    </form>
                  </div>
                </div>
                <div className="px-4 py-5 sm:p-6 flex flex-col md:flex-row gap-6">
                  {event.imageUrl && (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={event.imageUrl} alt={event.title} className="w-full md:w-48 h-32 object-cover rounded-lg" />
                  )}
                  <div className="flex-1 text-sm text-zinc-700">
                    <p className="font-semibold mb-2">{event.subtitle || "No subtitle"}</p>
                    <p className="mb-4">{event.body || "No description"}</p>
                    <div className="grid grid-cols-2 gap-4 text-xs">
                      <div>
                        <span className="font-semibold text-zinc-900">Date/Time:</span>
                        <p>{formatDate(event.startsAt) || "TBD"}</p>
                      </div>
                      <div>
                        <span className="font-semibold text-zinc-900">Venue:</span>
                        <p>{event.venue || "TBD"}</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
            {events.length === 0 && (
              <div className="rounded-xl border-2 border-dashed border-zinc-300 p-12 text-center">
                <h3 className="mt-2 text-sm font-semibold text-zinc-900">No events</h3>
                <p className="mt-1 text-sm text-zinc-500">Get started by creating a new event.</p>
              </div>
            )}
          </div>
        </div>

        <div>
          <div className="bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl p-6 sticky top-8">
            <h3 className="text-lg font-medium leading-6 text-zinc-900 border-b border-zinc-200 pb-4 mb-4">Create New Event</h3>
            <form action={saveCmsAction} className="space-y-4">
              <input type="hidden" name="section" value="event" />
              <input type="hidden" name="color" value="#8E1119" />
              
              <div>
                <label className="block text-sm font-medium leading-6 text-zinc-900">Event Title</label>
                <div className="mt-2">
                  <input required name="title" className="block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6" />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium leading-6 text-zinc-900">Subtitle (Optional)</label>
                <div className="mt-2">
                  <input name="subtitle" className="block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6" />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium leading-6 text-zinc-900">Description</label>
                <div className="mt-2">
                  <textarea name="body" rows={3} className="block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6" />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium leading-6 text-zinc-900">Starts At</label>
                  <div className="mt-2">
                    <input type="datetime-local" name="startsAt" className="block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6" />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium leading-6 text-zinc-900">Venue</label>
                  <div className="mt-2">
                    <input name="venue" className="block w-full rounded-md border-0 py-1.5 px-3 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6" />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium leading-6 text-zinc-900 mb-2">Event Image</label>
                <ImageUploader />
              </div>

              <div className="flex items-center gap-3 mt-4">
                <input type="checkbox" name="isPublished" defaultChecked className="h-4 w-4 rounded border-zinc-300 text-indigo-600 focus:ring-indigo-600" />
                <label className="text-sm font-medium leading-6 text-zinc-900">Publish immediately</label>
              </div>

              <div className="mt-6">
                <button type="submit" className="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
                  Save Event
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </>
  );
}
