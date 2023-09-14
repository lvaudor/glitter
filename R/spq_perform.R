#' Assemble query parts into a sparql query and send it to endpoint to get a tibble as a result.
#' @param .query a list with elements of the query
#' @param endpoint a string or url corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @param replace_prefixes Boolean indicating whether to replace used prefixes in the results table,
#' for instance making, for instance "http://www.wikidata.org/entity/" "wd:".
#' @inheritParams send_sparql
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
spq_perform = function(.query,
                       endpoint = lifecycle::deprecated(),
                       user_agent = lifecycle::deprecated(),
                       max_tries = lifecycle::deprecated(),
                       max_seconds = lifecycle::deprecated(),
                       timeout = lifecycle::deprecated(),
                       request_type = lifecycle::deprecated(),
                       dry_run = FALSE,
                       replace_prefixes = FALSE){


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
    results = purrr::reduce(
      .query[["prefixes_used"]],
      \(results, x) replace_prefix(x, results, .query = .query),
      .init = results
    )
  }

  results

}

replace_prefix = function(prefix, results, .query) {
   prefixes = rbind(usual_prefixes[, c("name", "url")], .query[["prefixes_provided"]])
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
