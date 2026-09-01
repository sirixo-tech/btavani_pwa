import { randomUUID } from "node:crypto";
import { clearMobileCache, getCachedJson, setCachedJson } from "./cache";
import { sendPaymentSuccessEmail } from "./email";
import { hasDatabase, query } from "./db";
import { createSeedDashboardData } from "./seed";
import type {
  AuctionBid,
  Block,
  CmsEntry,
  DashboardData,
  Payment,
  PaymentProvider,
  PaymentStatus,
  Registration,
  TransparencyBlock,
  TransparencyData,
  VolunteerSubmission,
} from "./types";

const memory = createSeedDashboardData();

type DbBlock = {
  id: string;
  name: string;
  organizer_name: string;
  organizer_phone: string;
  upi_id: string;
  qr_image_url: string;
  payment_provider: PaymentProvider;
  razorpay_key_id: string;
  razorpay_link: string;
  is_active: boolean;
};

type DbPayment = {
  id: string;
  amount: number;
  block_id: string;
  block_name: string;
  resident_name: string;
  email: string;
  phone: string;
  flat_number: string;
  gotram: string;
  provider: PaymentProvider;
  status: PaymentStatus;
  reference_id: string;
  screenshot_url: string;
  created_at: string;
  paid_at: string | null;
};

type DbCms = {
  id: string;
  section: CmsEntry["section"];
  title: string;
  subtitle: string;
  body: string;
  image_url: string;
  label: string;
  color: string;
  starts_at: string;
  venue: string;
  sort_order: number;
  is_published: boolean;
};

type DbRegistration = {
  id: string;
  event_title: string;
  participant_name: string;
  flat_number: string;
  age_group: string;
  mobile: string;
  status: Registration["status"];
  created_at: string;
};

type DbVolunteer = {
  id: string;
  name: string;
  flat_number: string;
  mobile: string;
  roles: string[];
  note: string;
  created_at: string;
};

type DbBid = {
  id: string;
  item_title: string;
  amount: number;
  bidder_name: string;
  flat_number: string;
  mobile: string;
  status: AuctionBid["status"];
  created_at: string;
};

type DbTransparencyBlock = {
  block_id: string;
  block_name: string;
  total_payments: number | string;
  total_amount: number | string;
  last_paid_at: string | null;
};

function mapBlock(row: DbBlock): Block {
  return {
    id: row.id,
    name: row.name,
    organizerName: row.organizer_name,
    organizerPhone: row.organizer_phone,
    upiId: row.upi_id,
    qrImageUrl: row.qr_image_url,
    paymentProvider: row.payment_provider,
    razorpayKeyId: row.razorpay_key_id,
    razorpayLink: row.razorpay_link,
    isActive: row.is_active,
  };
}

function mapPayment(row: DbPayment): Payment {
  return {
    id: row.id,
    amount: row.amount,
    blockId: row.block_id,
    blockName: row.block_name,
    residentName: row.resident_name,
    email: row.email,
    phone: row.phone,
    flatNumber: row.flat_number,
    gotram: row.gotram,
    provider: row.provider,
    status: row.status,
    referenceId: row.reference_id,
    screenshotUrl: row.screenshot_url,
    createdAt: row.created_at,
    paidAt: row.paid_at || "",
  };
}

function mapCms(row: DbCms): CmsEntry {
  return {
    id: row.id,
    section: row.section,
    title: row.title,
    subtitle: row.subtitle,
    body: row.body,
    imageUrl: row.image_url,
    label: row.label,
    color: row.color,
    startsAt: row.starts_at,
    venue: row.venue,
    sortOrder: row.sort_order,
    isPublished: row.is_published,
  };
}

function mapRegistration(row: DbRegistration): Registration {
  return {
    id: row.id,
    eventTitle: row.event_title,
    participantName: row.participant_name,
    flatNumber: row.flat_number,
    ageGroup: row.age_group,
    mobile: row.mobile,
    status: row.status,
    createdAt: row.created_at,
  };
}

function mapVolunteer(row: DbVolunteer): VolunteerSubmission {
  return {
    id: row.id,
    name: row.name,
    flatNumber: row.flat_number,
    mobile: row.mobile,
    roles: row.roles,
    note: row.note,
    createdAt: row.created_at,
  };
}

function mapBid(row: DbBid): AuctionBid {
  return {
    id: row.id,
    itemTitle: row.item_title,
    amount: row.amount,
    bidderName: row.bidder_name,
    flatNumber: row.flat_number,
    mobile: row.mobile,
    status: row.status,
    createdAt: row.created_at,
  };
}

function totals(data: Omit<DashboardData, "totals">) {
  return {
    collected: data.payments
      .filter((payment) => payment.status === "paid")
      .reduce((sum, payment) => sum + payment.amount, 0),
    pending: data.payments
      .filter((payment) => payment.status === "pending")
      .reduce((sum, payment) => sum + payment.amount, 0),
    registrations: data.registrations.length,
    volunteers: data.volunteers.length,
  };
}

function toNumber(value: unknown) {
  if (typeof value === "number") return value;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function getConfiguredExpenseTotal(entries: Pick<CmsEntry, "id" | "title" | "body" | "subtitle" | "label">[]) {
  const setting = entries.find((entry) => {
    const key = `${entry.id} ${entry.title}`.toLowerCase();
    return key.includes("expense") || key.includes("transparency_total_expenses");
  });

  if (!setting) return 0;
  const value = setting.body || setting.subtitle || setting.label;
  return toNumber(String(value).replace(/[^0-9.-]/g, ""));
}

function buildTransparencyResponse(
  blocks: TransparencyBlock[],
  cmsEntries: Pick<CmsEntry, "id" | "title" | "body" | "subtitle" | "label">[],
): TransparencyData {
  const totalVerifiedCollection = blocks.reduce(
    (sum, block) => sum + block.totalAmount,
    0,
  );
  const totalPayments = blocks.reduce((sum, block) => sum + block.totalPayments, 0);
  const totalExpenses = getConfiguredExpenseTotal(cmsEntries);
  const lastUpdated =
    blocks
      .map((block) => block.lastPaidAt)
      .filter(Boolean)
      .sort()
      .at(-1) || "";

  return {
    blocks,
    totals: {
      verifiedCollection: totalVerifiedCollection,
      totalPayments,
      totalExpenses,
      balanceAvailable: totalVerifiedCollection - totalExpenses,
    },
    totalVerifiedCollection,
    totalPayments,
    totalExpenses,
    balanceAvailable: totalVerifiedCollection - totalExpenses,
    lastUpdated,
  };
}

function mapTransparencyBlock(row: DbTransparencyBlock): TransparencyBlock {
  const totalPayments = toNumber(row.total_payments);
  const totalAmount = toNumber(row.total_amount);
  const lastPaidAt = row.last_paid_at
    ? new Date(row.last_paid_at).toISOString()
    : "";

  return {
    blockId: row.block_id,
    blockName: row.block_name,
    totalPayments,
    totalAmount,
    lastPaidAt,
    block_id: row.block_id,
    block_name: row.block_name,
    total_payments: totalPayments,
    total_amount: totalAmount,
  };
}

function aggregateMemoryTransparency(data: DashboardData): TransparencyData {
  const paidByBlock = new Map<string, Payment[]>();

  for (const payment of data.payments) {
    if (payment.status !== "paid") continue;
    const items = paidByBlock.get(payment.blockId) || [];
    items.push(payment);
    paidByBlock.set(payment.blockId, items);
  }

  const blocks = data.blocks
    .filter((block) => block.isActive)
    .map((block) => {
      const payments = paidByBlock.get(block.id) || [];
      const lastPaidAt =
        payments
          .map((payment) => payment.paidAt || payment.createdAt)
          .filter(Boolean)
          .sort()
          .at(-1) || "";

      return mapTransparencyBlock({
        block_id: block.id,
        block_name: block.name,
        total_payments: payments.length,
        total_amount: payments.reduce((sum, payment) => sum + payment.amount, 0),
        last_paid_at: lastPaidAt,
      });
    });

  const response = buildTransparencyResponse(blocks, data.cmsEntries);
  response.payments = data.payments
    .filter(p => p.status === 'paid')
    .map(p => ({
      residentName: p.residentName,
      amount: p.amount,
      blockId: p.blockId,
      resident_name: p.residentName,
      block_id: p.blockId,
    }));
  return response;
}

export async function getDashboardData(): Promise<DashboardData> {
  if (!hasDatabase()) {
    return { ...memory, totals: totals(memory) };
  }

  const [blocks, cmsEntries, payments, registrations, volunteers, bids] =
    await Promise.all([
      query<DbBlock>("select * from blocks order by name asc"),
      query<DbCms>(
        "select * from cms_entries order by section asc, sort_order asc, title asc",
      ),
      query<DbPayment>(
        `select p.*, b.name as block_name
         from payments p
         join blocks b on b.id = p.block_id
         order by p.created_at desc
         limit 100`,
      ),
      query<DbRegistration>(
        "select * from event_registrations order by created_at desc limit 100",
      ),
      query<DbVolunteer>(
        "select * from volunteer_submissions order by created_at desc limit 100",
      ),
      query<DbBid>("select * from auction_bids order by amount desc, created_at desc"),
    ]);

  const data = {
    blocks: blocks.rows.map(mapBlock),
    cmsEntries: cmsEntries.rows.map(mapCms),
    payments: payments.rows.map(mapPayment),
    registrations: registrations.rows.map(mapRegistration),
    volunteers: volunteers.rows.map(mapVolunteer),
    bids: bids.rows.map(mapBid),
  };

  return { ...data, totals: totals(data) };
}

export async function getMobileBootstrap() {
  const cached = await getCachedJson("mobile:bootstrap");
  if (cached) return cached;

  const data = await getDashboardData();
  const response = {
    blocks: data.blocks.filter((block) => block.isActive),
    events: data.cmsEntries.filter(
      (entry) => entry.section === "event" && entry.isPublished,
    ),
    schedule: data.cmsEntries.filter(
      (entry) => entry.section === "schedule" && entry.isPublished,
    ),
    announcements: data.cmsEntries.filter(
      (entry) => entry.section === "announcement" && entry.isPublished,
    ),
    gallery: data.cmsEntries.filter(
      (entry) => entry.section === "gallery" && entry.isPublished,
    ),
    volunteerRoles: data.cmsEntries.filter(
      (entry) => entry.section === "volunteer_role" && entry.isPublished,
    ),
    appSettings: data.cmsEntries.filter(
      (entry) => entry.section === "app_setting" && entry.isPublished,
    ),
    settings: data.cmsEntries.filter(
      (entry) => entry.section === "app_setting" && entry.isPublished,
    ),
  };

  await setCachedJson("mobile:bootstrap", response, 60);
  return response;
}

export async function getTransparencyData(): Promise<TransparencyData> {
  const cached = await getCachedJson<TransparencyData>("mobile:transparency");
  if (cached) return cached;

  if (!hasDatabase()) {
    const response = aggregateMemoryTransparency({ ...memory, totals: totals(memory) });
    await setCachedJson("mobile:transparency", response, 30);
    return response;
  }

  const [blocks, settings, payments] = await Promise.all([
    query<DbTransparencyBlock>(
      `select
        b.id as block_id,
        b.name as block_name,
        count(p.id)::int as total_payments,
        coalesce(sum(p.amount), 0)::int as total_amount,
        max(coalesce(p.paid_at, p.created_at)) as last_paid_at
       from blocks b
       left join payments p on p.block_id = b.id and p.status = 'paid'
       where b.is_active = true
       group by b.id, b.name
       order by b.name asc`,
    ),
    query<Pick<DbCms, "id" | "title" | "subtitle" | "body" | "label">>(
      `select id, title, subtitle, body, label
       from cms_entries
       where section = 'app_setting' and is_published = true`,
    ),
    query<{ resident_name: string; amount: number; block_id: string }>(
      `select resident_name, amount, block_id
       from payments
       where status = 'paid'
       order by created_at desc`,
    ),
  ]);

  const response = buildTransparencyResponse(
    blocks.rows.map(mapTransparencyBlock),
    settings.rows.map((row) => ({
      id: row.id,
      title: row.title,
      subtitle: row.subtitle,
      body: row.body,
      label: row.label,
    })),
  );
  
  response.payments = [
    // Database payments
    ...payments.rows.map(row => ({
      residentName: row.resident_name,
      amount: row.amount,
      blockId: row.block_id,
      resident_name: row.resident_name,
      block_id: row.block_id,
    })),
  ];

  await setCachedJson("mobile:transparency", response, 30);
  return response;
}

export async function saveBlock(input: Partial<Block> & { id: string; name: string }) {
  const block: Block = {
    id: input.id,
    name: input.name,
    organizerName: input.organizerName || "",
    organizerPhone: input.organizerPhone || "",
    upiId: input.upiId || "",
    qrImageUrl: input.qrImageUrl || "",
    paymentProvider: input.paymentProvider || "upi_qr",
    razorpayKeyId: input.razorpayKeyId || "",
    razorpayLink: input.razorpayLink || "",
    isActive: input.isActive ?? true,
  };

  if (!hasDatabase()) {
    const index = memory.blocks.findIndex((item) => item.id === block.id);
    if (index >= 0) memory.blocks[index] = block;
    else memory.blocks.push(block);
    return block;
  }

  await query(
    `insert into blocks
      (id, name, organizer_name, organizer_phone, upi_id, qr_image_url, payment_provider, razorpay_key_id, razorpay_link, is_active, updated_at)
     values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,now())
     on conflict (id) do update set
      name = excluded.name,
      organizer_name = excluded.organizer_name,
      organizer_phone = excluded.organizer_phone,
      upi_id = excluded.upi_id,
      qr_image_url = excluded.qr_image_url,
      payment_provider = excluded.payment_provider,
      razorpay_key_id = excluded.razorpay_key_id,
      razorpay_link = excluded.razorpay_link,
      is_active = excluded.is_active,
      updated_at = now()`,
    [
      block.id,
      block.name,
      block.organizerName,
      block.organizerPhone,
      block.upiId,
      block.qrImageUrl,
      block.paymentProvider,
      block.razorpayKeyId,
      block.razorpayLink,
      block.isActive,
    ],
  );
  await clearMobileCache();
  return block;
}

export async function saveCmsEntry(input: Omit<CmsEntry, "id"> & { id?: string }) {
  const entry: CmsEntry = {
    id: input.id || randomUUID(),
    section: input.section,
    title: input.title,
    subtitle: input.subtitle,
    body: input.body,
    imageUrl: input.imageUrl,
    label: input.label,
    color: input.color,
    startsAt: input.startsAt,
    venue: input.venue,
    sortOrder: input.sortOrder,
    isPublished: input.isPublished,
  };

  if (!hasDatabase()) {
    const index = memory.cmsEntries.findIndex((item) => item.id === entry.id);
    if (index >= 0) memory.cmsEntries[index] = entry;
    else memory.cmsEntries.push(entry);
    return entry;
  }

  await query(
    `insert into cms_entries
      (id, section, title, subtitle, body, image_url, label, color, starts_at, venue, sort_order, is_published, updated_at)
     values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,now())
     on conflict (id) do update set
      section = excluded.section,
      title = excluded.title,
      subtitle = excluded.subtitle,
      body = excluded.body,
      image_url = excluded.image_url,
      label = excluded.label,
      color = excluded.color,
      starts_at = excluded.starts_at,
      venue = excluded.venue,
      sort_order = excluded.sort_order,
      is_published = excluded.is_published,
      updated_at = now()`,
    [
      entry.id,
      entry.section,
      entry.title,
      entry.subtitle,
      entry.body,
      entry.imageUrl,
      entry.label,
      entry.color,
      entry.startsAt,
      entry.venue,
      entry.sortOrder,
      entry.isPublished,
    ],
  );
  await clearMobileCache();
  return entry;
}

export async function updatePaymentStatus(
  id: string,
  status: PaymentStatus,
  referenceId: string,
) {
  if (!hasDatabase()) {
    const payment = memory.payments.find((item) => item.id === id);
    if (payment) {
      payment.status = status;
      payment.referenceId = referenceId;
      payment.paidAt = status === "paid" ? new Date().toISOString() : "";
    }
    await clearMobileCache();
    return payment;
  }

  const result = await query(
    `update payments p
     set status = $2,
         reference_id = $3,
         paid_at = case when $2 = 'paid' then coalesce(p.paid_at, now()) else p.paid_at end
     from blocks b
     where p.id = $1 and b.id = p.block_id
     returning p.email, p.resident_name, p.amount, b.name as block_name`,
    [id, status, referenceId],
  );
  await clearMobileCache();

  if (status === "paid" && result.rows.length > 0) {
    const row = result.rows[0];
    if (row.email) {
      sendPaymentSuccessEmail(row.email, row.resident_name, row.amount, row.block_name, referenceId);
    }
  }
}

export async function createPayment(input: {
  amount: number;
  blockId: string;
  residentName: string;
  email?: string;
  phone?: string;
  flatNumber?: string;
  gotram?: string;
  provider?: PaymentProvider;
  status?: PaymentStatus;
  referenceId?: string;
  screenshotUrl?: string;
}) {
  const block = (await getDashboardData()).blocks.find(
    (item) => item.id === input.blockId || item.name === input.blockId,
  );
  if (!block) throw new Error("Unknown block");

  const payment: Payment = {
    id: randomUUID(),
    amount: input.amount,
    blockId: block.id,
    blockName: block.name,
    residentName: input.residentName,
    email: input.email || "",
    phone: input.phone || "",
    flatNumber: input.flatNumber || "",
    gotram: input.gotram || "",
    provider: input.provider || block.paymentProvider,
    status: input.status || "pending",
    referenceId: input.referenceId || "",
    screenshotUrl: input.screenshotUrl || "",
    createdAt: new Date().toISOString(),
    paidAt: input.status === "paid" ? new Date().toISOString() : "",
  };

  if (!hasDatabase()) {
    memory.payments.unshift(payment);
    await clearMobileCache();
    return payment;
  }

  await query(
    `insert into payments
      (id, amount, block_id, resident_name, email, phone, flat_number, gotram, provider, status, reference_id, screenshot_url, paid_at)
     values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,
    [
      payment.id,
      payment.amount,
      payment.blockId,
      payment.residentName,
      payment.email,
      payment.phone,
      payment.flatNumber,
      payment.gotram,
      payment.provider,
      payment.status,
      payment.referenceId,
      payment.screenshotUrl,
      payment.paidAt || null,
    ],
  );
  await clearMobileCache();
  
  if (payment.status === "paid" && payment.email) {
    sendPaymentSuccessEmail(payment.email, payment.residentName, payment.amount, payment.blockName, payment.referenceId);
  }
  
  return payment;
}

export async function createRegistration(
  input: Omit<Registration, "id" | "status" | "createdAt">,
) {
  const registration: Registration = {
    ...input,
    id: randomUUID(),
    status: "new",
    createdAt: new Date().toISOString(),
  };

  if (!hasDatabase()) {
    memory.registrations.unshift(registration);
    return registration;
  }

  await query(
    `insert into event_registrations
      (id, event_title, participant_name, flat_number, age_group, mobile, status)
     values ($1,$2,$3,$4,$5,$6,$7)`,
    [
      registration.id,
      registration.eventTitle,
      registration.participantName,
      registration.flatNumber,
      registration.ageGroup,
      registration.mobile,
      registration.status,
    ],
  );
  return registration;
}

export async function createVolunteer(
  input: Omit<VolunteerSubmission, "id" | "createdAt">,
) {
  const volunteer: VolunteerSubmission = {
    ...input,
    id: randomUUID(),
    createdAt: new Date().toISOString(),
  };

  if (!hasDatabase()) {
    memory.volunteers.unshift(volunteer);
    return volunteer;
  }

  await query(
    `insert into volunteer_submissions
      (id, name, flat_number, mobile, roles, note)
     values ($1,$2,$3,$4,$5,$6)`,
    [
      volunteer.id,
      volunteer.name,
      volunteer.flatNumber,
      volunteer.mobile,
      volunteer.roles,
      volunteer.note,
    ],
  );
  return volunteer;
}

export async function createAuctionBid(
  input: Omit<AuctionBid, "id" | "status" | "createdAt">,
) {
  const bid: AuctionBid = {
    ...input,
    id: randomUUID(),
    status: "leading",
    createdAt: new Date().toISOString(),
  };

  if (!hasDatabase()) {
    memory.bids = memory.bids.map((item) => ({ ...item, status: "outbid" }));
    memory.bids.unshift(bid);
    return bid;
  }

  await query("update auction_bids set status = 'outbid' where item_title = $1", [
    bid.itemTitle,
  ]);
  await query(
    `insert into auction_bids
      (id, item_title, amount, bidder_name, flat_number, mobile, status)
     values ($1,$2,$3,$4,$5,$6,$7)`,
    [
      bid.id,
      bid.itemTitle,
      bid.amount,
      bid.bidderName,
      bid.flatNumber,
      bid.mobile,
      bid.status,
    ],
  );
  await clearMobileCache();
  return bid;
}

export async function deleteCmsEntry(id: string) {
  if (!hasDatabase()) {
    const index = memory.cmsEntries.findIndex((item) => item.id === id);
    if (index >= 0) memory.cmsEntries.splice(index, 1);
    return;
  }
  await query('delete from cms_entries where id = $1', [id]);
  await clearMobileCache();
}

export async function deletePayment(id: string) {
  if (!hasDatabase()) {
    const index = memory.payments.findIndex((item) => item.id === id);
    if (index >= 0) memory.payments.splice(index, 1);
    return;
  }
  await query('delete from payments where id = $1', [id]);
  await clearMobileCache();
}

export async function clearDemoData() {
  if (!hasDatabase()) {
    memory.cmsEntries = [];
    memory.payments = [];
    memory.registrations = [];
    memory.volunteers = [];
    memory.bids = [];
    return;
  }

  await query("TRUNCATE TABLE cms_entries, payments, event_registrations, volunteer_submissions, auction_bids CASCADE;");
  await clearMobileCache();
}
