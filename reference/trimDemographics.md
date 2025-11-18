# Trim cohort on patient demographics

`trimDemographics()` resets the cohort start and end date based on the
specified demographic criteria is satisfied.

## Usage

``` r
trimDemographics(
  cohort,
  cohortId = NULL,
  ageRange = NULL,
  sex = NULL,
  minPriorObservation = NULL,
  minFutureObservation = NULL,
  name = tableName(cohort)
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- cohortId:

  Vector identifying which cohorts to modify (cohort_definition_id or
  cohort_name). If NULL, all cohorts will be used; otherwise, only the
  specified cohorts will be modified, and the rest will remain
  unchanged.

- ageRange:

  A list of vectors specifying minimum and maximum age.

- sex:

  Can be "Both", "Male" or "Female".

- minPriorObservation:

  A minimum number of continuous prior observation days in the database.

- minFutureObservation:

  A minimum number of continuous future observation days in the
  database.

- name:

  Name of the new cohort table created in the cdm object.

## Value

The cohort table with only records for individuals satisfying the
demographic requirements

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()

cdm$cohort1 |>
  trimDemographics(ageRange = list(c(10, 30)))
}
# }
```
