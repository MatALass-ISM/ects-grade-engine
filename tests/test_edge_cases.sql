/*
  Edge case visibility checks (not asserts):
  - cohorts with very small size
  - potential nulls / filtered rows
  - ties frequency
*/

-- 1) Small cohorts
WITH results AS (
  SELECT * FROM v_ects_grade_v1
)
SELECT degree_group, COUNT(*) AS n_total
FROM results
GROUP BY degree_group
HAVING COUNT(*) < 10
ORDER BY n_total ASC;

-- 2) Ties on GPA (potentially high)
WITH base AS (
  SELECT
    ps.pid AS student_id,
    s.name AS program_name,
    ns.gpa
  FROM profil_studium ps
  JOIN studium s ON s.id = ps.studium
  JOIN noten_students ns ON ns.sid = ps.pid
  WHERE ps.graduation_date IS NOT NULL AND ns.gpa IS NOT NULL AND ns.gpa > 0
),
mapped AS (
  SELECT
    student_id,
    gpa,
    CASE
      WHEN program_name LIKE '%B.A.%'  THEN 'B.A.'
      WHEN program_name LIKE '%B.Sc.%' THEN 'B.Sc.'
      WHEN program_name LIKE '%M.A.%'  THEN 'M.A.'
      WHEN program_name LIKE '%M.Sc.%' THEN 'M.Sc.'
      WHEN program_name LIKE '%MBA%'   THEN 'MBA'
      ELSE NULL
    END AS degree_group
  FROM base
)
SELECT
  degree_group,
  gpa,
  COUNT(*) AS how_many_students_share_gpa
FROM mapped
WHERE degree_group IS NOT NULL
GROUP BY degree_group, gpa
HAVING COUNT(*) > 1
ORDER BY how_many_students_share_gpa DESC, degree_group;