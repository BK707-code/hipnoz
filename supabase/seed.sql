-- =====================================================================
-- Hipnoz — Seed data v1 (Brandon's courses + A/B/C workout rotation)
-- Run ONCE in: SQL Editor, AFTER creating your user in Authentication
-- =====================================================================
-- The SQL Editor runs as the admin role 'postgres', which BYPASSES RLS
-- and has no logged-in user (auth.uid() is NULL). So the default
-- `user_id = auth.uid()` would be NULL here → we set user_id explicitly.

do $$
declare
  uid uuid;
  t_a uuid;
  t_b uuid;
  t_c uuid;
begin
  -- 1) Find the (single) user we created in Authentication → Users
  if (select count(*) from auth.users) <> 1 then
    raise exception 'Expected exactly 1 user in auth.users, found %',
      (select count(*) from auth.users);
  end if;
  select id into uid from auth.users;

  -- 2) Courses (Fall 2026). weekly_target_min = 0 → set later in the app
  insert into courses (user_id, code, name) values
    (uid, 'CMPE327', 'Theory of Computation'),
    (uid, 'CMPE224', 'Algorithms and Data Structures II'),
    (uid, 'CMPE232', 'Database Systems'),
    (uid, 'LIBE130', 'Art and Design'),
    (uid, 'MATH313', 'Real Analysis'),
    (uid, 'MATH321', 'Abstract Algebra'),
    (uid, 'MATH333', 'Probability and Statistics'),
    (uid, 'TUR101',  'Turkish');

  -- 3) Workout rotation A → B → C
  insert into workout_templates (user_id, name, rotation_order)
    values (uid, 'A: Göğüs + Arka kol', 1) returning id into t_a;
  insert into workout_templates (user_id, name, rotation_order)
    values (uid, 'B: Sırt + Ön kol + Trapez', 2) returning id into t_b;
  insert into workout_templates (user_id, name, rotation_order)
    values (uid, 'C: Omuz + Bacak + Kalf', 3) returning id into t_c;

  -- 4) Which muscle groups each template trains (many-to-many)
  insert into template_muscle_groups (user_id, template_id, muscle_group_id)
  select uid, x.template_id, m.id
  from (values
          (t_a, 'chest'), (t_a, 'triceps'),
          (t_b, 'back'),  (t_b, 'biceps'), (t_b, 'traps'),
          (t_c, 'shoulders'), (t_c, 'legs'), (t_c, 'calves')
       ) as x(template_id, muscle)
  join muscle_groups m on m.name = x.muscle;

  raise notice 'Seed done for user %', uid;
end $$;

-- 5) Check the result: each template with its muscle groups
select t.rotation_order, t.name, string_agg(m.name_tr, ', ' order by m.id) as muscles
from workout_templates t
join template_muscle_groups tm on tm.template_id = t.id
join muscle_groups m on m.id = tm.muscle_group_id
group by t.rotation_order, t.name
order by t.rotation_order;
