#' Initialize a query object.
#' @export
spq_init=function(){
    query=list(prefixes_provided=tibble(name=NULL,url=NULL),
               prefixes_used=NULL,
               previous_subject=NULL,
               select=NULL,
               body="",
               service=NULL,
               filter=NULL,
               limit=NULL,
               group_by=NULL,
               order_by=NULL)
    return(query)
}

# filter ------------------------------------------------------------------

