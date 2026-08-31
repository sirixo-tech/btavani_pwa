import { getDashboardData } from "@/lib/repository";
import { saveCmsAction } from "@/app/admin/actions";
import { ImageUploader } from "@/app/components/admin/ImageUploader";

export default async function SettingsPage() {
  const data = await getDashboardData();
  const settings = data.cmsEntries.filter((entry) => entry.section === "app_setting");
  
  // We can treat "home_banner", "app_logo" etc as specific entries in app_setting
  const getSetting = (id: string) => settings.find(s => s.id === id) || {
    id, section: "app_setting", title: id.replace("_", " "), body: "", imageUrl: "", isPublished: true
  };

  const homeBanner = getSetting("home_banner");
  const appLogo = getSetting("app_logo");

  return (
    <>
      <div className="sm:flex sm:items-center mb-8">
        <div className="sm:flex-auto">
          <h2 className="text-2xl font-bold leading-7 text-zinc-900 sm:truncate sm:text-3xl sm:tracking-tight">
            PWA Settings & Assets
          </h2>
          <p className="mt-2 text-sm text-zinc-700">
            Configure global images and settings for the Flutter application.
          </p>
        </div>
      </div>

      <div className="grid gap-8 lg:grid-cols-2">
        <div className="bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl p-6">
          <h3 className="text-base font-semibold leading-6 text-zinc-900 border-b border-zinc-200 pb-4 mb-4">Home Banner</h3>
          <form action={saveCmsAction} className="space-y-4">
            <input type="hidden" name="id" value={homeBanner.id} />
            <input type="hidden" name="section" value="app_setting" />
            <input type="hidden" name="title" value={homeBanner.title} />
            <input type="hidden" name="isPublished" value="on" />
            <input type="hidden" name="imageUrl" value={homeBanner.imageUrl} />
            
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900 mb-2">Banner Image</label>
              <ImageUploader defaultImage={homeBanner.imageUrl} />
            </div>

            <div className="mt-6">
              <button type="submit" className="flex w-full justify-center rounded-md bg-zinc-900 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-zinc-800">
                Save Banner
              </button>
            </div>
          </form>
        </div>

        <div className="bg-white shadow-sm ring-1 ring-zinc-200 sm:rounded-xl p-6">
          <h3 className="text-base font-semibold leading-6 text-zinc-900 border-b border-zinc-200 pb-4 mb-4">App Logo</h3>
          <form action={saveCmsAction} className="space-y-4">
            <input type="hidden" name="id" value={appLogo.id} />
            <input type="hidden" name="section" value="app_setting" />
            <input type="hidden" name="title" value={appLogo.title} />
            <input type="hidden" name="isPublished" value="on" />
            <input type="hidden" name="imageUrl" value={appLogo.imageUrl} />
            
            <div>
              <label className="block text-sm font-medium leading-6 text-zinc-900 mb-2">Logo Image</label>
              <ImageUploader defaultImage={appLogo.imageUrl} />
            </div>

            <div className="mt-6">
              <button type="submit" className="flex w-full justify-center rounded-md bg-zinc-900 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-zinc-800">
                Save Logo
              </button>
            </div>
          </form>
        </div>
      </div>
    </>
  );
}
