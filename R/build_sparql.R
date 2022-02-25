#' Assemble query parts into a proper SPARQL query
#' @param query a list with elements of the query
#' @param endpoint SPARQL endpoint to send the query to
#' @export
#' @examples
#' spq_init() %>%
#' spq_add("?city wdt:P31 wd:Q515", label="?city") %>%
#' spq_add("?city wdt:P1082 ?pop") %>%
#' spq_language("fr") %>%
#' spq_head(n=5) %>%
#' spq_assemble() %>%
#' cat()
spq_assemble=function(query, endpoint = "Wikidata"){
  if (endpoint != "Wikidata"){
    query$service = ""
  }

  query = query %>%
    spq_prefix(auto=TRUE, prefixes=NULL)

  # are prefixes correct and do they correspond to provided prefixes?
  prefixes_known = dplyr::bind_rows(query$prefixes_provided,usual_prefixes)
  purrr::map_lgl(query$prefixes_used,
                 is_prefix_known,
                 prefixes_known= prefixes_known,
                 endpoint=endpoint)
  # prefixes
  if(nrow(query$prefixes_provided)>0){
    part_prefixes=glue::glue("PREFIX {query$prefixes_provided$name}: <{query$prefixes_provided$url}>") %>%
      paste0(collapse="\n")
  }else{part_prefixes=""}

  if(!is.null(query$group_by)){
    query$group_by=paste0("GROUP BY ", paste0(query$group_by, collapse=" "),"\n")
  }

  if(is.null(query$service)){
    query=spq_language(query,language="en")
  }

  query$order_by = if (length(query$order_by) > 0) {
    sprintf("ORDER BY %s", paste(query$order_by, collapse = " "))
  }
  else {
    ""
  }

  query$select <- if (length(query$select) == 0) {
    "*"
  } else {
    query$select
  }

  paste0(part_prefixes,"\n",
    "SELECT ", paste0(query$select,collapse=" "),"\n",
    "WHERE{\n",
    query$body,"\n",
    query$filter,"\n",
    query$service,"\n",
    "}\n",
    query$group_by,
    query$order_by,"\n",
    glue::glue("LIMIT {query$limit}"),"\n",
    glue::glue("OFFSET {query$offset}")
  )
}

utils::globalVariables("usual_prefixes")
