# Create cohorts based on patient demographics

`demographicsCohort()` creates a cohort table based on patient
characteristics. If and when an individual satisfies all the criteria
they enter the cohort. When they stop satisfying any of the criteria
their cohort entry ends.

## Usage

``` r
demographicsCohort(
  cdm,
  name,
  ageRange = NULL,
  sex = NULL,
  minPriorObservation = NULL
)
```

## Arguments

- cdm:

  A cdm reference.

- name:

  Name of the new cohort table created in the cdm object.

- ageRange:

  A list of vectors specifying minimum and maximum age.

- sex:

  Can be "Both", "Male" or "Female".

- minPriorObservation:

  A minimum number of continuous prior observation days in the database.

## Value

A cohort table

## Examples

``` r
# \donttest{
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
library(CohortConstructor)

cdm <- mockCohortConstructor()

cohort <-  cdm |>
    demographicsCohort(name = "cohort3", ageRange = c(18,40), sex = "Male")

attrition(cohort)

# Can also create multiple demographic cohorts, and add minimum prior history requirements.

cohort <- cdm |>
    demographicsCohort(name = "cohort4",
    ageRange = list(c(0, 19),c(20, 64),c(65, 150)),
    sex = c("Male", "Female", "Both"),
    minPriorObservation = 365)

attrition(cohort)
}
# }
```
