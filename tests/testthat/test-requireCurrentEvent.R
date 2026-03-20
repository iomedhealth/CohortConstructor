source("../../R/requireCurrentEvent.R")
library(omopgenerics)

test_that("requireCurrentEvent correctly filters out discordant dates", {
  skip_on_cran()
  
  # Set up a mock CDM
  person <- dplyr::tibble(
    person_id = 1:2,
    gender_concept_id = c(8532L, 8507L),
    year_of_birth = c(1997L, 1963L),
    month_of_birth = c(8L, 1L),
    day_of_birth = c(22L, 27L),
    race_concept_id = NA_integer_,
    ethnicity_concept_id = NA_integer_
  )
  
  obs <- dplyr::tibble(
    observation_period_id = 1:2,
    person_id = 1:2,
    observation_period_start_date = as.Date(c("2000-01-01", "2000-01-01")),
    observation_period_end_date = as.Date(c("2020-12-31", "2020-12-31")),
    period_type_concept_id = NA_integer_
  )
  
  condition_occurrence <- dplyr::tibble(
    condition_occurrence_id = 1:4,
    person_id = c(1L, 1L, 2L, 2L),
    condition_concept_id = c(1L, 2L, 3L, 4L),
    condition_start_date = as.Date(c("2010-01-01", "2010-01-01", "2015-05-05", "2018-08-08")),
    condition_start_datetime = as.POSIXct(c(
      "2010-01-01 10:00:00", # Match
      "2012-01-01 10:00:00", # Discordant datetime year
      "2015-05-05 15:30:00", # Match
      NA                     # Missing datetime
    )),
    condition_end_date = as.Date(c("2010-01-02", "2010-01-02", "2015-05-06", "2018-08-09")),
    condition_end_datetime = as.POSIXct(rep(NA, 4)),
    condition_type_concept_id = 0L
  )
  
  procedure_occurrence <- dplyr::tibble(
    procedure_occurrence_id = 1:2,
    person_id = c(1L, 2L),
    procedure_concept_id = c(1L, 2L),
    procedure_date = as.Date(c("2012-02-02", "2016-06-06")),
    procedure_datetime = as.POSIXct(c(
      "2012-02-02 08:00:00", # Match
      "2016-06-07 08:00:00"  # Discordant day
    )),
    procedure_type_concept_id = 0L
  )
  
  observation <- dplyr::tibble(
    observation_id = 1:2,
    person_id = c(1L, 2L),
    observation_concept_id = c(1L, 2L),
    observation_date = as.Date(c("2011-11-11", "2014-04-04")),
    observation_datetime = as.POSIXct(c(
      "2010-11-11 11:11:11", # Discordant year
      "2014-04-04 14:14:14"  # Match
    )),
    observation_type_concept_id = 0L
  )
  
  cdm <- omock::mockCdmFromTables(
    tables = list(
      "condition_occurrence" = condition_occurrence,
      "procedure_occurrence" = procedure_occurrence,
      "observation" = observation
    )
  ) |>
    omopgenerics::insertTable(name = "observation_period", table = obs) |>
    omopgenerics::insertTable(name = "person", table = person)
  
  if (exists("copyCdm", mode = "function")) {
    cdm <- copyCdm(cdm)
  }
  
  cdm <- requireCurrentEvent(cdm)
  
  # Condition should have 2 records left (ID 1 and 3)
  cond_res <- cdm$condition_occurrence |> dplyr::collect()
  expect_equal(nrow(cond_res), 2)
  expect_equal(sort(cond_res$condition_occurrence_id), c(1, 3))
  
  # Procedure should have 1 record left (ID 1)
  proc_res <- cdm$procedure_occurrence |> dplyr::collect()
  expect_equal(nrow(proc_res), 1)
  expect_equal(proc_res$procedure_occurrence_id, 1)
  
  # Observation should have 1 record left (ID 2)
  obs_res <- cdm$observation |> dplyr::collect()
  expect_equal(nrow(obs_res), 1)
  expect_equal(obs_res$observation_id, 2)
})

test_that("requireCurrentEvent handles missing tables gracefully", {
  skip_on_cran()
  
  cdm <- omock::mockCdmFromTables(tables = list())
  
  if (exists("copyCdm", mode = "function")) {
    cdm <- copyCdm(cdm)
  }
  
  expect_message(
    cdm <- requireCurrentEvent(cdm),
    "None of the specified tables were found"
  )
})
