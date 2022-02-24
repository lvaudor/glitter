# Functions on multisets --------------------------------
set_functions <- tibble::tribble(
    ~R, ~SPARQL, ~args,
    "n", "COUNT", list(),
    "sum", "SUM", list(),
    "mean", "AVG", list(),
    "min", "MIN", list(),
    "max", "MAX", list(),
    "sample", "SAMPLE", list(),
    "str_c", "GROUP_CONCAT", list(tibble::tibble(R = "sep", SPARQL = "SEPARATOR"))
  )

usethis::use_data(set_functions, overwrite = TRUE)

# Functions on terms ---------------------------------------------------
term_functions <- tibble::tribble(
    ~R, ~SPARQL,
    "is.iri", "isIRI",
    "is.uri", "isURI", # synonym of isIRI
    "is.null", "isBlank",
    "is.literal", "isLiteral",
    "is.numeric", "isNumeric",
    "as.character", "str",
    "lang", "lang",
    "typeof", "datatype",
    "as.iri", "IRI",
    "as.character", "URI", # synonym of IRI
    "bnode", "BNODE", # useful?
    "str_dt", "STRDT",
    "str_lang", "STRLANG",
    "uuid", "UUID",
    "str_uuid", "STRUUID"
  )

usethis::use_data(term_functions, overwrite = TRUE)

# Functions... miscellaneous --------------------------------------------
misc_functions <- tibble::tribble(
    ~R, ~SPARQL,
    "bound", "bound",
    "coalesce", "COALESCE",
    "if_else", "IF"
  )

usethis::use_data(misc_functions, overwrite = TRUE)

# Operators ------------------------------------------------
operators <- tibble::tribble(
    ~R, ~SPARQL,
    "==", "=",
    "%in%", "IN",
    "|", "||",
    "||", "||"
  )

usethis::use_data(operators, overwrite = TRUE)
