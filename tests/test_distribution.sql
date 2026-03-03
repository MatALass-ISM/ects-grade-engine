/*
  Distribution test:
  counts and proportions by degree_group + ects_grade
  Expect approx: A~10%, B~25%, C~30%, D~25%, E~10%
*/

WITH results AS (
  SELECT * FROM v_ects_grade_v1
),
counts AS (
  SELECT
    degree_group,
    ects_grade,
    COUNT(*) AS n
  FROM results
  GROUP BY degree_group, ects_grade
),
totals AS (
  SELECT
    degree_group,
    COUNT(*) AS n_total
  FROM results
  GROUP BY degree_group
)
SELECT
  c.degree_group,
  c.ects_grade,
  c.n,
  t.n_total,
  ROUND((c.n / NULLIF(t.n_total, 0)) * 100, 2) AS pct
FROM counts c
JOIN totals t USING (degree_group)
ORDER BY c.degree_group, c.ects_grade;