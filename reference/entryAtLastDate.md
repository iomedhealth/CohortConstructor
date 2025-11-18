# Set cohort start date to the last of a set of column dates

`entryAtLastDate()` resets cohort end date based on a set of specified
column dates. The last date is chosen.

## Usage

``` r
entryAtLastDate(
  cohort,
  dateColumns,
  cohortId = NULL,
  returnReason = FALSE,
  keepDateColumns = TRUE,
  name = tableName(cohort),
  .softValidation = FALSE
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference.

- dateColumns:

  Character vector indicating date columns in the cohort table to
  consider.

- cohortId:

  Vector identifying which cohorts to modify (cohort_definition_id or
  cohort_name). If NULL, all cohorts will be used; otherwise, only the
  specified cohorts will be modified, and the rest will remain
  unchanged.

- returnReason:

  If TRUE it will return a column indicating which of the `dateColumns`
  was used.

- keepDateColumns:

  If TRUE the returned cohort will keep columns in `dateColumns`.

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

The cohort table.

## Examples

``` r
# \donttest{
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
library(CohortConstructor)
library(PatientProfiles)

cdm <- mockCohortConstructor()

cdm$cohort1 <- cdm$cohort1 |>
  addTableIntersectDate(
    tableName = "drug_exposure",
    nameStyle = "prior_drug",
    order = "last",
    window = c(-Inf, 0)
  ) |>
  addPriorObservation(priorObservationType = "date", name = "cohort1")

cdm$cohort1 |>
  entryAtLastDate(dateColumns = c("prior_drug", "prior_observation"))
}
# }
```
