import { hasDatabase } from "@/lib/db";
import { hasConfiguredAdminPassword, isAdminAuthenticated } from "@/lib/auth";
import { getDashboardData } from "@/lib/repository";
import {
  clearDemoDataAction,
  createPaymentAction,
  loginAdmin,
  logoutAdmin,
  saveBlockAction,
  saveCmsAction,
  updatePaymentAction,
} from "./actions";
import type { Block, CmsEntry, Payment } from "@/lib/types";

export const dynamic = "force-dynamic";

const sections = [
  "event",
  "schedule",
  "announcement",
  "gallery",
  "volunteer_role",
  "app_setting",
];

const providers = [
  ["upi_qr", "UPI / uploaded QR"],
  ["razorpay", "Razorpay integration"],
  ["manual", "Manual collection"],
];

const statuses = ["created", "pending", "paid", "failed", "refunded"];

function money(value: number) {
  return `Rs ${new Intl.NumberFormat("en-IN").format(value)}`;
}

function formatDate(value: string) {
  if (!value) return "Not set";
  return new Intl.DateTimeFormat("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
}

export default async function AdminPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const params = await searchParams;
  const authenticated = await isAdminAuthenticated();

  if (!authenticated) {
    return <LoginScreen invalid={params.error === "invalid"} />;
  }

  const data = await getDashboardData();
  const events = data.cmsEntries.filter((entry) => entry.section === "event");
  const announcements = data.cmsEntries.filter(
    (entry) => entry.section === "announcement",
  );
  const leadingBid = data.bids[0];

  return (
    <main className="min-h-screen bg-zinc-50 text-zinc-900 font-sans">
      <div className="mx-auto flex max-w-[1480px] gap-0 xl:gap-8">
        <aside className="sticky top-0 hidden h-screen w-64 shrink-0 flex-col border-r border-zinc-200 bg-zinc-50/50 px-6 py-8 xl:flex">
          <div className="flex items-center gap-3">
            <div className="grid size-10 place-items-center rounded-lg bg-zinc-900 text-sm font-bold text-white shadow-sm">
              BT
            </div>
            <div>
              <p className="text-sm font-bold text-zinc-900">BT AVANI</p>
              <p className="text-xs font-medium text-zinc-500">
                Festival Admin
              </p>
            </div>
          </div>
          <nav className="mt-10 space-y-1 text-sm font-medium text-zinc-600">
            {[
              "Overview",
              "Payments",
              "Block QR",
              "CMS",
              "Registrations",
              "Volunteers",
              "Auction",
            ].map((item) => (
              <a
                key={item}
                href={`#${item.toLowerCase().replace(" ", "-")}`}
                className="block rounded-md px-3 py-2 hover:bg-zinc-100 hover:text-zinc-900 transition-colors"
              >
                {item}
              </a>
            ))}
          </nav>
          <div className="mt-auto space-y-4">
            <div className="rounded-lg border border-zinc-200 bg-white p-4 shadow-sm">
              <p className="text-[10px] font-bold uppercase tracking-wider text-zinc-500">
                System Status
              </p>
              <div className="mt-3 flex items-center gap-2">
                <div className={`size-2 rounded-full ${hasDatabase() ? 'bg-emerald-500' : 'bg-amber-500'}`} />
                <p className="text-xs font-medium text-zinc-700">
                  {hasDatabase() ? "PostgreSQL Connected" : "Local Preview"}
                </p>
              </div>
              <div className="mt-2 flex items-center gap-2">
                <div className={`size-2 rounded-full ${process.env.REDIS_URL ? 'bg-emerald-500' : 'bg-zinc-300'}`} />
                <p className="text-xs font-medium text-zinc-700">
                  {process.env.REDIS_URL ? "Redis Active" : "Redis Pending"}
                </p>
              </div>
            </div>
            <form action={clearDemoDataAction} onSubmit={(e) => {
              if(!confirm('WARNING: This will permanently delete ALL data (events, schedules, payments, etc.) from the database. Are you sure?')) e.preventDefault();
            }}>
              <button className="danger-button w-full text-xs py-2 min-h-0">
                Clear Demo Data
              </button>
            </form>
          </div>
        </aside>

        <section className="min-w-0 flex-1 px-4 py-8 sm:px-6 lg:px-8">
          <header className="rounded-xl border border-zinc-200 bg-white p-6 shadow-sm">
            <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
              <div>
                <p className="text-[11px] font-bold uppercase tracking-widest text-zinc-500">
                  Avani Ganesh Utsav 2026
                </p>
                <h1 className="mt-1 text-2xl font-semibold tracking-tight text-zinc-900">
                  Operations Dashboard
                </h1>
                <p className="mt-1 max-w-2xl text-sm font-medium text-zinc-500">
                  Manage mobile app content, block payment setups, registrations, volunteers, and auction bids.
                </p>
              </div>
              <form action={logoutAdmin}>
                <button className="rounded-md border border-zinc-200 px-4 py-2 text-sm font-medium text-zinc-700 hover:bg-zinc-50 transition-colors">
                  Sign out
                </button>
              </form>
            </div>
            {!hasConfiguredAdminPassword() && (
              <div className="mt-6 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm font-medium text-amber-800 flex items-center gap-2">
                <svg className="size-5 text-amber-600 shrink-0" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
                Please set ADMIN_PASSWORD in your environment variables for production security.
              </div>
            )}
          </header>

          <section
            id="overview"
            className="mt-5 grid gap-4 sm:grid-cols-2 xl:grid-cols-4"
          >
            <StatCard
              label="Collected"
              value={money(data.totals.collected)}
              detail="Paid contributions"
            />
            <StatCard
              label="Pending"
              value={money(data.totals.pending)}
              detail="Awaiting reconciliation"
            />
            <StatCard
              label="Registrations"
              value={String(data.totals.registrations)}
              detail={`${events.length} managed events`}
            />
            <StatCard
              label="Volunteers"
              value={String(data.totals.volunteers)}
              detail="Submitted preferences"
            />
          </section>

          <section className="mt-5 grid gap-5 xl:grid-cols-[1.3fr_0.7fr]">
            <Panel
              id="payments"
              title="Payments"
              subtitle="Track every UPI, Razorpay or manual contribution."
            >
              <div className="grid gap-4 lg:grid-cols-[0.8fr_1.2fr]">
                <CreatePaymentForm blocks={data.blocks} />
                <PaymentTable payments={data.payments} />
              </div>
            </Panel>

            <Panel title="Live pulse" subtitle="A quick health read for admins.">
              <div className="space-y-3">
                <PulseRow
                  label="Active blocks"
                  value={String(data.blocks.filter((block) => block.isActive).length)}
                />
                <PulseRow
                  label="Published announcements"
                  value={String(
                    announcements.filter((entry) => entry.isPublished).length,
                  )}
                />
                <PulseRow
                  label="Leading bid"
                  value={leadingBid ? money(leadingBid.amount) : "No bids"}
                />
                <PulseRow
                  label="Mobile cache"
                  value={process.env.REDIS_URL ? "Redis enabled" : "Redis pending"}
                />
              </div>
            </Panel>
          </section>

          <Panel
            id="block-qr"
            title="Seven-block QR and payment integration"
            subtitle="Choose generated UPI QR, uploaded QR image, Razorpay payment link, or manual collection per block."
          >
            <div className="grid gap-4 lg:grid-cols-2 2xl:grid-cols-3">
              {data.blocks.map((block) => (
                <BlockForm key={block.id} block={block} />
              ))}
            </div>
          </Panel>

          <Panel
            id="cms"
            title="CMS content manager"
            subtitle="Publish and edit everything the Flutter app needs: events, schedule, announcements, gallery, roles and settings."
          >
            <div className="grid gap-4 xl:grid-cols-[0.85fr_1.15fr]">
              <CmsForm />
              <CmsList entries={data.cmsEntries} />
            </div>
          </Panel>

          <section className="mt-5 grid gap-5 xl:grid-cols-3">
            <Panel
              id="registrations"
              title="Participate registrations"
              subtitle="New app registrations arrive here."
            >
              <CompactTable
                headers={["Participant", "Event", "Flat", "Status"]}
                rows={data.registrations.map((item) => [
                  item.participantName,
                  item.eventTitle,
                  item.flatNumber,
                  item.status,
                ])}
              />
            </Panel>
            <Panel
              id="volunteers"
              title="Volunteers"
              subtitle="Volunteer interests from the mobile app."
            >
              <CompactTable
                headers={["Name", "Flat", "Roles"]}
                rows={data.volunteers.map((item) => [
                  item.name,
                  item.flatNumber,
                  item.roles.join(", "),
                ])}
              />
            </Panel>
            <Panel
              id="auction"
              title="Laddoo auction"
              subtitle="Bid stream and current leader."
            >
              <CompactTable
                headers={["Bidder", "Amount", "Flat", "Status"]}
                rows={data.bids.map((item) => [
                  item.bidderName || "Resident",
                  money(item.amount),
                  item.flatNumber,
                  item.status,
                ])}
              />
            </Panel>
          </section>
        </section>
      </div>
    </main>
  );
}

function LoginScreen({ invalid }: { invalid: boolean }) {
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
            <span className="label">Password</span>
            <input
              className="input"
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
          <button className="primary-button w-full">Open dashboard</button>
        </form>
      </section>
    </main>
  );
}

function StatCard({
  label,
  value,
  detail,
}: {
  label: string;
  value: string;
  detail: string;
}) {
  return (
    <article className="rounded-xl border border-zinc-200 bg-white p-6 shadow-sm">
      <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500">
        {label}
      </p>
      <p className="mt-2 text-3xl font-semibold tracking-tight text-zinc-900">{value}</p>
      <p className="mt-1 text-sm font-medium text-zinc-500">{detail}</p>
    </article>
  );
}

function Panel({
  id,
  title,
  subtitle,
  children,
}: {
  id?: string;
  title: string;
  subtitle: string;
  children: React.ReactNode;
}) {
  return (
    <section
      id={id}
      className="mt-6 rounded-xl border border-zinc-200 bg-white shadow-sm overflow-hidden"
    >
      <div className="border-b border-zinc-100 bg-zinc-50/50 px-6 py-5">
        <h2 className="text-lg font-semibold text-zinc-900">{title}</h2>
        <p className="mt-1 text-sm font-medium text-zinc-500">{subtitle}</p>
      </div>
      <div className="p-6">
        {children}
      </div>
    </section>
  );
}

function PulseRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between rounded-lg border border-zinc-100 bg-zinc-50 px-4 py-3">
      <span className="text-sm font-medium text-zinc-600">{label}</span>
      <span className="text-sm font-semibold text-zinc-900">{value}</span>
    </div>
  );
}

function CreatePaymentForm({ blocks }: { blocks: Block[] }) {
  return (
    <form action={createPaymentAction} className="rounded-lg border border-zinc-100 bg-zinc-50 p-5">
      <h3 className="text-[11px] font-bold uppercase tracking-wider text-zinc-500">
        Record Offline Payment
      </h3>
      <div className="mt-4 grid gap-4 sm:grid-cols-2">
        <Input name="residentName" label="Resident name" required />
        <Input name="amount" label="Amount" type="number" required />
        <Select
          name="blockId"
          label="Block"
          options={blocks.map((block) => [block.id, block.name])}
        />
        <Select name="provider" label="Provider" options={providers} />
        <Select
          name="status"
          label="Status"
          options={statuses.map((status) => [status, status])}
        />
        <Input name="referenceId" label="Reference ID" />
        <Input name="phone" label="Phone" />
        <Input name="flatNumber" label="Flat" />
      </div>
      <button className="primary-button mt-4">Record payment</button>
    </form>
  );
}

function PaymentTable({ payments }: { payments: Payment[] }) {
  return (
    <div className="overflow-x-auto rounded-lg border border-zinc-100">
      <table className="w-full min-w-[780px] text-left text-sm">
        <thead className="bg-zinc-50 text-[11px] font-bold uppercase tracking-wider text-zinc-500">
          <tr>
            <th className="table-head">Resident</th>
            <th className="table-head">Block</th>
            <th className="table-head">Amount</th>
            <th className="table-head">Status</th>
            <th className="table-head">Reference</th>
            <th className="table-head">Update</th>
          </tr>
        </thead>
        <tbody>
          {payments.map((payment) => (
            <tr key={payment.id} className="border-b border-zinc-100 last:border-0 hover:bg-zinc-50/50 transition-colors">
              <td className="table-cell">
                <p className="font-semibold text-zinc-900">{payment.residentName}</p>
                <p className="mt-0.5 text-xs text-zinc-500">
                  {payment.flatNumber} • {formatDate(payment.createdAt)}
                </p>
              </td>
              <td className="table-cell text-zinc-600">{payment.blockName}</td>
              <td className="table-cell font-semibold text-zinc-900">{money(payment.amount)}</td>
              <td className="table-cell">
                <span className="inline-flex items-center rounded-md bg-zinc-100 px-2 py-1 text-xs font-medium text-zinc-800 ring-1 ring-inset ring-zinc-200">
                  {payment.status}
                </span>
              </td>
              <td className="table-cell text-zinc-600">{payment.referenceId || "Pending"}</td>
              <td className="table-cell">
                <form action={updatePaymentAction} className="flex gap-2">
                  <input type="hidden" name="id" value={payment.id} />
                  <select
                    className="mini-input"
                    name="status"
                    defaultValue={payment.status}
                  >
                    {statuses.map((status) => (
                      <option key={status} value={status}>
                        {status}
                      </option>
                    ))}
                  </select>
                  <input
                    className="mini-input w-28"
                    name="referenceId"
                    defaultValue={payment.referenceId}
                    placeholder="Ref"
                  />
                  <button className="mini-button">Save</button>
                </form>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function BlockForm({ block }: { block: Block }) {
  return (
    <form
      action={saveBlockAction}
      className="rounded-lg border border-zinc-200 bg-white p-5 shadow-sm transition-shadow hover:shadow-md"
    >
      <input type="hidden" name="id" value={block.id} />
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-base font-semibold text-zinc-900">{block.name}</h3>
          <p className="text-xs font-medium text-zinc-500">
            QR and payment destination
          </p>
        </div>
        <label className="flex items-center gap-2 text-sm font-medium text-zinc-700 cursor-pointer">
          <input
            type="checkbox"
            name="isActive"
            defaultChecked={block.isActive}
            className="rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900 size-4 cursor-pointer"
          />
          Active
        </label>
      </div>
      <div className="mt-5 grid gap-4 sm:grid-cols-2">
        <Input name="name" label="Block name" defaultValue={block.name} required />
        <Select
          name="paymentProvider"
          label="Mode"
          defaultValue={block.paymentProvider}
          options={providers}
        />
        <Input
          name="organizerName"
          label="Organizer"
          defaultValue={block.organizerName}
        />
        <Input
          name="organizerPhone"
          label="Organizer phone"
          defaultValue={block.organizerPhone}
        />
        <Input name="upiId" label="UPI ID" defaultValue={block.upiId} />
        <Input
          name="qrImageUrl"
          label="QR image URL"
          defaultValue={block.qrImageUrl}
        />
        <Input
          name="razorpayKeyId"
          label="Razorpay key ID"
          defaultValue={block.razorpayKeyId}
        />
        <Input
          name="razorpayLink"
          label="Razorpay payment link"
          defaultValue={block.razorpayLink}
        />
      </div>
      <label className="mt-3 block">
        <span className="label">Upload QR image</span>
        <input className="file-input" name="qrFile" type="file" accept="image/*" />
      </label>
      <button className="primary-button mt-4">Save block</button>
    </form>
  );
}

function CmsForm() {
  return (
    <form action={saveCmsAction} className="rounded-lg border border-zinc-100 bg-zinc-50 p-5">
      <h3 className="text-[11px] font-bold uppercase tracking-wider text-zinc-500">
        Create or update content
      </h3>
      <div className="mt-4 grid gap-4 sm:grid-cols-2">
        <Input name="id" label="Existing ID optional" />
        <Select
          name="section"
          label="Section"
          options={sections.map((section) => [section, section])}
        />
        <Input name="title" label="Title" required />
        <Input name="subtitle" label="Subtitle / date" />
        <Input name="label" label="Label / time" />
        <Input name="venue" label="Venue" />
        <Input name="color" label="Color" defaultValue="#8E1119" />
        <Input name="startsAt" label="Starts at" type="datetime-local" />
        <Input
          name="sortOrder"
          label="Sort order"
          type="number"
          defaultValue="10"
        />
        <label className="flex items-center gap-2 self-end rounded-md border border-zinc-200 bg-white px-3 py-[0.6rem] text-sm font-medium text-zinc-700 cursor-pointer shadow-sm">
          <input type="checkbox" name="isPublished" defaultChecked className="rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900 size-4 cursor-pointer" />
          Published
        </label>
      </div>
      <label className="mt-4 block">
        <span className="label">Body</span>
        <textarea className="input min-h-28" name="body" />
      </label>
      <div className="mt-3 grid gap-3 sm:grid-cols-2">
        <Input name="imageUrl" label="Image URL" />
        <label className="block">
          <span className="label">Upload image</span>
          <input
            className="file-input"
            name="imageFile"
            type="file"
            accept="image/*"
          />
        </label>
      </div>
      <button className="primary-button mt-4">Publish content</button>
    </form>
  );
}

function CmsList({ entries }: { entries: CmsEntry[] }) {
  return (
    <div className="grid max-h-[620px] gap-4 overflow-y-auto pr-2 custom-scrollbar">
      {entries.map((entry) => (
        <article key={entry.id} className="rounded-lg border border-zinc-200 bg-white p-5 shadow-sm transition-shadow hover:shadow-md">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500">
                {entry.section}
              </p>
              <h3 className="mt-1 text-base font-semibold text-zinc-900">{entry.title}</h3>
              <p className="mt-1 text-sm font-medium text-zinc-500">
                {entry.subtitle || entry.label || entry.venue || "No subtitle"}
              </p>
            </div>
            <span className={`inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset ${entry.isPublished ? 'bg-zinc-100 text-zinc-800 ring-zinc-200' : 'bg-amber-50 text-amber-800 ring-amber-200'}`}>
              {entry.isPublished ? "Published" : "Draft"}
            </span>
          </div>
          <p className="mt-3 line-clamp-2 text-sm font-normal text-zinc-600">
            {entry.body || "No body text."}
          </p>
          <p className="mt-4 text-[10px] font-medium text-zinc-400 font-mono">ID: {entry.id}</p>
        </article>
      ))}
    </div>
  );
}

function CompactTable({
  headers,
  rows,
}: {
  headers: string[];
  rows: string[][];
}) {
  return (
    <div className="overflow-x-auto rounded-lg border border-zinc-100">
      <table className="w-full min-w-[420px] text-left text-sm">
        <thead className="bg-zinc-50 text-[11px] font-bold uppercase tracking-wider text-zinc-500">
          <tr>
            {headers.map((header) => (
              <th className="table-head" key={header}>
                {header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, rowIndex) => (
            <tr key={`${row[0]}-${rowIndex}`} className="border-b border-zinc-100 last:border-0 hover:bg-zinc-50/50 transition-colors">
              {row.map((cell, cellIndex) => (
                <td className="table-cell text-zinc-700" key={`${cell}-${cellIndex}`}>
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function Input({
  name,
  label,
  type = "text",
  defaultValue = "",
  required = false,
}: {
  name: string;
  label: string;
  type?: string;
  defaultValue?: string | number;
  required?: boolean;
}) {
  return (
    <label className="block">
      <span className="label">{label}</span>
      <input
        className="input"
        name={name}
        type={type}
        defaultValue={defaultValue}
        required={required}
      />
    </label>
  );
}

function Select({
  name,
  label,
  options,
  defaultValue,
}: {
  name: string;
  label: string;
  options: string[][] | readonly (readonly string[])[];
  defaultValue?: string;
}) {
  return (
    <label className="block">
      <span className="label">{label}</span>
      <select className="input" name={name} defaultValue={defaultValue}>
        {options.map(([value, optionLabel]) => (
          <option key={value} value={value}>
            {optionLabel}
          </option>
        ))}
      </select>
    </label>
  );
}
