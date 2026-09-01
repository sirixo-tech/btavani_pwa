import { Pool, type QueryResultRow } from "pg";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  seedBids,
  seedBlocks,
  seedCmsEntries,
  seedPayments,
  seedRegistrations,
  seedVolunteers,
} from "./seed";

let pool: Pool | null = null;
let schemaReady: Promise<void> | null = null;
const schemaSql = readFileSync(join(process.cwd(), "db/schema.sql"), "utf8");

export function hasDatabase() {
  return Boolean(process.env.DATABASE_URL);
}

function getPool() {
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is not configured");
  }

  if (!pool) {
    pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl:
        process.env.POSTGRES_SSL === "false"
          ? false
          : { rejectUnauthorized: false },
    });
  }

  return pool;
}

export async function ensureSchema() {
  if (!hasDatabase()) return;

  schemaReady ??= getPool().query(schemaSql).then(seedDatabase);
  await schemaReady;
}

export async function query<T extends QueryResultRow>(
  text: string,
  params: unknown[] = [],
) {
  await ensureSchema();
  return getPool().query<T>(text, params);
}

async function seedDatabase() {
  const client = await getPool().connect();

    try {
      await client.query("begin");
      await client.query("ALTER TABLE payments ADD COLUMN IF NOT EXISTS screenshot_url TEXT NOT NULL DEFAULT '';");
      await client.query("ALTER TABLE payments ADD COLUMN IF NOT EXISTS receipt_number TEXT UNIQUE;");

      for (const block of seedBlocks) {
      await client.query(
        `insert into blocks
          (id, name, organizer_name, organizer_phone, upi_id, qr_image_url, payment_provider, razorpay_key_id, razorpay_link, is_active)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
         on conflict (id) do nothing`,
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
    }

    for (const entry of seedCmsEntries) {
      await client.query(
        `insert into cms_entries
          (id, section, title, subtitle, body, image_url, label, color, starts_at, venue, sort_order, is_published)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
         on conflict (id) do nothing`,
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
    }

    for (const payment of seedPayments) {
      await client.query(
        `insert into payments
          (id, amount, block_id, resident_name, email, phone, flat_number, gotram, provider, status, reference_id, receipt_number, created_at, paid_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
         on conflict (id) do nothing`,
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
          payment.receiptNumber || `BTAVANI-${payment.createdAt.slice(0, 10).replace(/-/g, "")}-${Math.floor(Math.random() * 900000 + 100000)}`,
          payment.createdAt,
          payment.paidAt || null,
        ],
      );
    }

    for (const registration of seedRegistrations) {
      await client.query(
        `insert into event_registrations
          (id, event_title, participant_name, flat_number, age_group, mobile, status, created_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8)
         on conflict (id) do nothing`,
        [
          registration.id,
          registration.eventTitle,
          registration.participantName,
          registration.flatNumber,
          registration.ageGroup,
          registration.mobile,
          registration.status,
          registration.createdAt,
        ],
      );
    }

    for (const volunteer of seedVolunteers) {
      await client.query(
        `insert into volunteer_submissions
          (id, name, flat_number, mobile, roles, note, created_at)
         values ($1,$2,$3,$4,$5,$6,$7)
         on conflict (id) do nothing`,
        [
          volunteer.id,
          volunteer.name,
          volunteer.flatNumber,
          volunteer.mobile,
          volunteer.roles,
          volunteer.note,
          volunteer.createdAt,
        ],
      );
    }

    for (const bid of seedBids) {
      await client.query(
        `insert into auction_bids
          (id, item_title, amount, bidder_name, flat_number, mobile, status, created_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8)
         on conflict (id) do nothing`,
        [
          bid.id,
          bid.itemTitle,
          bid.amount,
          bid.bidderName,
          bid.flatNumber,
          bid.mobile,
          bid.status,
          bid.createdAt,
        ],
      );
    }

    await client.query("commit");
  } catch (error) {
    await client.query("rollback");
    throw error;
  } finally {
    client.release();
  }
}
