# Require cohort entries last for a certain number of days

`requireDuration()` filters cohort records, keeping only those which
last for the specified amount of days

## Usage

``` r
requireDuration(
  cohort,
  daysInCohort,
  cohortId = NULL,
  name = tableName(cohort)
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- daysInCohort:

  Number of days cohort entries must last. Can be a vector of length two
  if a range, or a vector of length one if a specific number of days.
  Note, cohort entry and exit on the same day counts as one day in the
  cohort. So if, for example, you wish to require individuals are in the
  cohort for at least one night then set daysInCohort to c(2, Inf).
  Meanwhile, if set to c(30, 90) then only cohort entries that are 30
  days or more longer and shorter or equal to 90 days will be kept.

- cohortId:

  Vector identifying which cohorts to modify (cohort_definition_id or
  cohort_name). If NULL, all cohorts will be used; otherwise, only the
  specified cohorts will be modified, and the rest will remain
  unchanged.

- name:

  Name of the new cohort table created in the cdm object.

## Value

The cohort table with any cohort entries that last less or more than the
required duration dropped

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()
cdm$cohort1 |>
  requireDuration(daysInCohort = c(2, Inf))
}
# }
```
