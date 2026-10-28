-- ============================================================
--  BATTERY MONITORING SYSTEM  —  Supabase schema
--  Superior Laundry Equipment / warehouse stackers
--
--  HOW TO RUN:
--    Supabase Dashboard  ->  SQL Editor  ->  New query
--    paste everything below  ->  Run
-- ============================================================


-- ------------------------------------------------------------
-- 1) readings  —  one row per voltage measurement (from ESP32)
-- ------------------------------------------------------------
create table if not exists public.readings (
  id          bigint generated always as identity primary key,
  stacker_id  integer      not null,          -- 1, 2, 3 ...
  voltage     numeric(6,3) not null,          -- measured battery voltage, e.g. 37.482
  created_at  timestamptz  not null default now()
);

-- fast "latest reading per stacker" lookups
create index if not exists readings_stacker_time_idx
  on public.readings (stacker_id, created_at desc);


-- ------------------------------------------------------------
-- 2) service_log  —  maintenance records (from the dashboard)
-- ------------------------------------------------------------
create table if not exists public.service_log (
  id            bigint generated always as identity primary key,
  stacker_id    integer not null,
  service_date  date    not null,             -- when the service was done
  next_due      date,                         -- next due date; NULL = one-time service
  note          text    not null default '',  -- what was done
  created_at    timestamptz not null default now()
);

create index if not exists service_log_stacker_idx
  on public.service_log (stacker_id, service_date desc);


-- ============================================================
--  ROW LEVEL SECURITY
--  No login is used — access is through the publishable
--  (anon) key, so we open exactly the access the app needs.
-- ============================================================
alter table public.readings    enable row level security;
alter table public.service_log enable row level security;

-- table-level grants for the anon role (publishable key)
grant select, insert                 on public.readings    to anon;
grant select, insert, update, delete on public.service_log to anon;

-- readings: everyone may READ and INSERT; history stays immutable
create policy "readings_read"   on public.readings    for select to anon using (true);
create policy "readings_insert" on public.readings    for insert to anon with check (true);

-- service_log: full CRUD (the dashboard adds / edits / deletes records)
create policy "service_read"   on public.service_log for select to anon using (true);
create policy "service_insert" on public.service_log for insert to anon with check (true);
create policy "service_update" on public.service_log for update to anon using (true) with check (true);
create policy "service_delete" on public.service_log for delete to anon using (true);


-- ============================================================
--  OPTIONAL — test data, so you can verify the dashboard
--  reads real data BEFORE the ESP32 nodes arrive.
--  (Run this block too, or paste it later. Delete anytime.)
-- ============================================================
insert into public.readings (stacker_id, voltage) values
  (1, 37.60),   -- Stacker 1  (36V)
  (2, 35.40),   -- Stacker 2  (36V)
  (3, 23.05);   -- Order Picker 3 (24V)

insert into public.service_log (stacker_id, service_date, next_due, note) values
  (1, '2026-09-10', '2026-12-10', 'Checked cell water levels, cleaned terminals'),
  (2, '2026-07-20', '2026-10-20', 'Full inspection and charge test'),
  (3, '2026-10-01', '2027-01-01', 'Visual inspection, voltage checked');

-- To simulate a live update later, just run another insert:
--   insert into public.readings (stacker_id, voltage) values (1, 37.10);
