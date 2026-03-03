SELECT
  r.student_id,
  r.degree_group,
  r.graduation_date,
  r.gpa,
  ROUND(100.0 * r.rn / r.n_in_group, 2) AS rank_percent,
  CASE
    WHEN (1.0 * r.rn / r.n_in_group) <= 0.10 THEN 'A'
    WHEN (1.0 * r.rn / r.n_in_group) <= 0.35 THEN 'B'
    WHEN (1.0 * r.rn / r.n_in_group) <= 0.65 THEN 'C'
    WHEN (1.0 * r.rn / r.n_in_group) <= 0.90 THEN 'D'
    ELSE 'E'
  END AS ects_grade
FROM (
  SELECT
    ordered.*,
    (@rn := IF(@grp = ordered.degree_group, @rn + 1, 1)) AS rn,
    (@grp := ordered.degree_group) AS _grp_set
  FROM (
    SELECT
      base.student_id,
      base.degree_group,
      base.graduation_date,
      base.gpa,
      cnt.n_in_group
    FROM (
      SELECT
        p.id AS student_id,
        ps.graduation_date,
        ns.gpa,
        CASE
          WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '%B.A.%'  THEN 'B.A.'
          WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '%B.Sc.%' THEN 'B.Sc.'
          WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '%M.A.%'  THEN 'M.A.'
          WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '%M.Sc.%' THEN 'M.Sc.'
          WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE 'MBA%'
            OR COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '% MBA%' THEN 'MBA'
          ELSE NULL
        END AS degree_group
      FROM profil_studium ps
      JOIN profil p ON p.id = ps.pid
      JOIN studium s ON s.id = ps.studium
      JOIN noten_students ns ON ns.sid = ps.id AND ns.parent = 0
      WHERE ps.graduation_date IS NOT NULL
 --       AND ps.graduation_date >= DATE_SUB(CURDATE(), INTERVAL 4 YEAR)
        AND ns.gpa IS NOT NULL
        AND ns.gpa <> 0
    ) base
    JOIN (
      SELECT degree_group, COUNT(*) AS n_in_group
      FROM (
        SELECT
          CASE
            WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '%B.A.%'  THEN 'B.A.'
            WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '%B.Sc.%' THEN 'B.Sc.'
            WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '%M.A.%'  THEN 'M.A.'
            WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '%M.Sc.%' THEN 'M.Sc.'
            WHEN COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE 'MBA%'
              OR COALESCE(s.name, s.bez_zeugnis_en, s.bez_zeugnis) LIKE '% MBA%' THEN 'MBA'
            ELSE NULL
          END AS degree_group
        FROM profil_studium ps
        JOIN studium s ON s.id = ps.studium
        JOIN noten_students ns ON ns.sid = ps.id AND ns.parent = 0
        WHERE ps.graduation_date IS NOT NULL
          AND ps.graduation_date >= DATE_SUB(CURDATE(), INTERVAL 4 YEAR)
          AND ns.gpa IS NOT NULL
          AND ns.gpa <> 0
      ) x
      WHERE degree_group IS NOT NULL
      GROUP BY degree_group
    ) cnt ON cnt.degree_group = base.degree_group
    WHERE base.degree_group IS NOT NULL
    ORDER BY base.degree_group, base.gpa ASC, base.student_id
    LIMIT 18446744073709551615
  ) ordered
  CROSS JOIN (SELECT @rn := 0, @grp := '') vars
) r
ORDER BY r.degree_group, r.rn;
