# 0004 — One generic `sessions` table for all timed activities

- **Status:** Accepted
- **Date:** 2026-10-15

## Context
Studying, reading, sleeping, working out and (later) guitar / language practice all share the same interaction: **tap start → tap stop**. Sleep is logged the same way: "going to sleep" / "woke up".

A table per activity (`study_logs`, `reading_logs`, `sleep_logs`, …) would duplicate columns, API code and report queries for every new module.

## Decision
A single `sessions` table:

```
sessions(id, user_id, category, course_id?, template_id?, started_at, ended_at, note)
```

- `category` ∈ `study | reading | sleep | workout | guitar | english | german` (check constraint)
- `course_id` only allowed when `category = 'study'`; `template_id` only when `category = 'workout'` (check constraints)
- `ended_at IS NULL` means **the timer is running**
- A partial unique index — `unique (user_id) where ended_at is null` — guarantees **at most one running timer per user**, enforced by the database even if the app has a bug.

## Consequences
- Adding a module (e.g. German practice) = adding one value to the check constraint.
- Weekly reports are one `GROUP BY category` query.
- Activity-specific details live in side tables (e.g. `session_muscle_groups` for workouts).
