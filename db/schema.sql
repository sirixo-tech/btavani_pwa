create extension if not exists pgcrypto;

create table if not exists blocks (
  id text primary key,
  name text not null unique,
  organizer_name text not null default '',
  organizer_phone text not null default '',
  upi_id text not null default '',
  qr_image_url text not null default '',
  payment_provider text not null default 'upi_qr',
  razorpay_key_id text not null default '',
  razorpay_link text not null default '',
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists cms_entries (
  id text primary key default gen_random_uuid()::text,
  section text not null,
  title text not null,
  subtitle text not null default '',
  body text not null default '',
  image_url text not null default '',
  label text not null default '',
  color text not null default '#8E1119',
  starts_at text not null default '',
  venue text not null default '',
  sort_order integer not null default 0,
  is_published boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists payments (
  id text primary key default gen_random_uuid()::text,
  amount integer not null check (amount > 0),
  block_id text not null references blocks(id),
  resident_name text not null,
  email text not null default '',
  phone text not null default '',
  flat_number text not null default '',
  gotram text not null default '',
  provider text not null default 'upi_qr',
  status text not null default 'pending',
  reference_id text not null default '',
  screenshot_url text not null default '',
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

create index if not exists payments_status_created_idx on payments (status, created_at desc);
create index if not exists payments_block_created_idx on payments (block_id, created_at desc);

create table if not exists event_registrations (
  id text primary key default gen_random_uuid()::text,
  event_title text not null,
  participant_name text not null,
  flat_number text not null,
  age_group text not null,
  mobile text not null,
  status text not null default 'new',
  created_at timestamptz not null default now()
);

create table if not exists volunteer_submissions (
  id text primary key default gen_random_uuid()::text,
  name text not null,
  flat_number text not null,
  mobile text not null,
  roles text[] not null default '{}',
  note text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists auction_bids (
  id text primary key default gen_random_uuid()::text,
  item_title text not null default 'Laddoo Auction',
  amount integer not null check (amount > 0),
  bidder_name text not null default '',
  flat_number text not null,
  mobile text not null default '',
  status text not null default 'leading',
  created_at timestamptz not null default now()
);

create table if not exists audit_events (
  id text primary key default gen_random_uuid()::text,
  actor text not null default 'admin',
  action text not null,
  entity_type text not null,
  entity_id text not null,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);
