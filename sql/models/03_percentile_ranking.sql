/*
  Percentile ranking within each degree_group.
  Deterministic ordering: GPA, then student_id.
  Assumption: lower GPA = better (ASC). If opposite, switch to DESC.
*/

WITH base AS (
  /* Use 02_base_dataset.sql */
  WITH mapped AS (
    SELECT *
    FROM (
      WITH program_source AS (
        SELECT
          ps.id                  AS profil_studium_id,
          ps.pid                 AS student_id,
          ps.studium             AS studium_id,
          ps.graduation_date,
          s.name                 AS program_name
        FROM profil_studium ps
        JOIN studium s ON s.id = ps.studium
      )
      SELECT
        profil_studium_id,
        student_id,
        studium_id,
        graduation_date,
        program_name,
        CASE
          WHEN program_name LIKE '%B.A.%'  THEN 'B.A.'
          WHEN program_name LIKE '%B.Sc.%' THEN 'B.Sc.'
          WHEN program_name LIKE '%M.A.%'  THEN 'M.A.'
          WHEN program_name LIKE '%M.Sc.%' THEN 'M.Sc.'
          WHEN program_name LIKE '%MBA%'   THEN 'MBA'
          ELSE NULL
        END AS degree_group
      FROM program_source
    ) m
  )
  SELECT
    m.student_id,
    m.degree_group,
    m.graduation_date,
    ns.gpa
  FROM mapped m
  JOIN noten_students ns
    ON ns.sid = m.student_id
  WHERE
    m.graduation_date IS NOT NULL
    AND m.degree_group IS NOT NULL
    AND ns.gpa IS NOT NULL
    AND ns.gpa > 0
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
  FROM base
)
SELECT
  student_id,
  degree_group,
  graduation_date,
  gpa,
  rn,
  n_in_group,
  /* percentile in [0,100], based on rank position */
  ROUND( (rn / NULLIF(n_in_group, 0)) * 100, 2 ) AS percentile
FROM ranked;