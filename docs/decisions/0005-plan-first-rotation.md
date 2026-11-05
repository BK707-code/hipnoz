# 0005 — Plan-first design and a rotation (circular queue) for workouts

- **Status:** Accepted
- **Date:** 2026-10-15

## Context
The first draft was **reactive**: "you trained calves fewer than 2× in 10 days" → warning. That is a lagging indicator, arrives too late, and is demotivating. The user asked for a **proactive** flow: decide each week what to prioritise, then follow a good program.

The user's training split is a **3-day cycle**, not a weekly calendar:

```
A: Chest + Triceps
B: Back + Biceps + Traps
C: Shoulders + Legs + Calves
→ A → B → C → A …
```

with forearm, abs, calves, traps and neck "sprinkled" onto days. A 3-day cycle doesn't fit a 7-day week, and the user trains 4–5 times a week, so fixed weekdays would drift after any skipped day.

## Decision
- **Plan vs. actual** are stored separately: `weekly_plans` + `weekly_focus_muscles` (plan) vs. `sessions` (actual).
- Workouts follow a **rotation**: `workout_templates.rotation_order` with
  `next_order = (last_order mod N) + 1` — a circular queue keyed on the *last completed* workout, not the calendar.
- Accessory muscles form a **pool**; the app suggests accessories that are in this week's focus and least recently trained.
- Past data is shown only as **input to next week's plan**, never as a warning.

## Consequences
- Skipping a day never breaks the schedule.
- The same plan-vs-actual pattern is reused for courses (planned topics vs. timed study).
- Many-to-many links (`template_muscle_groups`, `session_muscle_groups`, `weekly_focus_muscles`) are required.
