#' Check ISRaD Template/Info files
#'
#' @description Check that the template information file and the template file match appropriately.
#' @details Used in compile() function, but primarily a development tool
#' @param outfile file to dump the output report. Defaults to an empty string that will print
#' to standard output
#' @param verbose if TRUE (default) will print output to specified outfile
#' @importFrom readxl read_excel excel_sheets
#' @importFrom dplyr group_by filter summarise left_join mutate
#' @importFrom utils type.convert
#' @importFrom stats setNames
#' @importFrom tidyr gather
#' @export
#' @return Nothing (run for side effects).
#' @examples
#' checkTemplateFiles()
checkTemplateFiles <- function(outfile = "", verbose = TRUE) {
  stopifnot(is.character(outfile))

  Column_Name <- Template_Vocab <- Variable_class <- Vocab <- Info_Vocab <- NULL # silence R CMD CHECK note

  vcat <- function(...) if (verbose) cat(...)

  vcat("\nChecking compatibility between ISRaD template and info file...",
    file = outfile, append = TRUE
  )

  # Get the tables stored in the template sheets
  template <- read_template_file()
  template_info <- read_template_info_file()

  # check that column names in the info and template files match
  check_template_info_columns(template, template_info, outfile, verbose)

  vcat("\nChecking controlled vocab between ISRaD template and info file...",
    file = outfile, append = TRUE
  )

  ## Strip out the extra header
  template_vocab <- template$`controlled vocabulary` # pull the control vocab in template
  colnames(template_vocab) <- template_vocab[1, ] # rename the columns
  template_vocab <- template_vocab[c(-1, -2), ]

  ## Crunch the vocab in the template
  template_vocab <- template_vocab %>%
    gather(Column_Name, Template_Vocab, na.rm = TRUE) %>%
    filter(Template_Vocab != "<NA>") %>%
    group_by(Column_Name) %>%
    summarise(Template_Vocab = list(Template_Vocab)) %>%
    ungroup()

  sheetNames <- lapply(template_info, names)
  # Find sheets that have Variable_class defined
  vcd <- sapply(sheetNames, function(x) "Variable_class" %in% x)

  for (tab in names(sheetNames)[vcd]) {
    vcat("\n", tab, "...", file = outfile, append = TRUE)

    template_info_vocab <- template_info[[tab]] %>% # pull the sheet in the info
      filter(
        Variable_class == "character", # filter the variable class
        !is.na(Vocab), # ignore ones with non-sepcific vocabs
        !grepl("name", Column_Name)
      ) %>% # also ignore name columns
      group_by(Column_Name) %>%
      mutate(Info_Vocab = (strsplit(Vocab, split = ", "))) %>%
      left_join(template_vocab, by = "Column_Name") %>%
      mutate(
        InfoInTemplate = list(unlist(Info_Vocab) %in%
          unlist(Template_Vocab)),
        TemplateInInfo = list(unlist(Template_Vocab) %in%
          unlist(Info_Vocab))
      )

    iit <- unlist(template_info_vocab$InfoInTemplate)
    tii <- unlist(template_info_vocab$TemplateInInfo)
    if (!any(tii) || !any(iit)) {
      warning("Mismatch between template info vocab column and template controlled vocab")
      if (!any(iit)) {
        vcat("\n\tWARNING controlled vocab column from template info not found in controlled vocab tab of template:",
          unlist(template_info_vocab$Info_Vocab)[!iit],
          file = outfile, append = TRUE
        )
      }
      if (!any(tii)) {
        vcat("\n\tWARNING controlled vocab tab of template not found in controlled vocab column from template info:",
          unlist(template_info_vocab$Template_Vocab)[!tii],
          file = outfile, append = TRUE
        )
      }
    }

    ## Check that the min/max are strictly numeric or NA-------------------
    template_info_num <- template_info[[tab]] %>% # pull the sheet in the info
      filter(Variable_class == "numeric")
    check_numeric_minmax(template_info_num$Max, "Max")
    check_numeric_minmax(template_info_num$Min, "Min")
  }

  invisible(NULL)
}
