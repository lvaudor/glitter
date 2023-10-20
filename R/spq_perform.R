#' Assemble query parts into a sparql query and send it to endpoint
#' to get a tibble as a result.
#' @param .query a list with elements of the query
#' @param endpoint `r lifecycle::badge('deprecated')` a string or url
#' corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @param replace_prefixes Boolean indicating whether to replace used
#' prefixes in the results table,
#' for instance making, for instance "http://www.wikidata.org/entity/" "wd:".
#' @param endpoint a string or url corresponding to a SPARQL endpoint.
#' Defaults to "Wikidata"
#' @param user_agent `r lifecycle::badge('deprecated')` a string indicating
#' the user agent to send with the query.
#' @param max_tries,max_seconds `r lifecycle::badge('deprecated')`
#' Cap the maximal number of
#' attemps with `max_tries` or the total elapsed time from the first request
#' with `max_seconds`.
#' @param timeout `r lifecycle::badge('deprecated')` maximum number of seconds
#' to wait (`httr2::req_timeout()`).
#' @param request_type `r lifecycle::badge('deprecated')` a string indicating
#' how the query should be sent: in the
#' URL (`url`, default, most common) or as a body form (`body-form`).
#' @param dry_run Boolean indicating whether to return the output of
#' `httr2::req_dry_run()`
#' rather than of `httr2::req_perform()`. Useful for debugging.
#' @return A query object
#' @export
#' @examples
#' \dontrun{
#' spq_init() %>%
#'   spq_add(.subject="?city",.verb="wdt:P31",.object="wd:Q515") %>%
#'   spq_add(.subject="?city",.verb="wdt:P1082",.object="?pop") %>%
#'   spq_label(city) %>%
#'   spq_head(n=5) %>%
#'   spq_perform()
#' }
#'
#' @section Request control:
#'
#' Control the way the query is performed via the `control_request`
#' argument of `spq_init()`.
#' This way you can create a basic spq object with all the correct options
#' corresponding to the SPARQL service you are using, and then use it as
#' the basis of all your subsequent glitter pipelines.
#'
#'
spq_perform = function(.query,
                       endpoint = lifecycle::deprecated(),
                       user_agent = lifecycle::deprecated(),
                       max_tries = lifecycle::deprecated(),
                       max_seconds = lifecycle::deprecated(),
                       timeout = lifecycle::deprecated(),
                       request_type = lifecycle::deprecated(),
                       dry_run = FALSE,
                       replace_prefixes = FALSE) {

  if (lifecycle::is_present(endpoint)) {
     lifecycle::deprecate_warn(
       "0.3.0",
       "spq_perform(endpoint)",
       "spq_init(endpoint)"
    )
  } else {
    endpoint = .query[["endpoint_info"]][["endpoint_url"]]
  }


  sparql_query = spq_assemble(.query = .query)

  results = send_sparql(
    sparql_query,
    endpoint = endpoint,
    user_agent = user_agent,
    max_tries = max_tries,
    max_seconds = max_seconds,
    timeout = timeout,
    request_type = request_type,
    dry_run = dry_run,
    request_control = .query[["request_control"]]
  )

  if (replace_prefixes) {
    endpoint_url=.query[["endpoint_info"]]$endpoint_url
    if(endpoint_url %in% usual_endpoints$url){
      endpoint_name=usual_endpoints$name[which(usual_endpoints$url==endpoint_url)]
      prefixes=usual_prefixes$name[which(usual_prefixes$type==endpoint_name)]
    }else{prefixes=c()}
    prefixes=c(prefixes,.query[["prefixes_used"]])
    results = purrr::reduce(
      prefixes,
      \(results, x) replace_prefix(x, results, .query = .query),
      .init = results
    )
  }

  results

}

replace_prefix = function(prefix, results, .query) {
   prefixes = rbind(
     usual_prefixes[, c("name", "url")],
     .query[["prefixes_provided"]]
    )

   dplyr::mutate(
     results,
     dplyr::across(
       dplyr::where(is.character),
       \(x) str_replace(
         x,
         pattern = prefixes[["url"]][prefixes[["name"]] == prefix],
         replacement = sprintf("%s:", prefix))
     )
   )
}

control_explanation <- function() {
  "Parameters controlling how the request is made have to be
       passed to `spq_init()`'s `request_control` argument."
}
