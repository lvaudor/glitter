

#' Assemble query parts into a query.
#' @param query_parts a list with elements of the query
#' @export
#' @examples
#' add_triplets(subject="?city",verb="wdt:P31",object="wd:Q515", limit=10) %>%
#' add_triplets(subject="?city",verb="wdt:P1082",object="?pop", label="?city", language="en") %>%
#' build_sparql() %>%
#' send_sparql()
build_sparql=function(query_parts){
  query=paste0("SELECT ", paste0(query_parts$select,collapse=" "),"\n",
               "WHERE{\n",
               query_parts$body,"\n",
               query_parts$filter,"\n",
               query_parts$service,"\n",
               "}\n",
               query_parts$limit)
  return(query)
}

#' Compose query parts for triplets with subject verb object.
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "Q456"))
#' @param optional whether the triplet is optional (other results are sent back even if this particular triplet is missing)
#' @param label a vector of variables for which to include a label column (defaults to NA)
#' @param limit the max number of items sent back
#' @param filter the filters to apply
#' @param within_box if provided, rectangular bounding box for the triplet query.
#' Provided as list(southwest=c(long=...,lat=...),northeast=c(long=...,lat=...))
#' @param within_distance if provided, circular bounding box for the triplet query.
#' Provided as list(center=c(long=...,lat=...), radius=...), with radius in kilometers.
#' The center can also be provided as a variable (for instance, "?location") for the center coordinates to be retrieved directly from the query.
#' @param language the language in which the labels will be provided (defaults to "en" for English)
#' @export
#' @examples
#' add_triplets(subject="?city",
#' verb="wdt:P31/wdt:P279*",
#' object="wd:Q515",
#'  label=c("?city"),
#'   limit=10) %>%
#' add_triplets(subject="?city",
#' verb="wdt:P1082",object="?pop",
#' optional=TRUE) %>%
#' add_triplets(subject="?city",
#' verb="wdt:P625",object="?coords",
#' within_box=list(southwest=c(3,43),
#' northeast=c(7,47))) %>%
#' build_sparql() %>%
#' send_sparql()
add_triplets=function(query=NA,subject,verb,object,
                      optional=FALSE, label=NA,
                      filter=NA,
                      limit=NA,
                      within_box=c(NA,NA),
                      within_distance=c(NA,NA),
                      language="en"){
  query_parts=list(select=build_part_select(query,subject,verb,object,label),
                   body=build_part_body(query,subject,verb,object,optional,
                                        within_box=within_box, within_distance=within_distance),
                   service=build_part_service(query, language),
                   filter=build_part_filter(query, filter),
                   limit=build_part_limit(query,limit))
  return(query_parts)
}
