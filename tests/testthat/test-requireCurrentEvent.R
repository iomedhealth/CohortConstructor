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
    ), tz = "UTC"),
    condition_end_date = as.Date(c("2010-01-02", "2010-01-02", "2015-05-06", "2018-08-09")),
    condition_end_datetime = as.POSIXct(rep(NA, 4), tz = "UTC"),
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
    ), tz = "UTC"),
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
    ), tz = "UTC"),
    observation_type_concept_id = 0L
  )

  cohort1 <- dplyr::tibble(
    cohort_definition_id = 1L,
    subject_id = c(1L, 1L, 1L, 2L, 2L, 2L),
    cohort_start_date = as.Date(c(
      "2010-01-01", # Should match condition
      "2012-02-02", # Should match procedure
      "2011-11-11", # Should NOT match observation (discordant datetime)
      "2015-05-05", # Should match condition
      "2016-06-06", # Should NOT match procedure (discordant datetime)
      "2014-04-04"  # Should match observation
    )),
    cohort_end_date = as.Date(c(
      "2010-01-02",
      "2012-02-03",
      "2011-11-12",
      "2015-05-06",
      "2016-06-07",
      "2014-04-05"
    ))
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
  
  cdm <- omopgenerics::insertTable(cdm, "cohort1", cohort1)
  cdm$cohort1 <- omopgenerics::newCohortTable(cdm$cohort1)
  
  if (exists("copyCdm", mode = "function")) {
    cdm <- copyCdm(cdm)
  }
  
  cdm$cohort2 <- requireCurrentEvent(cdm$cohort1, name = "cohort2")
  
  res <- cdm$cohort2 |> dplyr::collect() |> dplyr::arrange(subject_id, cohort_start_date)
  
  expect_equal(nrow(res), 4)
  expect_equal(res$subject_id, c(1L, 1L, 2L, 2L))
  expect_equal(res$cohort_start_date, as.Date(c("2010-01-01", "2012-02-02", "2014-04-04", "2015-05-05")))
  
  attrition <- omopgenerics::attrition(cdm$cohort2)
  expect_equal(nrow(attrition), 2)
  expect_true(grepl("Current event in", attrition$reason[2]))
})

test_that("requireCurrentEvent handles missing tables gracefully", {
  skip_on_cran()
  
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

  cohort1 <- dplyr::tibble(
    cohort_definition_id = 1L,
    subject_id = c(1L, 1L, 1L, 2L, 2L, 2L),
    cohort_start_date = as.Date(c(
      "2010-01-01",
      "2012-02-02",
      "2011-11-11",
      "2015-05-05",
      "2016-06-06",
      "2014-04-04"
    )),
    cohort_end_date = as.Date(c(
      "2010-01-02",
      "2012-02-03",
      "2011-11-12",
      "2015-05-06",
      "2016-06-07",
      "2014-04-05"
    ))
  )

  cdm <- omock::mockCdmFromTables(tables = list()) |>
    omopgenerics::insertTable(name = "observation_period", table = obs) |>
    omopgenerics::insertTable(name = "person", table = person)
  
  cdm <- omopgenerics::insertTable(cdm, "cohort1", cohort1)
  cdm$cohort1 <- omopgenerics::newCohortTable(cdm$cohort1)
  
  if (exists("copyCdm", mode = "function")) {
    cdm <- copyCdm(cdm)
  }
  
  expect_message(
    cdm$cohort2 <- requireCurrentEvent(cdm$cohort1, tables = "random_table", name = "cohort2"),
    "None of the specified tables were found"
  )
  
  # Cohort should remain unchanged except for name
  expect_equal(nrow(cdm$cohort1 |> dplyr::collect()), nrow(cdm$cohort2 |> dplyr::collect()))
})
