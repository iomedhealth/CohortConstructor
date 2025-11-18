# Sample a cohort table for a given number of individuals.

`sampleCohorts()` samples an existing cohort table for a given number of
people. All records of these individuals are preserved.

## Usage

``` r
sampleCohorts(cohort, n, cohortId = NULL, name = tableName(cohort))
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- n:

  Number of people to be sampled for each included cohort.

- cohortId:

  Vector identifying which cohorts to modify (cohort_definition_id or
  cohort_name). If NULL, all cohorts will be used; otherwise, only the
  specified cohorts will be modified, and the rest will remain
  unchanged.

- name:

  Name of the new cohort table created in the cdm object.

## Value

Cohort table with the specified cohorts sampled.

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()

cdm$cohort2 |> sampleCohorts(cohortId = 1, n = 10)
}
# }
```
