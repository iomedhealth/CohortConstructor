#' Require cohort subjects to have a structured source record
#'
#' @description
#' `requireStructuredSource()` filters a cohort table to only keep records where
#' the underlying clinical event comes from a structured data source (e.g.,
#' `condition_type_concept_id` in `32817`, `32831`), excluding NLP-only events
#' like `32858`.
#'
#' @inheritParams requireIntersectDoc
#' @inheritParams cohortDoc
#' @inheritParams cohortIdModifyDoc
#' @inheritParams windowDoc
#' @inheritParams nameDoc
#' @param tableName Name of the clinical table to check for the structured source (default: "condition_occurrence").
#' @param typeConceptIds A vector of integer concept IDs representing structured sources. Default: `c(32817, 32831)`.
#' 
#' @return Cohort table
#'
#' @export
#'
requireStructuredSource <- function(cohort,
                                    tableName = "condition_occurrence",
                                    typeConceptIds = c(32817, 32831),
                                    window = c(0, 0),
                                    cohortId = NULL,
                                    indexDate = "cohort_start_date",
                                    targetStartDate = startDateColumn(tableName),
                                    targetEndDate = endDateColumn(tableName),
                                    name = tableName(cohort)) {
  # validation
  name <- omopgenerics::validateNameArgument(name, validation = "warning")
  cohort <- omopgenerics::validateCohortArgument(cohort)
  cdm <- omopgenerics::validateCdmArgument(omopgenerics::cdmReference(cohort))
  cohortId <- omopgenerics::validateCohortIdArgument(cohortId, cohort, validation = "warning")
  omopgenerics::assertCharacter(tableName)
  typeConceptIds <- as.integer(typeConceptIds)
  
  if (!tableName %in% names(cdm)) {
    cli::cli_abort("Table '{tableName}' not found in the cdm reference.")
  }

  codelist_name <- paste0(omopgenerics::tableName(cohort), "_codelist")
  if (codelist_name %in% names(cdm)) {
    codelist_df <- cdm[[codelist_name]] |> dplyr::collect()
  } else {
    codelist_ref <- attr(cohort, "cohort_codelist")
    if (is.null(codelist_ref)) {
      cli::cli_abort("The cohort does not have a 'cohort_codelist' attribute. requireStructuredSource requires this to map concepts.")
    }
    codelist_df <- dplyr::collect(codelist_ref)
  }

  attrition_name <- paste0(omopgenerics::tableName(cohort), "_attrition")
  if (attrition_name %in% names(cdm)) {
    attrition_df <- cdm[[attrition_name]] |> dplyr::collect()
  } else {
    attrition_df <- dplyr::collect(attr(cohort, "cohort_attrition"))
  }
  
  set_name <- paste0(omopgenerics::tableName(cohort), "_set")
  if (set_name %in% names(cdm)) {
    set_df <- cdm[[set_name]] |> dplyr::collect()
  } else {
    set_df <- dplyr::collect(attr(cohort, "cohort_set"))
  }

  if (nrow(codelist_df) == 0) {
    cli::cli_abort("The cohort does not have a 'cohort_codelist' attribute. requireStructuredSource requires this to map concepts.")
  }
  
  # Filter codelist to relevant cohort definitions
  if (is.null(cohortId)) {
    target_concepts <- codelist_df |> 
      dplyr::select("concept_id") |>
      dplyr::distinct()
  } else {
    target_concepts <- codelist_df |> 
      dplyr::filter(.data$cohort_definition_id %in% .env$cohortId) |>
      dplyr::select("concept_id") |>
      dplyr::distinct()
  }

  codelist_ref <- attr(cohort, "cohort_codelist")
  if (is.null(codelist_ref)) {
    cli::cli_abort("The cohort does not have a 'cohort_codelist' attribute. requireStructuredSource requires this to map concepts.")
  }
  codelist_df <- dplyr::collect(codelist_ref)
  if (nrow(codelist_df) == 0) {
    cli::cli_abort("The cohort does not have a 'cohort_codelist' attribute. requireStructuredSource requires this to map concepts.")
  }
  
  # Filter codelist to relevant cohort definitions
  if (is.null(cohortId)) {
    target_concepts <- codelist_df |> 
      dplyr::select("concept_id") |>
      dplyr::distinct()
  } else {
    target_concepts <- codelist_df |> 
      dplyr::filter(.data$cohort_definition_id %in% .env$cohortId) |>
      dplyr::select("concept_id") |>
      dplyr::distinct()
  }
  
  # capture original attributes
  cohort_set_ref <- attr(cohort, "cohort_set") |> dplyr::collect()
  cohort_attrition_ref <- attr(cohort, "cohort_attrition") |> dplyr::collect()
  cohort_codelist_ref <- attr(cohort, "cohort_codelist") |> dplyr::collect()
  
  tablePrefix <- omopgenerics::tmpPrefix()
  tmpNewCohort <- omopgenerics::uniqueTableName(tablePrefix)
  tmpUnchanged <- omopgenerics::uniqueTableName(tablePrefix)
  cdm <- filterCohortInternal(cdm, cohort, cohortId, tmpNewCohort, tmpUnchanged)
  newCohort <- cdm[[tmpNewCohort]]
  
  typeColName <- paste0(gsub("_occurrence", "", tableName), "_type_concept_id")
  if (!typeColName %in% colnames(cdm[[tableName]])) {
    cli::cli_abort("Type concept column '{typeColName}' not found in table '{tableName}'.")
  }
  conceptColName <- paste0(gsub("_occurrence", "", tableName), "_concept_id")
  if (!conceptColName %in% colnames(cdm[[tableName]])) {
    cli::cli_abort("Concept column '{conceptColName}' not found in table '{tableName}'.")
  }
  
  # Inner join with the clinical table to find overlaps
  # We require the clinical record to have the target concept AND be structured
  cdm <- omopgenerics::insertTable(cdm = cdm, name = paste0(tablePrefix, "_tc"), table = target_concepts)
  
  # Ensure the concepts are actually in the cdm to avoid lazy eval failures later
  cdm[[paste0(tablePrefix, "_tc")]] |> dplyr::compute(name = paste0(tablePrefix, "_tc"), temporary = FALSE)
  
  valid_events <- cdm[[tableName]] |>
    dplyr::inner_join(
      cdm[[paste0(tablePrefix, "_tc")]], 
      by = stats::setNames("concept_id", conceptColName)
    ) |>
    dplyr::filter(.data[[typeColName]] %in% .env$typeConceptIds) |>
    dplyr::select(
      person_id = "person_id", 
      target_start = dplyr::all_of(targetStartDate), 
      target_end = dplyr::all_of(targetEndDate)
    ) |>
    dplyr::compute(name = paste0(tablePrefix, "_ve"), temporary = FALSE)

  # Check overlap with cohort entries
  # Convert window offsets
  window_start <- as.integer(window[1])
  window_end <- as.integer(window[2])
  
  # For each cohort entry, check if there is at least one valid structured event in the window
  intersect_counts <- newCohort |>
    dplyr::inner_join(
      valid_events, 
      by = c("subject_id" = "person_id"), 
      relationship = "many-to-many"
    )

  if (window_start != 0L | window_end != 0L) {
    intersect_counts <- intersect_counts %>%
      dplyr::mutate(
        window_start_date = !!CDMConnector::dateadd(indexDate, window_start),
        window_end_date = !!CDMConnector::dateadd(indexDate, window_end)
      ) %>%
      dplyr::filter(
        .data$target_start >= .data$window_start_date,
        .data$target_start <= .data$window_end_date
      )
  } else {
    intersect_counts <- intersect_counts %>%
      dplyr::filter(
        .data$target_start == .data[[indexDate]]
      )
  }

  intersect_counts <- intersect_counts |>
    dplyr::select("cohort_definition_id", "subject_id", "cohort_start_date", "cohort_end_date") |>
    dplyr::distinct() |>
    dplyr::compute(name = paste0(tablePrefix, "_ic"), temporary = FALSE)

  # attrition reason
  reason <- glue::glue("Structured source required from {tableName} (type concept {paste(typeConceptIds, collapse = ', ')})")

  cdm[[name]] <- newCohort |>
    dplyr::inner_join(
      intersect_counts,
      by = c("cohort_definition_id", "subject_id", "cohort_start_date", "cohort_end_date")
    ) |>
    dplyr::select(dplyr::all_of(colnames(newCohort))) |>
    dplyr::compute(name = name, temporary = FALSE)

  if (isTRUE(needsIdFilter(cohort, cohortId))) {
    cdm[[name]] <- cdm[[name]] |>
      dplyr::union_all(
        cdm[[tmpUnchanged]] |>
          dplyr::select(dplyr::all_of(colnames(cdm[[name]])))
      ) |>
      dplyr::compute(name = name, temporary = FALSE)
  }

  # Drop temp tables so we don't hold references to them unnecessarily
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(tablePrefix))

  cdm[[name]] <- cdm[[name]] |>
    omopgenerics::newCohortTable(
      cohortSetRef = set_df,
      cohortAttritionRef = attrition_df,
      cohortCodelistRef = codelist_df,
      .softValidation = TRUE
    ) |>
    omopgenerics::recordCohortAttrition(reason = reason, cohortId = cohortId)

  useIndexes <- getOption("CohortConstructor.use_indexes")
  if (!isFALSE(useIndexes) && exists("addIndex", mode = "function")) {
    addIndex(
      cohort = cdm[[name]],
      cols = c("subject_id", "cohort_start_date")
    )
  }

  return(cdm[[name]])
}
