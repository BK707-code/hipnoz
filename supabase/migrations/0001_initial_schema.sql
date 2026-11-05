-- =====================================================================
-- Hipnoz — Database schema v1
-- Run once in: Supabase Dashboard → SQL Editor → New query → Run
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) LOOKUP TABLE (shared reference data, same for every user)
-- ---------------------------------------------------------------------
create table muscle_groups (
  id            smallint generated always as identity primary key,
  name          text not null unique,          -- English key used in code
  name_tr       text not null,                 -- Turkish label shown in app
  is_accessory  boolean not null default false -- true = in the "accessory pool"
);

insert into muscle_groups (name, name_tr, is_accessory) values
  ('chest',     'Göğüs',     false),
  ('back',      'Sırt',      false),
  ('shoulders', 'Omuz',      false),
  ('biceps',    'Ön kol',    false),
  ('triceps',   'Arka kol',  false),
  ('legs',      'Bacak',     false),
  ('forearm',   'Bilek',     true),
  ('abs',       'Karın',     true),
  ('calves',    'Kalf',      true),
  ('traps',     'Trapez',    true),
  ('neck',      'Boyun',     true);

-- ---------------------------------------------------------------------
-- 2) COURSES
-- ---------------------------------------------------------------------
create table courses (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null default auth.uid() references auth.users on delete cascade,
  code               text not null,                 -- e.g. 'CMPE232'
  name               text not null,
  weekly_target_min  int  not null default 0,
  created_at         timestamptz not null default now(),
  unique (user_id, code)
);

create table course_topics (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  course_id   uuid not null references courses on delete cascade,
  title       text not null,
  week        int,
  status      text not null default 'not_started'
              check (status in ('not_started','pre_studied','attended','reviewed','practiced')),
  sort_order  int not null default 0
);

create table course_events (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  course_id  uuid not null references courses on delete cascade,
  type       text not null check (type in ('homework','quiz','ale','midterm','final','project')),
  title      text not null,
  due_at     timestamptz,
  weight     numeric(5,2),   -- % of final grade, e.g. 30.00
  grade      numeric(5,2),   -- score out of 100, null until graded
  done       boolean not null default false
);

-- ---------------------------------------------------------------------
-- 3) WORKOUT TEMPLATES (the A → B → C rotation)
-- ---------------------------------------------------------------------
create table workout_templates (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users on delete cascade,
  name            text not null,     -- e.g. 'A: Chest + Triceps'
  rotation_order  int  not null,     -- 1, 2, 3 ...
  unique (user_id, rotation_order)
);

create table template_muscle_groups (
  user_id          uuid not null default auth.uid() references auth.users on delete cascade,
  template_id      uuid not null references workout_templates on delete cascade,
  muscle_group_id  smallint not null references muscle_groups,
  primary key (template_id, muscle_group_id)
);

-- ---------------------------------------------------------------------
-- 4) SESSIONS — every start/stop activity (study, reading, sleep, workout…)
-- ---------------------------------------------------------------------
create table sessions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users on delete cascade,
  category     text not null
               check (category in ('study','reading','sleep','workout','guitar','english','german')),
  course_id    uuid references courses on delete set null,            -- only for 'study'
  template_id  uuid references workout_templates on delete set null,  -- only for 'workout'
  started_at   timestamptz not null default now(),
  ended_at     timestamptz,                                           -- null = timer still running
  note         text,
  check (ended_at is null or ended_at > started_at),
  check (course_id   is null or category = 'study'),
  check (template_id is null or category = 'workout')
);

-- Only ONE running timer per user at a time
create unique index one_running_session_per_user
  on sessions (user_id) where ended_at is null;

-- Fast "this week's sessions" queries
create index sessions_user_time on sessions (user_id, started_at);

create table session_muscle_groups (
  user_id          uuid not null default auth.uid() references auth.users on delete cascade,
  session_id       uuid not null references sessions on delete cascade,
  muscle_group_id  smallint not null references muscle_groups,
  primary key (session_id, muscle_group_id)
);

-- ---------------------------------------------------------------------
-- 5) WEEKLY PLANNING
-- ---------------------------------------------------------------------
create table weekly_plans (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null default auth.uid() references auth.users on delete cascade,
  week_start       date not null,          -- Monday of the week
  target_sessions  int  not null default 4,
  note             text,
  unique (user_id, week_start)
);

create table weekly_focus_muscles (
  user_id          uuid not null default auth.uid() references auth.users on delete cascade,
  weekly_plan_id   uuid not null references weekly_plans on delete cascade,
  muscle_group_id  smallint not null references muscle_groups,
  primary key (weekly_plan_id, muscle_group_id)
);

-- ---------------------------------------------------------------------
-- 6) PROGRESS PHOTOS (file lives in Storage, DB keeps only the path)
-- ---------------------------------------------------------------------
create table progress_photos (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users on delete cascade,
  taken_at      timestamptz not null default now(),
  pose          text not null default 'front' check (pose in ('front','back','side','other')),
  storage_path  text not null
);

-- ---------------------------------------------------------------------
-- 7) DAILY TASKS
-- ---------------------------------------------------------------------
create table daily_tasks (
  id       uuid primary key default gen_random_uuid(),
  user_id  uuid not null default auth.uid() references auth.users on delete cascade,
  date     date not null default current_date,
  title    text not null,
  done     boolean not null default false
);

-- =====================================================================
-- 8) ROW LEVEL SECURITY — each user sees and edits ONLY their own rows
-- =====================================================================

-- "Automatically expose new tables" is OFF → nothing is accessible until we GRANT it.
-- Only the 'authenticated' role (logged-in users) gets access; 'anon' gets nothing.
grant usage on schema public to authenticated;

-- Lookup table: everyone logged in can read, nobody can change from the app
grant select on muscle_groups to authenticated;
alter table muscle_groups enable row level security;
create policy "read muscle groups" on muscle_groups
  for select to authenticated using (true);

-- Every user-owned table gets the same rule: user_id must equal the caller
do $$
declare
  t text;
begin
  foreach t in array array[
    'courses','course_topics','course_events',
    'workout_templates','template_muscle_groups',
    'sessions','session_muscle_groups',
    'weekly_plans','weekly_focus_muscles',
    'progress_photos','daily_tasks'
  ]
  loop
    -- Layer 1 (GRANT): logged-in users may use this table at all
    execute format('grant select, insert, update, delete on %I to authenticated', t);
    -- Layer 2 (RLS): …but only on their own rows
    execute format('alter table %I enable row level security', t);
    execute format(
      'create policy "own rows" on %I for all to authenticated
         using (user_id = auth.uid())
         with check (user_id = auth.uid())', t);
  end loop;
end $$;
