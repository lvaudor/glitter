#' Summarise each group of results to fewer results
#' @inheritParams spq_arrange
#' @export
#' @examples
#' result=spq_init() %>%
#' spq_add("?item wdt:P361 wd:Q297853") %>%
#' spq_add("?item wdt:P1082 ?folkm_ngd") %>%
#' spq_add("?area wdt:P31 wd:Q1907114",label="?area") %>%
#' spq_add("?area wdt:P527 ?item") %>%
#' spq_group_by(c("?area","?areaLabel"))  %>%
#' spq_summarise(total_folkm = sum(folkm_ngd))
spq_summarise = function(query, ...){

  variables = purrr::map_chr(rlang::enquos(...), treat_select_argument)

  variables[nzchar(names(variables))] = purrr::map2_chr(
    variables[nzchar(names(variables))],
    names(variables)[nzchar(names(variables))],
    add_as
  )

  names(variables[!nzchar(names(variables))]) <- variables[!nzchar(names(variables))]

  # If no grouping has been done
  if (is.null(query$group_by)) {
    # then GROUP BY summary variables
    query$group_by = names(variables)
    # and remove all other selected variables
    query$select = NULL
  }

  query$select = c(query$select, variables)
  return(query)
}

#' @export
#' @rdname spq_summarise
spq_summarize <- spq_summarise
