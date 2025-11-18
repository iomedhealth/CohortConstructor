# Set cohort start or cohort end

Set cohort start or cohort end

## Usage

``` r
padCohortDate(
  cohort,
  days,
  cohortDate = "cohort_start_date",
  indexDate = "cohort_start_date",
  collapse = TRUE,
  requireFullContribution = FALSE,
  cohortId = NULL,
  name = tableName(cohort),
  .softValidation = FALSE
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- days:

  Integer with the number of days to add or name of a column (that must
  be numeric) to add.

- cohortDate:

  'cohort_start_date' or 'cohort_end_date'.

- indexDate:

  Variable in cohort that contains the index date to add.

- collapse:

  Whether to collapse the overlapping records (TRUE) or drop the records
  that have an ongoing prior record.

- requireFullContribution:

  Whether to require individuals to contribute all required days. If
  TRUE, those individuals for which adding days would take them out of
  observation will be dropped. If FALSE, days will only be added up to
  the day when the individual leaves observation.

- cohortId:

  Vector identifying which cohorts to modify (cohort_definition_id or
  cohort_name). If NULL, all cohorts will be used; otherwise, only the
  specified cohorts will be modified, and the rest will remain
  unchanged.

- name:

  Name of the new cohort table created in the cdm object.

- .softValidation:

  Whether to perform a soft validation of consistency. If set to FALSE
  four additional checks will be performed: 1) a check that cohort end
  date is not before cohort start date, 2) a check that there are no
  missing values in required columns, 3) a check that cohort duration is
  all within observation period, and 4) that there are no overlapping
  cohort entries

## Value

Cohort table

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()
cdm$cohort1 |>
  padCohortDate(
    cohortDate = "cohort_end_date",
    indexDate = "cohort_start_date",
    days = 10)
}
# }
```
