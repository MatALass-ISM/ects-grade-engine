/*
  Final model (single entry point).
  Output: student_id, degree_group, graduation_date, gpa, percentile, ects_grade
*/

WITH base AS (
  SELECT
    ps.pid                AS student_id,
    ps.graduation_date,
    s.name                AS program_name,
    ns.gpa
  FROM profil_studium ps
  JOIN studium s ON s.id = ps.studium
  JOIN noten_students ns ON ns.sid = ps.pid
  WHERE
    ps.graduation_date IS NOT NULL
    AND ns.gpa IS NOT NULL
    AND ns.gpa > 0
),
mapped AS (
  SELECT
    student_id,
    graduation_date,
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
),
filtered AS (
  SELECT *
  FROM mapped
  WHERE degree_group IS NOT NULL
),
ranked AS (
  SELECT
    student_id,
    degree_group,
    graduation_date,
    gpa,
    ROW_NUMBER() OVER (
      PARTITION BY degree_group
      ORDER BY gpa ASC, student_id ASC
    ) AS rn,
    COUNT(*) OVER (
      PARTITION BY degree_group
    ) AS n_in_group
  FROM filtered
),
scored AS (
  SELECT
    student_id,
    degree_group,
    graduation_date,
    gpa,
    ROUND((rn / NULLIF(n_in_group, 0)) * 100, 2) AS percentile
  FROM ranked
)
SELECT
  student_id,
  degree_group,
  graduation_date,
  gpa,
  percentile,
  CASE
    WHEN percentile <= 10 THEN 'A'
    WHEN percentile <= 35 THEN 'B'
    WHEN percentile <= 65 THEN 'C'
    WHEN percentile <= 90 THEN 'D'
    ELSE 'E'
  END AS ects_grade
FROM scored;