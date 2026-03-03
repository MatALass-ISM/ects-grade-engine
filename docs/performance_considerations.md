# Performance Considerations

## Avoid runtime LIKE classification
Text pattern classification (`LIKE '%M.Sc.%'`) is slow and error-prone.
Prefer a mapping table:
- program_id -> degree_group

## Indexes
Recommended (depending on DB):
- profil_studium(pid)
- profil_studium(studium)
- profil_studium(graduation_date)
- noten_students(sid)
- noten_students(gpa)

## Window functions
ROW_NUMBER and COUNT OVER are efficient with correct indexes and partition sizes.