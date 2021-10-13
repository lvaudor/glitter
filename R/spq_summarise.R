#' Builds the "select" part of a query.
#' @param query a list with elements of the query
#' @param vars a vector with the names of the variables used for grouping
#' @export
#' @examples
#' add_triplets(s="?item",v="wdt:P361",o="wd:Q297853") %>%
#' add_triplets(s="?item",v="wdt:P1082",o="?folkm_ngd") %>%
#' add_triplets(s="?area",v="wdt:P31",o="wd:Q1907114",label="?area") %>%
#' add_triplets(s="?area",v="wdt:P527",o="?item") %>%
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
