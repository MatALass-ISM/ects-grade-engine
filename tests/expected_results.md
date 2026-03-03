# Expected Results (Qualitative)

## Distribution
For each `degree_group`, grade proportions should roughly match:
- A: 10%
- B: 25%
- C: 30%
- D: 25%
- E: 10%

Small cohorts (< 10 students) will naturally deviate.

## Determinism
Given identical source data, output must be stable across runs.
Tie-breaking is done via `(gpa, student_id)`.