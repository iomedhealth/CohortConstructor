# Filter cohorts to keep only records for those with a minimum amount of subjects

`requireMinCohortCount()` filters an existing cohort table, keeping only
records from cohorts with a minimum number of individuals

## Usage

``` r
requireMinCohortCount(
  cohort,
  minCohortCount,
  cohortId = NULL,
  updateSettings = FALSE,
  name = tableName(cohort)
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- minCohortCount:

  The minimum count of sbjects for a cohort to be included.

- cohortId:

  Vector identifying which cohorts to modify (cohort_definition_id or
  cohort_name). If NULL, all cohorts will be used; otherwise, only the
  specified cohorts will be modified, and the rest will remain
  unchanged.

- updateSettings:

  If TRUE, dropped cohorts will also be removed from all cohort table
  attributes (i.e., settings, attrition, counts, and codelist). If
  FALSE, these attributes will be retained but updated to reflect that
  the affected cohorts have been suppressed.

- name:

  Name of the new cohort table created in the cdm object.

## Value

Cohort table

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()

cdm$cohort1 |>
requireMinCohortCount(5)
}
# }
```
