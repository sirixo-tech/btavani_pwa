import { loginAdmin } from "@/app/admin/actions";
import { isAdminAuthenticated } from "@/lib/auth";
import { redirect } from "next/navigation";

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const params = await searchParams;
  const authenticated = await isAdminAuthenticated();

  if (authenticated) {
    redirect("/admin");
  }

  const invalid = params.error === "invalid";

  return (
    <main className="grid min-h-screen place-items-center bg-zinc-50 px-4 font-sans">
      <section className="w-full max-w-md rounded-xl border border-zinc-200 bg-white p-8 shadow-sm">
        <div className="grid size-12 place-items-center rounded-lg bg-zinc-900 text-lg font-bold text-white shadow-sm">
          BT
        </div>
        <h1 className="mt-6 text-2xl font-semibold tracking-tight text-zinc-900">
          Admin Login
        </h1>
        <p className="mt-2 text-sm font-medium text-zinc-500">
          Sign in to manage BT AVANI content, payments, QR setup and resident
          submissions.
        </p>
        <form action={loginAdmin} className="mt-6 space-y-4">
          <label className="block">
            <span className="mb-2 block text-sm font-medium text-zinc-900">Password</span>
            <input
              className="block w-full rounded-md border-0 py-2.5 text-zinc-900 shadow-sm ring-1 ring-inset ring-zinc-300 placeholder:text-zinc-400 focus:ring-2 focus:ring-inset focus:ring-zinc-900 sm:text-sm sm:leading-6 px-3"
              name="password"
              type="password"
              autoComplete="current-password"
              required
            />
          </label>
          {invalid && (
            <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm font-medium text-red-600">
              Invalid password.
            </p>
          )}
          <button className="flex w-full justify-center rounded-md bg-zinc-900 px-3 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-zinc-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-zinc-900">
            Open dashboard
          </button>
        </form>
      </section>
    </main>
  );
}
