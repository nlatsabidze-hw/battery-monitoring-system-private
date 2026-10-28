# Stacker Battery Monitoring System — working repo (PRIVATE)

Full working version of the stacker battery monitor. **Keep private** — this repo holds live credentials and firmware.

Public / portfolio version: `nlatsabidze-hw/stacker-battery-monitor`

## Contents

- `index.html` — dashboard. Set `SUPABASE_URL` and `SUPABASE_KEY` (publishable key) at the top for live mode; blank = demo mode.
- `supabase_schema.sql` — DB tables + RLS. Run once in Supabase → SQL Editor.
- `firmware/` — ESP32-C3 node firmware (added as it's built).

## Secrets — never commit to the public repo

- ✅ Safe to expose: Supabase **Project URL** and **publishable key** (`sb_publishable_…`) — protected by RLS.
- ❌ Never expose: Supabase DB password, **secret key** (`sb_secret_…`), any Wi-Fi credentials in firmware.

## Deploy

1. Fill `SUPABASE_URL` + publishable key in `index.html`.
2. Push → Netlify auto-deploys (or drag-and-drop `index.html`).

## Status

- [x] Dashboard (live + service log + history charts)
- [x] Supabase schema + RLS
- [ ] Supabase project connected
- [ ] ESP32 firmware
- [ ] Hardware assembly & calibration
