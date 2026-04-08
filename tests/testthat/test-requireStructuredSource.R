test_that("requireStructuredSource correctly filters records", {
  skip_on_cran()
  
  cohort <- dplyr::tibble(
    cohort_definition_id = c(1L, 1L, 1L),
    subject_id = c(1L, 2L, 3L),
    cohort_start_date = as.Date(c("2010-01-02", "2015-05-06", "2020-10-11")),
    cohort_end_date = as.Date(c("2010-01-05", "2015-05-10", "2020-10-15"))
  )
  
  condition_occurrence <- dplyr::tibble(
    condition_occurrence_id = 1:4,
    person_id = c(1L, 2L, 2L, 3L),
    condition_concept_id = c(1L, 2L, 2L, 3L),
    condition_start_date = as.Date(c("2010-01-02", "2015-05-06", "2015-05-07", "2020-10-11")),
    condition_end_date = as.Date(c("2010-01-03", "2015-05-07", "2015-05-08", "2020-10-12")),
    condition_type_concept_id = c(32817L, 32831L, 32858L, 0L) # 1 and 2 are structured, 3 is NLP, 4 is other
  )
  
  # create codelist attr
  codelist_df <- dplyr::tibble(
    cohort_definition_id = c(1L, 1L, 1L),
    codelist_name = c("cond_1", "cond_2", "cond_3"),
    concept_id = c(1L, 2L, 3L),
    codelist_type = "index event"
  )
  
  cdm <- omock::mockCdmFromTables(
    tables = list(
      "condition_occurrence" = condition_occurrence,
      "cohort" = cohort
    )
  ) |>
    copyCdm()

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "cohort_codelist", table = codelist_df)
  
  cdm$cohort <- omopgenerics::newCohortTable(
    table = cdm$cohort, 
    cohortCodelistRef = cdm$cohort_codelist,
    .softValidation = TRUE
  )
  
  cdm$cohort_filtered <- requireStructuredSource(
    cohort = cdm$cohort,
    tableName = "condition_occurrence",
    typeConceptIds = c(32817, 32831),
    window = c(0, 0),
    name = "cohort_filtered"
  )
  
  res <- cdm$cohort_filtered |> dplyr::collect()
  
  expect_equal(nrow(res), 2)
  expect_equal(sort(res$subject_id), c(1, 2))
  
  attrition <- omopgenerics::attrition(cdm$cohort_filtered)
  expect_equal(attrition$reason[2], "Structured source required from condition_occurrence (type concept 32817, 32831)")
  
  # Error cases
  # Missing codelist
  cdm$cohort_no_codelist <- cdm$cohort
  attr(cdm$cohort_no_codelist, "cohort_codelist") <- NULL
  expect_error(
    requireStructuredSource(cdm$cohort_no_codelist),
    "does not have a 'cohort_codelist' attribute"
  )
  
  # Missing column
  cdm_missing_col <- cdm
  cdm_missing_col$condition_occurrence <- cdm_missing_col$condition_occurrence |> 
    dplyr::select(-"condition_type_concept_id")
  expect_error(
    requireStructuredSource(cdm$cohort, cdm_missing_col),
    "not found in table"
  )
})
