# Data Dictionary

## profil_studium
- id: PK row id
- pid: student id (FK to profil.id)
- studium: program id (FK to studium.id)
- graduation_date: date of graduation (required for inclusion)

## noten_students
- sid: student id
- gpa: numeric grade / average (must be > 0)

## studium
- id: program id
- name: program name (used for group mapping in demo version)

## Output Fields
- degree_group: one of {B.A., B.Sc., M.A., M.Sc., MBA}
- percentile: rank percentile within degree_group
- ects_grade: one of {A,B,C,D,E}