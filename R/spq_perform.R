#' Assemble query parts into a sparql query and send it to endpoint to get a tibble as a result.
#' @param .query a list with elements of the query
#' @param endpoint a string or url corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @inheritParams send_sparql
#' @return A query object
#' @export
#' @examples
#' query=spq_init() %>%
#' spq_add(.subject="?city",.verb="wdt:P31",.object="wd:Q515") %>%
#' spq_add(.subject="?city",.verb="wdt:P1082",.object="?pop", .label="?city") %>%
#' spq_head(n=5) %>%
#'
#' spq_perform()
spq_perform = function(.query,
                       endpoint = "Wikidata",
                       user_agent = getOption("glitter.ua", "glitter R package (https://github.com/lvaudor/glitter)"),
                       max_tries = getOption("glitter.max_tries", 3L),
                       max_seconds = getOption("glitter.max_seconds", 120L),
                       timeout = getOption("glitter.timeout", 1000L),
                       request_type = c("url", "body-form"),
                       dry_run = FALSE){
  sparql_query = spq_assemble(.query = .query, endpoint = endpoint)

  send_sparql(
    sparql_query,
    endpoint = endpoint,
    user_agent = user_agent,
    max_tries = max_tries,
    max_seconds = max_seconds,
    timeout = timeout,
    request_type = request_type,
    dry_run = FALSE
  )

}
