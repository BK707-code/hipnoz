# Hipnoz — V1 Requirements Spec

## Vision
Weekly progress tracking, reminders and daily structure for a demanding schedule (8 university courses, gym, reading, sleep). First user: the author. Later versions add a personal finance module (income/expenses, investments, analysis).

## Design principle: plan-first, not warning-first
The app is **proactive**: each week starts with a plan (what we focus on this week), and the app tracks plan vs. actual. No negative "you didn't do X in 10 days" alerts — past data is shown only as *input* to next week's planning. See [ADR 0005](decisions/0005-plan-first-rotation.md).

## Non-functional requirements
- **Platform:** iPhone, built with Expo / React Native (developed on Windows, tested with Expo Go, published via EAS cloud build) — [ADR 0001](decisions/0001-expo-react-native.md)
- **Data:** cloud from day one — Supabase (PostgreSQL + Auth + Storage) — [ADR 0002](decisions/0002-supabase-cloud-backend.md)
- **Latency:** backend hosted in the EU (Paris) — [ADR 0003](decisions/0003-region-latency.md)
- **Security:** least privilege, GRANT + RLS — [ADR 0006](decisions/0006-least-privilege-grant-rls.md)
- **Reminders:** local scheduled notifications; weekly report computed from data
- **Extensibility:** modular data model so new modules plug in without rewrites — [ADR 0004](decisions/0004-generic-sessions-table.md)

## MVP scope (V1) — priority order

### 1. Courses (8)
CMPE327 Theory of Computation · CMPE224 Algorithms & Data Structures II · CMPE232 Database Systems · LIBE130 Art and Design · MATH313 Real Analysis · MATH321 Abstract Algebra · MATH333 Probability & Statistics · TUR101 Turkish

- Topic checklist with stages: *pre-studied → attended → reviewed → practiced* (goal: learn topics **before** class, no all-nighters at exam time)
- Deadlines: homework, quiz, ALE, midterm, final — countdown + reminders
- Grades + weights → progress toward target grade
- Study time per course (start/stop timer), weekly target

### 2. Workouts
- 4–5 sessions/week, target duration 50–70 min (timer)
- 3-day **rotation** (cycle, not fixed weekdays): A: Chest + Triceps · B: Back + Biceps + Traps · C: Shoulders + Legs + Calves
- **Accessory pool** added to any day: forearm, abs, calves, traps, neck
- "Next workout" = next template in the rotation after the last completed one
- **Weekly planning:** choose focus areas + session count; app suggests accessories per day (focus groups first, least-recently-trained first)
- Plan vs. actual: tap "done ✓"
- Progress photos (private storage) to inform focus areas

### 3. Reading
- Daily timer, target ≥ 20 min/day, streak

### 4. Sleep
- Tap "going to sleep" / "woke up" → time-in-bed log (phone health data assumes a fixed schedule and doesn't reflect reality)

## Cross-cutting
- Weekly planning ritual (Sunday): review last week → set this week's plan
- Daily plan + checklist
- Fixed-time notifications
- Weekly review: study hours per course, average sleep, workouts + muscle coverage, reading minutes, plan adherence, vs. last week
- Streaks / score

## V1.1+ (after the MVP is in daily use)
- Guitar practice time
- English writing practice log
- German learning log
- Career deadlines (exchange program, internship applications)

## Data model
See the [schema](../supabase/migrations/0001_initial_schema.sql) and the ER diagram in the [README](../README.md#data-model).

## Open questions
- Grade weights per course (from syllabi)
- Weekly study-hour target per course
