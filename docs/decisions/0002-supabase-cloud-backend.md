# 0002 — Supabase as a cloud backend from day one

- **Status:** Accepted
- **Date:** 2026-10-14

## Context
Options for where data lives:

1. **Local only** (SQLite on the phone) — simple, but data is lost with the phone and can't be seen from a laptop.
2. **Local first, cloud later** — easy start, but a migration later.
3. **Cloud from day one** — client–server architecture immediately.

The user chose cloud from day one: data must survive device loss, be reachable from multiple devices, and the project should teach real client–server / networking concepts.

## Decision
Use **Supabase**: managed **PostgreSQL**, **Auth** (JWT), **Storage**, and an auto-generated **REST API** (PostgREST).

## Consequences
- A real relational database (constraints, foreign keys, RLS) without writing and hosting a custom server.
- Requests flow `app → HTTPS/REST/JSON → Supabase → Postgres`; the client never talks to the database directly.
- Free tier is enough for V1. Free projects pause after inactivity and must be restored from the dashboard.
- Custom server logic (e.g. investment analysis in V2) can be added later with Edge Functions or a separate service.
