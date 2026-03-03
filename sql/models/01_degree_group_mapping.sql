/* 
  Degree group mapping (normalize program names to a controlled group label)
  NOTE: In production, replace this with a real mapping table.
*/

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
FROM program_source;