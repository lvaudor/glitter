#' Send SPARQL query to endpoint and get tibble as a result
#' @param .query a string corresponding to a SPARQL query
#' @param endpoint a string or url corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @param user_agent a string indicating the user agent to send with the query.
#' @inheritParams httr2::req_retry
#' @param timeout maximum number of seconds to wait (`httr2::req_timeout()`).
#' @param request_type a string indicating how the query should be sent: in the
#' URL (`url`, default, most common) or as a body form (`body-form`).
#' @param dry_run Boolean indicating whether to return the output of `httr2::req_dry_run()`
#' rather than of `httr2::req_perform`. Useful for debugging.
#' @examples
#'metro_query='SELECT ?item ?itemLabel ?coords
#'{
#'  ?item wdt:P361 wd:Q1552;
#'  wdt:P625 ?coords.
#'  OPTIONAL{?item wdt:P1619 ?date.}
#'  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
#'} ORDER BY ?itemLabel
#''
#'send_sparql(metro_query)
#' @export
send_sparql = function(.query,
                       endpoint = "Wikidata",
                       user_agent = getOption("glitter.ua", "glitter R package (https://github.com/lvaudor/glitter)"),
                       max_tries = getOption("glitter.max_tries", 3L),
                       max_seconds = getOption("glitter.max_seconds", 120L),
                       timeout = getOption("glitter.timeout", 1000L),
                       request_type = c("url", "body-form"),
                       dry_run = FALSE) {

  if (!inherits(user_agent, "character")) {
    cli::cli_abort("{.field user_agent} must be a string.")
  }

  if (!inherits(max_tries, "integer")) {
    cli::cli_abort("{.field max_tries} must be a integer")
  }

  if (!inherits(max_seconds, "integer")) {
    cli::cli_abort("{.field max_seconds} must be a integer")
  }

  if (!inherits(timeout, "integer")) {
    cli::cli_abort("{.field timeout} must be a integer")
  }

  request_type <- rlang::arg_match(request_type, c("url", "body-form"))

  endpoint = tolower(endpoint)

  # if endpoint wikidata, use WikidataQueryServiceR::query_wikidata()
  if(endpoint=="wikidata"){
    return(purrr::quietly(WikidataQueryServiceR::query_wikidata)(.query)$result)
  }
  # else, use httr2

  # if endpoint passed as name, get url
  usual_endpoint_info = usual_endpoints %>%
                    dplyr::filter(.data$name == endpoint)
  url = if (nrow(usual_endpoint_info) > 0) {
    dplyr::pull(usual_endpoint_info, .data$url)
  } else {
    endpoint
  }

  initial_request = httr2::request(url) %>%
    httr2::req_method("POST") %>%
    httr2::req_headers(Accept = "application/sparql-results+json") %>%
    httr2::req_user_agent(user_agent) %>%
    httr2::req_retry(max_tries = max_tries, max_seconds = max_seconds) %>%
    httr2::req_timeout(timeout)

  request <- if (request_type == "url") {
    httr2::req_url_query(initial_request, query = .query)
  } else {
    httr2::req_body_form(initial_request, query = .query)
  }

  if (dry_run) {
    return(httr2::req_dry_run(request, quiet = TRUE))
  }

  resp <- httr2::req_perform(request)

    httr2::resp_check_status(resp)

    if (httr2::resp_content_type(resp) != "application/sparql-results+json") {
      rlang::abort("Not right response type") #TODO:better message, more flexibility
    }

    content = httr2::resp_body_json(resp)

    # Adapted from https://github.com/wikimedia/WikidataQueryServiceR/blob/accff89a06ad4ac4af1bef369f589175c92837b6/R/query.R#L56
    if (length(content$results$bindings) > 0) {
      parse_binding = function(binding, name) {
        type <- sub(
          "http://www.w3.org/2001/XMLSchema#", "",
          binding[["datatype"]] %||% "http://www.w3.org/2001/XMLSchema#character"
        )

        parse = function(x, type) {
          switch(
          type,
          character = x,
          integer = x, # easier for now as dbpedia can return different things with the same name
          datetime = anytime::anytime(x),
            x
        )
        }
        value = parse(binding[["value"]], type)
        tibble::tibble(.rows = 1) %>%
          dplyr::mutate({{name}} := value)
      }

      parse_result = function(result) {
        purrr::map2(result, names(result), parse_binding) %>%
        dplyr::bind_cols()
      }

      data_frame <- purrr::map_df(content$results$bindings, parse_result)

      } else {
        data_frame <- dplyr::as_tibble(
          matrix(
            character(),
            nrow = 0, ncol = length(content$head$vars),
            dimnames = list(c(), unlist(content$head$vars))
          )
        )
      }
      return(data_frame)

}

utils::globalVariables("usual_endpoints")
