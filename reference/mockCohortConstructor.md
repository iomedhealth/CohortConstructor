# Function to create a mock cdm reference for CohortConstructor

`mockCohortConstructor()` creates an example dataset that can be used
for demonstrating and testing the package

## Usage

``` r
mockCohortConstructor(source = "local")
```

## Arguments

- source:

  Source for the mock cdm, it can either be 'local' or 'duckdb'.

## Value

cdm object

## Examples

``` r
# \donttest{
library(CohortConstructor)
if(isTRUE(omock::isMockDatasetDownloaded("GiBleed"))){
cdm <- mockCohortConstructor()

cdm
}
# }
```
