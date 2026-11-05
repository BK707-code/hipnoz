# 0003 — Host the backend in the EU (Paris) for low latency

- **Status:** Accepted (supersedes an accidental Tokyo deployment)
- **Date:** 2026-11-04

## Context
The first Supabase project was created with region **"Auto"**, which placed it in **Tokyo (`ap-northeast-1`)**. The user is in Turkey.

Signals in optical fiber travel at roughly 2/3 of the speed of light (~200,000 km/s), so distance sets a hard lower bound on latency:

| Region | Distance from Ankara | Realistic round-trip time |
|---|---|---|
| Frankfurt / Paris | ~2,500–3,000 km | ~50–60 ms |
| Tokyo | ~9,000 km | ~250 ms |

A typical screen issues 3–4 requests, so Tokyo would add roughly **1 second** of waiting per screen.

A Supabase project's region **cannot be changed** after creation. The Tokyo project was empty (0 MB), so recreating it cost nothing.

## Decision
Delete the Tokyo project and recreate it with region **Europe**, which resolved to **West EU (Paris), `eu-west-3`**.

## Consequences
- Round trips stay in the ~50 ms range, so the app feels instant.
- Lesson recorded: never leave infrastructure choices on "Auto"; verify region before creating.
