# add name for AS bla
add_as = function(string, name) {
  sprintf("(%s AS %s)", string, add_question_mark(name))
}

globalVariables("name")
