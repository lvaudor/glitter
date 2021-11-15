#' Initialize a query object.
#' @export
spq_init=function(){
    query=list(prefixes=tibble(name=NULL,url=NULL),
               prefixed=NULL,
               previous_subject=NULL,
               select=NULL,
               body="",
               service="",
               filter="",
               limit="",
               group_by=NULL,
               order_by="")
    return(query)
}
