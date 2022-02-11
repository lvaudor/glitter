#' Send SPARQL query to endpoint and get tibble as a result
#' @param query a string corresponding to a SPARQL query
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
#'send_sparql(query=metro_query)
send_sparql=function(query,endpoint="Wikidata"){
  endpoint=tolower(endpoint)

  # if endpoint wikidata, use WikidataQueryServiceR::query_wikidata()
  if(endpoint=="wikidata"){
    return(purrr::quietly(WikidataQueryServiceR::query_wikidata)(query)$result)
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
    httr2::req_url_query(query = query) %>%
    httr2::req_method("POST") %>%
    httr2::req_user_agent("glitter R package (https://github.com/lvaudor/glitter)") %>%
    httr2::req_retry(max_tries = 3, max_seconds = 120) %>%
    httr2::req_perform()

    httr2::resp_check_status(resp)

    content = httr2::resp_body_xml(resp)
    xml2::xml_ns_strip(content)

    # results < result < binding

    parse_result = function(result) {
      xml2::xml_children(result) %>%
        purrr::map(parse_binding) %>%
        dplyr::bind_cols()
    }

    parse_binding = function(binding) {
      name = xml2::xml_attr(binding, 'name')
      value = xml2::xml_text(binding)
      tibble::tibble(.rows = 1) %>%
        dplyr::mutate({{name}} := value)
    }

    content %>%
      xml2::xml_find_first(".//results") %>%
      xml2::xml_children() %>%
      purrr::map_df(parse_result)

}

utils::globalVariables("usual_endpoints")
