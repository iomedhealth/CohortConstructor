# Create a new cohort table from stratifying an existing one

`stratifyCohorts()` creates new cohorts, splitting an existing cohort
based on specified columns on which to stratify on.

## Usage

``` r
stratifyCohorts(
  cohort,
  strata,
  cohortId = NULL,
  removeStrata = TRUE,
  name = tableName(cohort)
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- strata:

  A strata list that point to columns in cohort table.

- cohortId:

  Vector identifying which cohorts to include (cohort_definition_id or
  cohort_name). Cohorts not included will be removed from the cohort
  set.

- removeStrata:

  Whether to remove strata columns from final cohort table.

- name:

  Name of the new cohort table created in the cdm object.

## Value

Cohort table stratified.

## Examples

``` r
# \donttest{
library(CohortConstructor)
library(PatientProfiles)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()

cdm$my_cohort <- cdm$cohort1 |>
  addAge(ageGroup = list("child" = c(0, 17), "adult" = c(18, Inf))) |>
  addSex(name = "my_cohort") |>
  stratifyCohorts(
    strata = list("sex", c("sex", "age_group")), name = "my_cohort"
  )

cdm$my_cohort

settings(cdm$my_cohort)

attrition(cdm$my_cohort)
}
# }
```
