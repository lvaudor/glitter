#' Send SPARQL query to endpoint and get tibble as a result
#' @param query_string a string corresponding to a SPARQL query
#' @param endpoint `r lifecycle::badge('deprecated')` a string or url corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @param user_agent `r lifecycle::badge('deprecated')` a string indicating the user agent to send with the query.
#' @param max_tries,max_seconds `r lifecycle::badge('deprecated')` Cap the maximal number of
#' attemps with `max_tries` or the total elapsed time from the first request with `max_seconds`.
#' @param timeout `r lifecycle::badge('deprecated')` maximum number of seconds to wait (`httr2::req_timeout()`).
#' @param request_type `r lifecycle::badge('deprecated')` a string indicating how the query should be sent: in the
#' URL (`url`, default, most common) or as a body form (`body-form`).
#' @param dry_run Boolean indicating whether to return the output of `httr2::req_dry_run()`
#' rather than of `httr2::req_perform()`. Useful for debugging.
#' @inheritParams spq_init
#' @examples
#' \dontrun{
#' query_string = spq_init() %>%
#'   spq_add("?city wdt:P31/wdt:P279* wd:Q486972") %>%
#'   spq_label(city) %>%
#'   spq_mutate(coords = wdt::P625(city),
#'           .within_distance=list(center=c(long=4.84,lat=45.76),
#'                                radius=5)) %>%
#'  spq_assemble()
#'  send_sparql(query_string)
#'  }
#' @details
#'
#' Control the way the query is performed via the `control_request`
#' argument of `spq_init()`.
#' This way you can create a basic spq object with all the correct options
#' corresponding to the SPARQL service you are using, and then use it as
#' the basis of all your subsequent glitter pipelines.
#'
#'
#' @export
send_sparql = function(query_string,
                       endpoint = lifecycle::deprecated(),
                       user_agent = lifecycle::deprecated(),
                       max_tries = lifecycle::deprecated(),
                       max_seconds = lifecycle::deprecated(),
                       timeout = lifecycle::deprecated(),
                       request_type = lifecycle::deprecated(),
                       dry_run = FALSE,
                       request_control = NULL) {

  if (lifecycle::is_present(endpoint)) {
     lifecycle::deprecate_warn(
       "0.3.0",
       "spq_perform(endpoint)",
       "spq_request_control(endpoint)",
       details = control_explanation()
    )
  } else {
  endpoint = request_control[["endpoint"]]
  }

  if (lifecycle::is_present(user_agent)) {
     lifecycle::deprecate_warn(
       "0.3.0",
       "spq_perform(user_agent)",
       "spq_request_control(user_agent)",
       details = control_explanation()
    )
  } else {
    user_agent = request_control[["user_agent"]]
  }

  if (lifecycle::is_present(max_tries)) {
     lifecycle::deprecate_warn(
       "0.3.0",
       "spq_perform(max_tries)",
       "spq_request_control(max_tries)",
       details = control_explanation()
    )
  } else {
    max_tries = request_control[["max_tries"]]
  }

  if (lifecycle::is_present(max_seconds)) {
     lifecycle::deprecate_warn(
       "0.3.0",
       "spq_perform(max_seconds)",
       "spq_request_control(max_seconds)",
       details = control_explanation()
    )
  } else {
    max_seconds = request_control[["max_seconds"]]
  }

  if (lifecycle::is_present(timeout)) {
     lifecycle::deprecate_warn(
       "0.3.0",
       "spq_perform(timeout)",
       "spq_request_control(timeout)",
       details = control_explanation()
    )
  } else {
    timeout = request_control[["timeout"]]
  }

  if (lifecycle::is_present(request_type)) {
     lifecycle::deprecate_warn(
       "0.3.0",
       "spq_perform(request_type)",
       "spq_request_control(request_type)",
       details = control_explanation()
    )
  } else {
    request_type = request_control[["request_type"]]
  }

  # if endpoint wikidata, use WikidataQueryServiceR::query_wikidata()
  if (endpoint == "https://query.wikidata.org/") {
    return(purrr::quietly(WikidataQueryServiceR::query_wikidata)(query_string)$result)
  }
  # else, use httr2

  initial_request = httr2::request(endpoint) %>%
    httr2::req_method("POST") %>%
    httr2::req_headers(Accept = "application/sparql-results+json") %>%
    httr2::req_user_agent(user_agent) %>%
    httr2::req_retry(max_tries = max_tries, max_seconds = max_seconds) %>%
    httr2::req_timeout(timeout)

  request = if (request_type == "url") {
    httr2::req_url_query(initial_request, query = query_string)
  } else {
    httr2::req_body_form(initial_request, query = query_string)
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
            # easier for now as dbpedia can return different things with the same name
          integer = ifelse(endpoint == "https://dbpedia.org/sparql", x, as.integer(x)),
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
