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
    "if_else", "IF",
    "same_term", "sameTerm"
  )

usethis::use_data(misc_functions, overwrite = TRUE)

# Functions on strings --------------------------------------------
strings_functions <- tibble::tribble(
    ~R, ~SPARQL, ~args,
    "str_length", "STRLEN", list(),
  # !!! the second argument for SPARQL is lenth
  # And no argument is named
    "str_sub", "SUBSTR", list(
      tibble::tibble(
        R = c("string", "start", "end"),
        SPARQL = c(NULL, NULL, NULL)
      )
      ),
    "str_to_upper", "UCASE", list(),
    "str_to_lower", "LCASE", list(),
    "str_starts", "STRSTARTS", list(
      tibble::tibble(
        R = c("string", "pattern", "negate"),
        SPARQL = c(NULL, NULL, NA) # not possible to negate in SPARQL
      )
      ),
    "str_ends", "STRENDS", list(
      tibble::tibble(
        R = c("string", "pattern", "negate"),
        SPARQL = c(NULL, NULL, NA) # not possible to negate in SPARQL
      )
      ),
    "str_detect", "CONTAINS", list(
      tibble::tibble(
        R = c("string", "pattern", "negate"),
        SPARQL = c(NULL, NULL, NA) # not possible to negate in SPARQL
      )
      ),
    "str_before", "STRBEFORE", list(),
    "str_after", "STRAFTER", list(),
    "URLencode", "ENCODE_FOR_URI", list(),
    "paste0", "CONCAT", list(),
    "", "REGEX", list()
  )

usethis::use_data(strings_functions, overwrite = TRUE)

# Operators ------------------------------------------------
operators <- tibble::tribble(
    ~R, ~SPARQL,
    "==", "=",
    "%in%", "IN",
    "|", "||",
    "||", "||",
    "&", "&",
    "&&", "&"
  )

usethis::use_data(operators, overwrite = TRUE)
