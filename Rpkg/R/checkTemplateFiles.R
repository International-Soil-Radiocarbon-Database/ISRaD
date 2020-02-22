#' Check ISRaD Template/Info files
#'
#' @description Check that the template information file and the template file match appropriately.
#' @details Used in compile() function, but primarily a development tool
#' @param outfile file to dump the output report. Defaults to an empty string that will print
#' to standard output.
#' @param verbose if TRUE (default) will print output to specified outfile
#' @importFrom openxlsx read.xlsx getSheetNames
#' @importFrom dplyr group_by filter summarise left_join mutate
#' @importFrom utils type.convert
#' @importFrom stats setNames
#' @export
#' @return Nothing (run for side effects).
#' @examples
#' checkTemplateFiles()
checkTemplateFiles <- function(outfile = "", verbose = TRUE) {
  stopifnot(is.character(outfile))
  stopifnot(is.logical(verbose))
  
  Column_Name <- Template_Vocab <- Variable_class <- Vocab <- Info_Vocab <- NULL # silence R CMD CHECK note
  
  if (verbose) {
    cat("\nChecking compatibility between ISRaD template and info file...",
      file = outfile, append = TRUE
    )
  }

  # Get the tables stored in the template sheets
  template_file <- system.file("extdata", "ISRaD_Master_Template.xlsx",
    package = "ISRaD"
  )
  template <- lapply(
    setNames(nm = getSheetNames(template_file)),
    function(s) {
      read.xlsx(template_file,
        sheet = s
      )
    }
  )

  template_info_file <- system.file("extdata", "ISRaD_Template_Info.xlsx",
    package = "ISRaD"
  )
  template_info <- lapply(
    setNames(nm = getSheetNames(template_info_file)),
    function(s) {
      read.xlsx(template_info_file, sheet = s)
    }
  )

  # check that column names in the info and template files match
  for (tab in names(template)[1:8]) {
    if (verbose) cat("\n", tab, "...", file = outfile, append = TRUE)
    tab_cols <- colnames(template[[tab]])
    ti_colnames <- template_info[[tab]]$Column_Name
    if (any(!(ti_colnames %in% tab_cols))) {
      if (verbose) {
        cat("\n\tWARNING column names unique to info file:",
          setdiff(ti_colnames, tab_cols), file = outfile, append = TRUE
        )
      }
    }
    if (any(!(tab_cols %in% ti_colnames))) {
      if (verbose) {
        cat("\n\tWARNING column names unique to template file:",
          setdiff(tab_cols, ti_colnames), file = outfile, append = TRUE
        )
      }
    }
  }

  if (verbose) {
    cat("\nChecking controlled vocab between ISRaD template and info file...",
      file = outfile, append = TRUE
    )
  }

  ## Strip out the extra header
  template_vocab <- template$`controlled vocabulary` # pull the control vocab in template
  colnames(template_vocab) <- template_vocab[1, ] # rename the columns
  template_vocab <- template_vocab[c(-1, -2), ]

  ## Crunch the vocab in the template
  template_vocab <- template_vocab %>%
    tidyr::gather(Column_Name, Template_Vocab, na.rm = TRUE) %>%
    filter(Template_Vocab != "<NA>") %>%
    group_by(Column_Name) %>%
    summarise(Template_Vocab = list(Template_Vocab)) %>% 
    ungroup()

  sheetNames <- lapply(template_info, names)
  # for each sheet that has a Variable_class defined
  for (tab in names(sheetNames)[unlist(lapply(
    sheetNames,
    function(x) {
      any("Variable_class" %in% x)
    }
  ))]) {
    if (verbose) cat("\n", tab, "...", file = outfile, append = TRUE)

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

    if (!any(unlist(template_info_vocab$InfoInTemplate))) {
      if (verbose) {
        cat("\n\tWARNING controlled vocab column from template info not found in controlled vocab tab of template:",
          unlist(template_info_vocab$Info_Vocab)[!unlist(template_info_vocab$InfoInTemplate)],
          file = outfile, append = TRUE
        )
      }
    }

    if (!any(unlist(template_info_vocab$TemplateInInfo))) {
      if (verbose) {
        cat("\n\tWARNING controlled vocab tab of template not found in controlled vocab column from template info:",
          unlist(template_info_vocab$Template_Vocab)[!unlist(template_info_vocab$TemplateInInfo)],
          file = outfile, append = TRUE
        )
      }
    }

    ## Check that the min/max are strictly numeric or NA-------------------
    template_info_num <- template_info[[tab]] %>% # pull the sheet in the info
      filter(Variable_class == "numeric")

    if (!is.numeric(type.convert(template_info_num$Max))) {
      if (verbose) {
        cat("\n\tWARNING non-numeric values in Max column",
          file = outfile, append = TRUE
        )
      }
    }

    if (!is.numeric(type.convert(template_info_num$Min))) {
      if (verbose) {
        cat("\n\tWARNING non-numeric values in Min column",
          file = outfile, append = TRUE
        )
      }
    }
  }

  return(NULL)
}
