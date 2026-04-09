#' Require cohort subjects have a current event in clinical tables
#'
#' @description
#' `requireCurrentEvent()` filters cohort records, keeping only those for
#' which the index date corresponds to a "current event" in the specified
#' clinical tables. A current event is defined as a record where the date field
#' and the date part of the datetime field are equal, distinguishing confirmed
#' current events from historical or discordant events.
#'
#' @inheritParams cohortDoc
#' @inheritParams cohortIdModifyDoc
#' @inheritParams nameDoc
#' @param tables A character vector specifying the names of the tables to
#' check for current events. Default is `c("condition_occurrence", "procedure_occurrence",
#' "observation")`.
#' @param indexDate Name of the column in the cohort that contains the date of
#' interest to match with the event date.
#'
#' @return A modified cohort table
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(CohortConstructor)
#' cdm <- mockCohortConstructor()
#' cdm$cohort1 <- requireCurrentEvent(cdm$cohort1)
#' }
requireCurrentEvent <- function(cohort,
                                tables = c(
                                  "condition_occurrence",
                                  "procedure_occurrence",
                                  "observation"
                                ),
                                cohortId = NULL,
                                indexDate = "cohort_start_date",
                                name = tableName(cohort)) {
  # checks
  name <- omopgenerics::validateNameArgument(name, validation = "warning")
  cohort <- omopgenerics::validateCohortArgument(cohort)
  validateCohortColumn(indexDate, cohort, class = "date")
  cdm <- omopgenerics::validateCdmArgument(omopgenerics::cdmReference(cohort))
  cohortId <- omopgenerics::validateCohortIdArgument(cohortId, cohort, validation = "warning")
  omopgenerics::assertCharacter(tables, null = TRUE)

  if (length(cohortId) == 0) {
    cli::cli_inform("Returning entry cohort as `cohortId` is not valid.")
    # return entry cohort as cohortId is used to modify not subset
    cdm[[name]] <- cohort |> dplyr::compute(name = name, temporary = FALSE,
                                            logPrefix = "CohortConstructor_requireCurrentEvent_entry_")
    return(cdm[[name]])
  }

  if (is.null(tables)) {
    return(cohort |> dplyr::compute(name = name, temporary = FALSE,
                                    logPrefix = "CohortConstructor_requireCurrentEvent_null_"))
  }

  tables_to_check <- intersect(tables, names(cdm))

  if (length(tables_to_check) == 0) {
    cli::cli_inform("None of the specified tables were found in the cdm object.")
    return(cohort |> dplyr::compute(name = name, temporary = FALSE,
                                    logPrefix = "CohortConstructor_requireCurrentEvent_notables_"))
  }

  tablePrefix <- omopgenerics::tmpPrefix()
  tmpNewCohort <- omopgenerics::uniqueTableName(tablePrefix)
  tmpUnchanged <- omopgenerics::uniqueTableName(tablePrefix)
  cdm <- filterCohortInternal(cdm, cohort, cohortId, tmpNewCohort, tmpUnchanged)
  newCohort <- cdm[[tmpNewCohort]]

  # Mapping of table names to their date and datetime prefixes
  table_prefixes <- list(
    "condition_occurrence" = "condition_start",
    "procedure_occurrence" = "procedure",
    "observation" = "observation",
    "measurement" = "measurement",
    "drug_exposure" = "drug_exposure_start",
    "visit_occurrence" = "visit_start",
    "device_exposure" = "device_exposure_start",
    "specimen" = "specimen",
    "note" = "note"
  )

  valid_events <- list()
  for (tbl_name in tables_to_check) {
    prefix <- table_prefixes[[tbl_name]]

    if (is.null(prefix)) {
      cli::cli_warn(sprintf("Table '%s' is not a recognized clinical table. Skipping.", tbl_name))
      next
    }

    date_col <- paste0(prefix, "_date")
    datetime_col <- paste0(prefix, "_datetime")

    cols <- colnames(cdm[[tbl_name]])

    if (date_col %in% cols && datetime_col %in% cols) {
      valid_events[[tbl_name]] <- cdm[[tbl_name]] |>
        dplyr::filter(as.Date(.data[[date_col]]) == as.Date(.data[[datetime_col]])) |>
        dplyr::select("subject_id" = "person_id", !!indexDate := dplyr::all_of(date_col)) |>
        dplyr::distinct()
    } else {
      if (tbl_name %in% c("condition_occurrence", "procedure_occurrence", "observation")) {
        cli::cli_warn(sprintf("Table '%s' does not have both '%s' and '%s' columns. Skipping.", tbl_name, date_col, datetime_col))
      }
    }
  }

  if (length(valid_events) == 0) {
    # No events found, return empty subset for this cohortId
    newCohort <- newCohort |> dplyr::filter(FALSE)
    reason <- "No valid current events found"
  } else {
    # Union all valid events across tables
    all_events <- valid_events[[1]]
    if (length(valid_events) > 1) {
      for (i in 2:length(valid_events)) {
        all_events <- dplyr::union(all_events, valid_events[[i]])
      }
    }

    newCohort <- newCohort |>
      dplyr::inner_join(
        all_events |> dplyr::distinct(),
        by = c("subject_id", indexDate)
      ) |>
      dplyr::compute(name = tmpNewCohort, temporary = FALSE,
                     logPrefix = "CohortConstructor_requireCurrentEvent_join_")
    
    reason <- paste0("Current event in ", paste0(names(valid_events), collapse = " or "), " on ", indexDate)
  }

  if (isTRUE(needsIdFilter(cohort, cohortId))) {
    newCohort <- newCohort |>
      dplyr::union_all(cdm[[tmpUnchanged]]) |>
      dplyr::compute(name = tmpNewCohort, temporary = FALSE,
                     logPrefix = "CohortConstructor_requireCurrentEvent_union_")
  }

  newCohort <- newCohort |>
    dplyr::compute(name = name, temporary = FALSE,
                   logPrefix = "CohortConstructor_requireCurrentEvent_name_") |>
    omopgenerics::newCohortTable(.softValidation = TRUE) |>
    omopgenerics::recordCohortAttrition(reason = reason, cohortId = cohortId)

  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(tablePrefix))

  useIndexes <- getOption("CohortConstructor.use_indexes")
  if (!isFALSE(useIndexes)) {
    addIndex(
      cohort = newCohort,
      cols = c("subject_id", "cohort_start_date")
    )
  }

  return(newCohort)
}
