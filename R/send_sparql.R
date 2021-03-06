#' Send SPARQL query to endpoint and get tibble as a result
#' @param .query a string corresponding to a SPARQL query
#' @param endpoint a string or url corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @export
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
send_sparql=function(.query,endpoint="Wikidata"){
  endpoint=tolower(endpoint)

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


    resp = httr2::request(url) %>%
    httr2::req_url_query(query = .query) %>%
    httr2::req_method("POST") %>%
    httr2::req_headers(Accept = "application/sparql-results+json") %>%
    httr2::req_user_agent("glitter R package (https://github.com/lvaudor/glitter)") %>%
    httr2::req_retry(max_tries = 3, max_seconds = 120) %>%
    httr2::req_perform()

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
          datetime = anytime::anytime(x)
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
