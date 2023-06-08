#' Initialize a query object.
#' @return A query object
#' @export
spq_init=function(){
  query=list(
    prefixes_provided = tibble::tibble(name=NULL,url=NULL),
    prefixes_used = NULL,
    previous_subject = NULL,
    select = NULL,
    spq_duplicate = NULL,
    body = "",
    service = NULL,
    filter = NULL,
    limit = NULL,
    group_by = NULL,
    order_by = NULL,
    offset = NULL
  )

  structure(query, class = c("sparqle_query", "list"))
}

#' @export
print.sparqle_query <- function(x, ...) spq_assemble(x) %>% cat()

