# Set cohort end date to death date

This functions changes cohort end date to subject's death date. In the
case were this generates overlapping records in the cohort, those
overlapping entries will be merged.

## Usage

``` r
exitAtDeath(
  cohort,
  cohortId = NULL,
  requireDeath = FALSE,
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

- requireDeath:

  If TRUE, subjects without a death record will be dropped, while if
  FALSE their end date will be left as is.

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
library(PatientProfiles)
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockPatientProfiles()
cdm$cohort1 |> exitAtDeath()
}
# }
```
