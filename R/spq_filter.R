#' Filters results by adding conditions
#' @inheritParams spq_arrange
#' @inheritParams spq_add
#' @return A query object
#' @export
#' @section Some examples:
#'
#' ```r
#' spq_init() %>%
#' spq_filter(item == wdt::P31(wd::Q13442814))
#'
#' # Lexemes in English that match an expression
#' # here starting with "pota"
#' query <- spq_init() |>
#'   spq_prefix(prefixes = c(dct = "http://purl.org/dc/terms/")) |>
#'   spq_add(spq('?lexemeId dct:language wd:Q1860')) |>
#'   spq_mutate(lemma = wikibase::lemma(lexemeId)) |>
#'   spq_filter(str_detect(lemma, '^pota.*')) |>
#'   spq_select(lexemeId, lemma)
#' ```
spq_filter = function(.query = NULL,
                      ...,
                      .label = NA,
                      .within_box = c(NA, NA),
                      .within_distance = c(NA, NA)) {
  filters = purrr::map(rlang::enquos(...), spq_treat_filter_argument)

  # FILTER filters :-)
  normal_filters = filters[purrr::map_lgl(filters, is.character)]
  if (length(normal_filters) > 0) {
    # TODO add error if variables not in the df of variables

    .query = purrr::reduce(normal_filters, track_filters, .init = .query)
  }

  # triple pattern "filters"
  triple_filters = purrr::keep(filters, is.list)
  if (length(triple_filters) > 0) {
    .query = purrr::reduce(
      triple_filters,
      function(.query, x) {
        spq_add(
          .query,
          .subject = x[["subject"]],
          .verb = x[["verb"]],
          .object = x[["object"]]
        )
      },
      .init = .query
    )
  }

  # labelling ----
  if (!is.na(.label)) {
    lifecycle::deprecate_warn(
      when = "0.2.0",
      what = "spq_add(.label)",
      details = "Ability to use `.label` will be dropped in next release, use `spq_label()` instead."
    )
    .label <- gsub("^\\?", "", .label)
    .query <- spq_label(.query, !!!.label)
  }

  .query
}

spq_treat_filter_argument = function(arg) {
  eval_try = try(rlang::eval_tidy(arg), silent = TRUE)

  if (is.spq(eval_try)) {
    return(eval_try)
  }

  code = if (!inherits(eval_try, "try-error") && is.character(eval_try)) {
    # e.g. `"desc(length)"`
    eval_try
  } else {
    # e.g. `desc(length)`, without quotes
    rlang::expr_text(arg) %>% str_remove("^~")
  }

  if (!grepl("::", code, fixed = TRUE)) {
    spq_translate_dsl(code)
  } else {
    spq_translate_filter(code)
  }
}

spq_translate_filter = function(code) {
  code_data = parse_code(code)
  eq = xml2::xml_find_all(code_data, ".//EQ")
  if (length(eq) == 0) {
    rlang::abort("Can't use a triple-pattern-like filter without ==")
  }
  right_side = code_data %>%
    xml2::xml_find_all(".//EQ/following-sibling::expr[1]") %>%
    xml2::xml_text()

  subject = code_data %>%
    xml2::xml_find_first(".//SYMBOL") %>%
    xml2::xml_text()

  c(
    subject = sprintf("?%s", subject),
    spq_parse_verb_object(right_side)
  )
}
