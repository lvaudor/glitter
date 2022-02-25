assert_whether_character = function(eval_try) {
  if (!inherits(eval_try, "try-error") && is.character(eval_try)) {
    rlang::abort(
      message = c(
        x = sprintf('Cannot use "%s"', eval_try),
        i = "Did you mean to pass a string? Use spq() to wrap it."
      )
    )
  }
}

add_question_mark = function(x) sprintf("?%s", x)

# add name for AS bla
add_as = function(string, name) {
  sprintf("(%s AS %s)", string, add_question_mark(name))
}

# If running into issues look into the safe parsing downlit has
parse_code = function(code) {
  parse(
    text = code,
    keep.source = TRUE
  ) %>%
    xmlparsedata::xml_parse_data(pretty = TRUE) %>%
    xml2::read_xml()
}
