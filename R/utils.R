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
