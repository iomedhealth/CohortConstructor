# Generate a cohort table keeping a subset of cohorts.

`subsetCohorts()` filters an existing cohort table, keeping only the
records from cohorts that are specified.

## Usage

``` r
subsetCohorts(cohort, cohortId, name = tableName(cohort))
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- cohortId:

  Vector identifying which cohorts to include (cohort_definition_id or
  cohort_name). Cohorts not included will be removed from the cohort
  set.

- name:

  Name of the new cohort table created in the cdm object.

## Value

Cohort table with only cohorts in cohortId.

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()

cdm$cohort1 |>
  subsetCohorts(cohortId = 1)
}
# }
```
