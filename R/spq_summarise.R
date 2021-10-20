#' Summarise each group of results to fewer results
#' @param query a list with elements of the query
#' @param vars a vector with the names of the variables used for grouping
#' @export
#' @examples
#' result=spq_init() %>%
#' add_triplets("?item wdt:P361 wd:Q297853") %>%
#' add_triplets("?item wdt:P1082 ?folkm_ngd") %>%
#' add_triplets("?area wdt:P31 wd:Q1907114",label="?area") %>%
#' add_triplets("?area wdt:P527 ?item") %>%
#' spq_group_by(c("?area","?areaLabel")) %>%
#' spq_summarise(c("?total_folkm"="sum(?folkm_ngd)")) %>%
#' send()
spq_summarise=function(query,vars){
  group_vars=stringr::str_extract_all(query$select,"\\?[^\\s]*") %>%
    unlist() %>%  paste(collapse=" ")
  summaries=glue::glue("({vars} AS {names(vars)})") %>%
    paste(collapse=" ")
  query$select=glue::glue("{query$select} {summaries}")
  query$group_by=glue::glue("GROUP BY {group_vars}")
  return(query)
}
