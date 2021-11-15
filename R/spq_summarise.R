#' Summarise each group of results to fewer results
#' @param query a list with elements of the query
#' @param vars a vector with the names of the variables used for grouping
#' @export
#' @examples
#' result=spq_init() %>%
#' spq_add("?item wdt:P361 wd:Q297853") %>%
#' spq_add("?item wdt:P1082 ?folkm_ngd") %>%
#' spq_add("?area wdt:P31 wd:Q1907114",label="?area") %>%
#' spq_add("?area wdt:P527 ?item") %>%
#' spq_group_by(c("?area","?areaLabel"))  %>%
#' spq_summarise(c("?total_folkm"="sum(?folkm_ngd)"))
#' send()
spq_summarise=function(query,vars){

  # Which variables are summarised ?
  summarised_vars=stringr::str_extract(vars,
                                       "(?<=\\().*(?=\\))")
  # if(is.null(query$group_by)){
  # # If no grouping has been done then consider
  # # grouping variables to be all the other variables
  #   query$group_by=stringr::str_extract_all(query$select,"\\?[^\\s\\)]*") %>%
  #     unlist() %>% unique() %>%
  #     subset(!(. %in% summarised_vars))
  # }

  summaries=glue::glue("({vars} AS {names(vars)})") %>%
    paste(collapse=" ")

  query$select=c(query$select,summaries)
  return(query)
}
