# Set cohort end date to end of observation

`exitAtObservationEnd()` resets cohort end date based on a set of
specified column dates. The last date that occurs is chosen.

This functions changes cohort end date to the end date of the
observation period corresponding to the cohort entry. In the case were
this generates overlapping records in the cohort, overlapping entries
will be merged.

## Usage

``` r
exitAtObservationEnd(
  cohort,
  cohortId = NULL,
  persistAcrossObservationPeriods = FALSE,
  name = tableName(cohort),
  .softValidation = FALSE
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

- persistAcrossObservationPeriods:

  If FALSE, limits the cohort to one entry per person, ending at the
  current observation period. If TRUE, subsequent observation periods
  will create new cohort entries (starting from the start of that
  observation period and ending at the end of that observation period).

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
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()
cdm$cohort1 |> exitAtObservationEnd()
}
# }
```
