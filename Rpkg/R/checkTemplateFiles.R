#' Check ISRaD Template/Info files
#'
#' @description Check that the template information file and the template file match appropriately.
#' @details Used in compile() function, but primarily a development tool
#' @param outfile file to dump the output report. Defaults to an empty string that will print
#' to standard output.
#' @importFrom openxlsx read.xlsx getSheetNames
#' @importFrom dplyr group_by filter summarise left_join mutate
#' @importFrom utils type.convert
#' @importFrom stats setNames
#' @export
#' @return Nothing (run for side effects).
#' @examples
#' checkTemplateFiles()
checkTemplateFiles <- function(outfile = "") {
  stopifnot(is.character(outfile))
  
  Column_Name <- Template_Vocab <- Variable_class <- Vocab <- Info_Vocab <- NULL # silence R CMD CHECK note
  
  cat("\nChecking compatibility between ISRaD template and info file...",
      file = outfile, append = TRUE
  )
  
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
  check_template_info_columns(template, template_info, outfile)  

  cat("\nChecking controlled vocab between ISRaD template and info file...",
      file = outfile, append = TRUE
  )
  
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
    cat("\n", tab, "...", file = outfile, append = TRUE)
    
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
        cat("\n\tWARNING controlled vocab column from template info not found in controlled vocab tab of template:",
            unlist(template_info_vocab$Info_Vocab)[!iit],
            file = outfile, append = TRUE
        )
      }
      if (!any(tii)) {
        cat("\n\tWARNING controlled vocab tab of template not found in controlled vocab column from template info:",
            unlist(template_info_vocab$Template_Vocab)[!tii],
            file = outfile, append = TRUE
        )
      }
    }
    
    ## Check that the min/max are strictly numeric or NA-------------------
    template_info_num <- template_info[[tab]] %>% # pull the sheet in the info
      filter(Variable_class == "numeric")
    
    if (!is.numeric(type.convert(template_info_num$Max))) {
      warning("Non-numeric values in Max column")
    }
    if (!is.numeric(type.convert(template_info_num$Min))) {
      warning("Non-numeric values in Min column")
    }
  }
  
  invisible(NULL)
}
