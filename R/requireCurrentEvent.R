#' Filter clinical tables to keep only current events
#'
#' @description
#' `requireCurrentEvent()` filters clinical tables in a CDM object, keeping only
#' records where the date field and the date part of the datetime field are equal.
#' This is used to distinguish confirmed "current events" from historical or
#' discordant events.
#'
#' @param cdm A cdm_reference object.
#' @param tables A character vector specifying the names of the tables to filter.
#' Default is `c("condition_occurrence", "procedure_occurrence", "observation")`.
#'
#' @return A modified cdm_reference object where the specified tables are filtered.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(CohortConstructor)
#' library(omopgenerics)
#' cdm <- mockCohortConstructor()
#' cdm <- requireCurrentEvent(cdm)
#' }
requireCurrentEvent <- function(cdm,
                                tables = c("condition_occurrence",
                                           "procedure_occurrence",
                                           "observation")) {
  # checks
  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(tables, null = TRUE)

  if (is.null(tables)) {
    return(cdm)
  }

  tables_to_filter <- intersect(tables, names(cdm))

  if (length(tables_to_filter) == 0) {
    cli::cli_inform("None of the specified tables were found in the cdm object.")
    return(cdm)
  }

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

  for (tbl_name in tables_to_filter) {
    prefix <- table_prefixes[[tbl_name]]

    if (is.null(prefix)) {
      cli::cli_warn(sprintf("Table '%s' is not a recognized clinical table. Skipping.", tbl_name))
      next
    }

    date_col <- paste0(prefix, "_date")
    datetime_col <- paste0(prefix, "_datetime")

    cols <- colnames(cdm[[tbl_name]])

    if (date_col %in% cols && datetime_col %in% cols) {
      # Use lazy evaluation; omopgenerics will correctly retain OMOP table classes
      cdm[[tbl_name]] <- cdm[[tbl_name]] |>
        dplyr::filter(as.Date(.data[[date_col]]) == as.Date(.data[[datetime_col]]))
    } else {
      # Warn only if it's one of the explicitly requested tables, not just discovered ones
      if (tbl_name %in% c("condition_occurrence", "procedure_occurrence", "observation")) {
        cli::cli_warn(sprintf("Table '%s' does not have both '%s' and '%s' columns. Skipping.", tbl_name, date_col, datetime_col))
      }
    }
  }

  return(cdm)
}
