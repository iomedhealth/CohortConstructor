# Create cohort based on the death table

Create cohort based on the death table

## Usage

``` r
deathCohort(cdm, name, subsetCohort = NULL, subsetCohortId = NULL)
```

## Arguments

- cdm:

  A cdm reference.

- name:

  Name of the new cohort table created in the cdm object.

- subsetCohort:

  A character refering to a cohort table containing individuals for whom
  cohorts will be generated. Only individuals in this table will appear
  in the generated cohort.

- subsetCohortId:

  Optional. Specifies cohort IDs from the `subsetCohort` table to
  include. If none are provided, all cohorts from the `subsetCohort` are
  included.

## Value

A cohort table with a death cohort in cdm

## Examples

``` r
# \donttest{
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
library(CohortConstructor)

cdm <- mockCohortConstructor()

# Generate a death cohort
death_cohort <- deathCohort(cdm, name = "death_cohort")
death_cohort

# Create a death cohort for females aged over 50 years old.

# Create a demographics cohort with age range and sex filters
cdm$my_cohort <- demographicsCohort(cdm, "my_cohort", ageRange = c(50,100), sex = "Female")

# Generate a death cohort, restricted to individuals in 'my_cohort'
death_cohort <- deathCohort(cdm, name = "death_cohort", subsetCohort = "my_cohort")
death_cohort |> attrition()
}
# }
```
