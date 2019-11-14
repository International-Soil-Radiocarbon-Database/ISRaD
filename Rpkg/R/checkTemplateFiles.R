#' Check ISRaD Template/Info files
#'
#' @description Check that the template information file and the template file match appropriately.
#' @details Used in compile() function, but primarily a development tool
#' @param outfile file to dump the output report. Defaults to an empty string that will print
#' to standard output.
#' @param verbose if TRUE (default) will print output to specified outfile
#' @export
#' @return returns NULL
#' @examples
#' checkTemplateFiles()

checkTemplateFiles <- function(outfile='', verbose=T) {

  if(verbose) cat("\nChecking compatibility between ISRaD template and info file...",
                  file=outfile, append = TRUE)

  # Get the tables stored in the template sheets
  template_file <- system.file("extdata", "ISRaD_Master_Template.xlsx",
                               package = "ISRaD")
  template <- lapply(stats::setNames(nm=openxlsx::getSheetNames(template_file)),
                     function(s){openxlsx::read.xlsx(template_file,
                                                     sheet=s)})

  template_info_file <- system.file("extdata", "ISRaD_Template_Info.xlsx",
                                    package = "ISRaD")
  template_info <- lapply(stats::setNames(nm=openxlsx::getSheetNames(template_info_file)),
                          function(s){
                            openxlsx::read.xlsx(template_info_file , sheet=s)
                          })

  # check that column names in the info and template files match
  for (tab in names(template)[1:8]){
    if(verbose) cat("\n",tab,"...", file=outfile, append = TRUE)
    if(any(! (template_info[[tab]]$Column_Name %in% colnames(template[[tab]])))) {
    if(verbose) cat("\n\tWARNING column names unique to info file:",
                    setdiff(template_info[[tab]]$Column_Name, colnames(template[[tab]])),
                    file=outfile, append = TRUE)
    }
    if(any(! (colnames(template[[tab]]) %in% template_info[[tab]]$Column_Name))) {
      if(verbose) cat("\n\tWARNING column names unique to template file:",
                      setdiff(colnames(template[[tab]]),template_info[[tab]]$Column_Name),
                      file=outfile, append = TRUE)
    }
  }

  if(verbose) cat("\nChecking controlled vocab between ISRaD template and info file...",
                  file=outfile, append = T)

  ##Strip out the extra header
  template_vocab <- template$`controlled vocabulary`#pull the control vocab in template
  colnames(template_vocab)<-template_vocab[1,] #rename the columns
  template_vocab<-template_vocab[c(-1,-2),]

  ##Crunch the vocab in the template
  template_vocab <- template_vocab %>%
    tidyr::gather(key='Column_Name', value='Template_Vocab', na.rm=TRUE) %>%
    dplyr::filter(.data$Template_Vocab != '<NA>') %>%
    dplyr::group_by(.data$Column_Name) %>%
    dplyr::summarize(Template_Vocab = list(.data$Template_Vocab))

  sheetNames <- lapply(template_info, names)
  #for each sheet that has a Variable_class defined
  for (tab in names(sheetNames)[unlist(lapply(sheetNames,
                                              function(x){ any('Variable_class' %in% x)}))]){
    if(verbose) cat("\n",tab,"...", file=outfile, append = TRUE)

    template_info_vocab <- template_info[[tab]] %>% #pull the sheet in the info
      dplyr::filter(.data$Variable_class == 'character', #filter the variable class
                    !is.na(.data$Vocab), #ignore ones with non-sepcific vocabs
                    ! grepl("name", .data$Column_Name)) %>% #also ignore name columns
      group_by(.data$Column_Name) %>%
      mutate(Info_Vocab=(strsplit(.data$Vocab, split=', '))) %>%
      dplyr::left_join(template_vocab, by="Column_Name") %>%
      dplyr::mutate(InfoInTemplate = list(unlist(.data$Info_Vocab) %in%
                                            unlist(.data$Template_Vocab)),
                    TemplateInInfo = list(unlist(.data$Template_Vocab) %in%
                                            unlist(.data$Info_Vocab)))

    if(!any(unlist(template_info_vocab$InfoInTemplate))){
      if(verbose) cat("\n\tWARNING controlled vocab column from template info not found in controlled vocab tab of template:",
                      unlist(template_info_vocab$Info_Vocab)[!unlist(template_info_vocab$InfoInTemplate)],
                      file=outfile, append = TRUE)
    }

    if(!any(unlist(template_info_vocab$TemplateInInfo))){
      if(verbose) cat("\n\tWARNING controlled vocab tab of template not found in controlled vocab column from template info:",
                      unlist(template_info_vocab$Template_Vocab)[!unlist(template_info_vocab$TemplateInInfo)],
                      file=outfile, append = TRUE)
    }

    ##Check that the min/max are strictly numeric or NA-------------------
    template_info_num <- template_info[[tab]] %>% #pull the sheet in the info
      dplyr::filter(.data$Variable_class == 'numeric')

    if(! is.numeric(utils::type.convert(template_info_num$Max))){
      if(verbose) cat("\n\tWARNING non-numeric values in Max column",
                      file=outfile, append = TRUE)
    }

    if(! is.numeric(utils::type.convert(template_info_num$Min))){
      if(verbose) cat("\n\tWARNING non-numeric values in Min column",
                      file=outfile, append = TRUE)
    }
  }

  return(NULL)
}
