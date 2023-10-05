#' Send SPARQL query to endpoint and get tibble as a result
#' @param query_string a string corresponding to a SPARQL query
#' @inheritParams spq_init
#' @inheritParams spq_perform
#' @noRd

send_sparql = function(query_string,
                       endpoint = NULL,
                       user_agent = lifecycle::deprecated(),
                       max_tries = lifecycle::deprecated(),
                       max_seconds = lifecycle::deprecated(),
                       timeout = lifecycle::deprecated(),
                       request_type = lifecycle::deprecated(),
                       dry_run = FALSE,
                       request_control = NULL) {

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

  initial_request = httr2::request(endpoint) %>%
    httr2::req_method("POST")

  if (request_type == "url") {
    initial_request = initial_request %>%
    httr2::req_headers(
      Accept = "application/sparql-results+json",
      `Content-length` = 0
    )
  } else {
    initial_request = initial_request %>%
      httr2::req_headers(
        Accept = "application/sparql-results+json"
      )
  }

  initial_request = initial_request %>%
    httr2::req_user_agent(user_agent) %>%
    httr2::req_retry(max_tries = max_tries, max_seconds = max_seconds) %>%
    httr2::req_timeout(timeout)

  rate = request_control[["rate"]]
  if (!is.null(rate)) {
    realm = request_control[["realm"]]
    initial_request = httr2::req_throttle(
      initial_request,
      rate = rate,
      realm = realm
    )
  }

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

      parsed_results = purrr::map(
        content[["results"]][["bindings"]],
        parse_result,
        endpoint = endpoint
      )
      data_frame = try(
        dplyr::bind_rows(parsed_results),
        silent = TRUE
      )

      # for instance this can happen with HAL
      binding_failed <- inherits(data_frame, "try-error")

      if (binding_failed) {
        parsed_results <- purrr::map(
          content$results$bindings,
          parse_result,
          simple = TRUE,
          endpoint = endpoint
        )
        data_frame <- dplyr::bind_rows(parsed_results)
      }

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

parse_result = function(result, simple = FALSE, endpoint) {

  purrr::map2(
    result,
    names(result),
    parse_binding,
    simple = simple,
    endpoint = endpoint
  ) %>%
  dplyr::bind_cols()
}

parse_binding = function(binding, name, simple, endpoint) {
  type <- tolower(sub(
    "http://www.w3.org/2001/XMLSchema#", "",
    binding[["datatype"]] %||% "http://www.w3.org/2001/XMLSchema#character"
  ))

  parse = if (!simple) {
    function(x, type, endpoint) {
    switch(
      type,
      character = x,
      # easier for now as dbpedia can return different things with the same name
      integer = ifelse(endpoint == "https://dbpedia.org/sparql", x, as.integer(x)),
      datetime = anytime::anytime(x),
      x
    )
    }
  } else {
    function(x, type, endpoint) {
      as.character(x)
    }
  }
  value = parse(binding[["value"]], type, endpoint = endpoint)
  tibble::tibble(.rows = 1) %>%
    dplyr::mutate({{name}} := value)
}
