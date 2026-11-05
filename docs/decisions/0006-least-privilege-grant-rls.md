# 0006 — Least privilege: explicit GRANTs + Row Level Security

- **Status:** Accepted
- **Date:** 2026-11-04

## Context
The mobile app ships with Supabase's **public (anon/publishable) key**. Anyone can extract it, so the key itself is not a security boundary.

Supabase offers "**Automatically expose new tables**", which grants API roles (including `anon`, i.e. logged-out users) access to every new table. Then **RLS** would be the only line of defense.

## Decision
Apply the **principle of least privilege** with **defense in depth**:

1. **Auto-expose OFF.** Nothing is reachable until explicitly granted.
2. **Layer 1 — GRANT:** only the `authenticated` role gets `select/insert/update/delete` on user tables; `muscle_groups` (lookup data) is `select`-only. `anon` gets nothing.
3. **Layer 2 — RLS:** every user table has
   `using (user_id = auth.uid()) with check (user_id = auth.uid())`,
   and `user_id` defaults to `auth.uid()`.
4. **Automatic RLS ON** as a safety net for future tables.

```
request ─▶ [GRANT: may this role touch the table?] ─▶ [RLS: is this row yours?] ─▶ data
```

## Verification
Tested on a local PostgreSQL 16 with a mocked `auth` schema before deploying:

| Test | Result |
|---|---|
| User A inserts a course, reads it | 1 row ✅ |
| User B reads `courses` | 0 rows ✅ |
| `anon` reads `courses` | `permission denied` ✅ |
| `authenticated` deletes from `muscle_groups` | `permission denied` ✅ |
| Second running timer for same user | unique violation ✅ |

## Consequences
- A leaked public key exposes nothing to logged-out callers and only the caller's own rows to logged-in ones.
- Admin work (SQL Editor, seeding) runs as `postgres`, which **bypasses RLS** — so the service/secret key and DB password must never leave the dashboard or enter the repo.
