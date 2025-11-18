# Restrict cohort on sex

`requireSex()` filters cohort records, keeping only records where
individuals satisfy the specified sex criteria.

## Usage

``` r
requireSex(
  cohort,
  sex,
  cohortId = NULL,
  atFirst = FALSE,
  name = tableName(cohort)
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- sex:

  Can be "Both", "Male" or "Female".

- cohortId:

  Vector identifying which cohorts to modify (cohort_definition_id or
  cohort_name). If NULL, all cohorts will be used; otherwise, only the
  specified cohorts will be modified, and the rest will remain
  unchanged.

- atFirst:

  If FALSE the requirement will be applied to all records, if TRUE, it
  will only be required for the first entry of each subject.

- name:

  Name of the new cohort table created in the cdm object.

## Value

The cohort table with only records for individuals satisfying the sex
requirement

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()
cdm$cohort1 |>
  requireSex(sex = "Female")
}
# }
```
