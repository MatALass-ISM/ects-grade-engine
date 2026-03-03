# Assumptions

1) GPA ordering
- Default: lower GPA is better (ASC).
- If your institution uses higher-is-better, switch ordering to DESC.

2) Mapping
- Demo mapping uses text patterns on program name.
- Production: replace with a mapping table to avoid misclassification.

3) Eligibility filters
- graduation_date must be non-null
- gpa must be non-null and > 0