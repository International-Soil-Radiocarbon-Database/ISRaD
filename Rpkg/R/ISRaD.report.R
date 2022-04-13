#' ISRaD.report
#'
#' @description Generate basic summary reports of ISRaD data
#'
#' @param database ISRaD data object
#' @param report Parameter to define which type of report is desired. The default is "count.all" other options include "entry.stats", "count.frc", or "site.map".
#' @details Wrapper for the simple reporting functions ISRaD.rep.count.all, ISRaD.rep.count.frc, ISRaD.rep.entry.stats, ISRaD.rep.site.map
#' @export
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Report metadata statistics
#' ISRaD.report(database, report = "entry.stats")
#' # Report summary statistics for all levels of the database
#' ISRaD.report(database, report = "count.all")
#' # Generate a map of all ISRaD sites
#' ISRaD.report(database, report = "site.map")
#' }
#'
ISRaD.report <- function(database, report) {
  stopifnot(is_israd_database(database))
  stopifnot(is.character(report))

  if (report == "entry.stats") {
    out <- ISRaD.rep.entry.stats(database)
  } else if (report == "count.all") {
    out <- ISRaD.rep.count.all(database)
  } else if (report == "count.frc") {
    out <- ISRaD.rep.count.frc(database)
  } else if (report == "site.map") {
    out <- ISRaD.rep.site.map(database)
  } else {
    stop("Unknown report type ", report)
  }
  return(out)
}
