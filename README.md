![CI](https://github.com/MatALass-ISM/ects-grade-engine/actions/workflows/ci.yml/badge.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)
![MySQL](https://img.shields.io/badge/MySQL-8-orange)
![SQLFluff](https://img.shields.io/badge/Linted_with-sqlfluff-purple)
![License](https://img.shields.io/github/license/MatALass-ISM/ects-grade-engine)
![Last Commit](https://img.shields.io/github/last-commit/MatALass-ISM/ects-grade-engine)
![Issues](https://img.shields.io/github/issues/MatALass-ISM/ects-grade-engine)

# ects-grade-engine

> Production-ready SQL model to assign ECTS grades (A--E) based on GPA
> percentile ranking per degree cohort.

------------------------------------------------------------------------

## Overview

`ects-grade-engine` is a SQL-based grading model that assigns **ECTS
grades (A--E)** by ranking students within their degree group and
mapping percentiles to standardized European grade bands.

It is designed to be:

-   Deterministic
-   Reproducible
-   Testable
-   Analytics-pipeline ready
-   Database portable (MySQL 8+ / PostgreSQL supported)

------------------------------------------------------------------------

## Problem

Raw GPA values are not directly comparable across programs.

ECTS grading requires: - Ranking students within comparable cohorts -
Computing percentile distribution - Assigning grades based on
standardized thresholds

  Grade   Percentile Range
  ------- ------------------
  A       Top 10%
  B       Next 25%
  C       Next 30%
  D       Next 25%
  E       Bottom 10%

This repository implements a robust SQL model to perform that process
reliably.

------------------------------------------------------------------------

## Architecture

    .
    ├── README.md
    ├── LICENSE
    ├── sql/
    │   ├── models/
    │   │   ├── 01_degree_group_mapping.sql
    │   │   ├── 02_base_dataset.sql
    │   │   ├── 03_percentile_ranking.sql
    │   │   ├── 04_ects_assignment.sql
    │   │   └── ects_grade_model.sql
    │   ├── views/
    │   │   └── v_ects_grade_v1.sql
    │   └── portable/
    │       ├── mysql8_window_version.sql
    │       └── postgres_version.sql
    ├── tests/
    │   ├── test_distribution.sql
    │   ├── test_edge_cases.sql
    │   └── expected_results.md
    ├── data/
    │   └── demo_seed_anonymized.csv
    ├── docs/
    │   ├── data_dictionary.md
    │   ├── assumptions.md
    │   ├── performance_considerations.md
    │   └── methodology.md
    └── .github/
        └── workflows/
            └── ci.yml

------------------------------------------------------------------------

## Data Contract

### Required Tables

  Table            Required Columns
  ---------------- -----------------------------------
  profil_studium   id, pid, studium, graduation_date
  noten_students   sid, parent, gpa
  studium          id, name
  profil           id

### Assumptions

-   `graduation_date IS NOT NULL`
-   `gpa > 0`
-   GPA ordering direction must be defined explicitly
-   Degree groups should be normalized via mapping table in production

------------------------------------------------------------------------

## Methodology

1.  Normalize degree programs into degree groups\
2.  Filter valid graduation records\
3.  Partition students by degree_group\
4.  Rank by GPA within each group\
5.  Compute percentile rank\
6.  Assign ECTS letter grade

Implementation uses:

-   `ROW_NUMBER() OVER (PARTITION BY ...)`
-   Window functions
-   Deterministic secondary ordering
-   Explicit threshold logic

------------------------------------------------------------------------

## Example Output

  student_id   degree_group   gpa   percentile   ects_grade
  ------------ -------------- ----- ------------ ------------
  10021        M.Sc.          1.1   3.2          A
  10087        M.Sc.          1.8   29.5         B
  10102        M.Sc.          2.3   54.3         C

------------------------------------------------------------------------

## Determinism & Tie Handling

-   Secondary ordering by `student_id`
-   Stable ordering enforced
-   No non-deterministic variable hacks

------------------------------------------------------------------------

## Validation & Testing

Distribution checks per degree group:

-   A ≈ 10%
-   B ≈ 25%
-   C ≈ 30%
-   D ≈ 25%
-   E ≈ 10%

Edge cases tested:

-   Small cohorts
-   Identical GPA ties
-   Missing graduation dates
-   Zero GPA

------------------------------------------------------------------------

## Performance Considerations

-   Normalize degree group mapping into dimension table
-   Avoid LIKE pattern matching in production
-   Recommended indexes:
    -   graduation_date
    -   gpa
    -   degree_group

------------------------------------------------------------------------

## Versioning Strategy

Views are versioned:

-   `v_ects_grade_v1`
-   Future updates will create `v_ects_grade_v2`

Backward compatibility preserved.

------------------------------------------------------------------------

## Why this project matters

This project demonstrates:

-   SQL architecture structuring
-   Window function mastery
-   Percentile modeling
-   Data quality validation
-   Reproducible analytics design

It is not just a query --- it is a grading engine.

------------------------------------------------------------------------

## Roadmap

-   dbt implementation
-   Configurable threshold table
-   CLI wrapper for batch grading
-   Automated CI validation
-   Statistical bias analysis for small cohorts

------------------------------------------------------------------------

## License

MIT
