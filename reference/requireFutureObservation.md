# Restrict cohort on future observation

`requireFutureObservation()` filters cohort records, keeping only
records where individuals satisfy the specified future observation
criteria.

## Usage

``` r
requireFutureObservation(
  cohort,
  minFutureObservation,
  cohortId = NULL,
  indexDate = "cohort_start_date",
  atFirst = FALSE,
  name = tableName(cohort)
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- minFutureObservation:

  A minimum number of continuous future observation days in the
  database.

- cohortId:

  Vector identifying which cohorts to modify (cohort_definition_id or
  cohort_name). If NULL, all cohorts will be used; otherwise, only the
  specified cohorts will be modified, and the rest will remain
  unchanged.

- indexDate:

  Variable in cohort that contains the date to compute the demographics
  characteristics on which to restrict on.

- atFirst:

  If FALSE the requirement will be applied to all records, if TRUE, it
  will only be required for the first entry of each subject.

- name:

  Name of the new cohort table created in the cdm object.

## Value

The cohort table with only records for individuals satisfying the future
observation requirement

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()
cdm$cohort1 |>
  requireFutureObservation(indexDate = "cohort_start_date",
                           minFutureObservation = 30)
}
# }
```
