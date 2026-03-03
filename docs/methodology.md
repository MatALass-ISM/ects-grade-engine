# Methodology

1) Build a clean base dataset (eligible rows only)
2) Normalize program -> degree_group
3) Partition by degree_group
4) Rank by GPA within each group (deterministic tie-break on student_id)
5) Convert rank to percentile
6) Map percentile to ECTS grade bands

Grade bands:
- A <= 10
- B <= 35
- C <= 65
- D <= 90
- E > 90