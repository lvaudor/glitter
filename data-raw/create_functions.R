# Functions on multisets --------------------------------
set_functions = tibble::tribble(
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
term_functions = tibble::tribble(
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
    "str_uuid", "STRUUID",
    "as.integer", "xsd:integer",
    "as.datetime", "xsd:dateTime",
    "as.logical", "xsd:boolean",
    "as.double", "xsd:double",
    "as.float", "xsd:float",
    "as.decimal", "xsd:decimal",
    "as.str", "xsd:string"
)

usethis::use_data(term_functions, overwrite = TRUE)

# Functions... miscellaneous --------------------------------------------
misc_functions = tibble::tribble(
    ~R, ~SPARQL,
    "bound", "bound",
    "coalesce", "COALESCE",
    "if_else", "IF",
    "same_term", "sameTerm",
    "runif", "RAND",
    "Sys.time", "NOW",
    "desc", "DESC",
    "asc", "ASC"
  )

usethis::use_data(misc_functions, overwrite = TRUE)

# Functions on strings --------------------------------------------
stringr_common_args = tibble::tibble(
        R = c("string", "pattern", "negate"),
        SPARQL = c("", "", NA) # not possible to negate in SPARQL
      )
string_functions = tibble::tribble(
    ~R, ~SPARQL, ~args,
    "str_length", "STRLEN", list(),
  # !!! the second argument for SPARQL is lenth
  # And no argument is named
    "str_sub", "SUBSTR", list(
      tibble::tibble(
        R = c("string", "start", "end"),
        SPARQL = c("", "", "")
      )
      ),
    "str_to_upper", "UCASE", list(),
    "str_to_lower", "LCASE", list(),
    "str_starts", "STRSTARTS", list(stringr_common_args),
    "str_ends", "STRENDS", list(stringr_common_args),
    "str_detect", "CONTAINS", list(stringr_common_args),
    "str_before", "STRBEFORE", list(),
    "str_after", "STRAFTER", list(),
    "URLencode", "ENCODE_FOR_URI", list(),
    "paste0", "CONCAT", list(),
    "str_detect", "REGEX", list(stringr_common_args),
    "str_replace", "REGEX", list(
      tibble::tibble(
        R = c("string", "pattern", "replacement"),
        SPARQL = c("", "", "")
      )
    )
  )

usethis::use_data(string_functions, overwrite = TRUE)

# Functions on numerics ----------------------------------
numeric_functions = tibble::tribble(
    ~R, ~SPARQL,
    "abs", "abs",
    "round", "round",
    "ceiling", "ceil",
    "floor", "floor"
)
usethis::use_data(numeric_functions, overwrite = TRUE)

# Functions on date/time ----------------------------------
datetime_functions = tibble::tribble(
    ~R, ~SPARQL,
    "year", "YEAR",
    "month", "MONTH",
    "day", "DAY",
    "hours", "HOURS",
    "minutes", "MINUTES",
    "seconds", "SECONDS",
    "tz", "tz"
)
usethis::use_data(datetime_functions, overwrite = TRUE)

# Operators ------------------------------------------------
operators = tibble::tribble(
    ~R, ~SPARQL,
    "==", "=",
    "%in%", "IN",
    "|", "||",
    "||", "||",
    "&", "&",
    "&&", "&"
  )

usethis::use_data(operators, overwrite = TRUE)

# All ------------------------------------
all_correspondences <- dplyr::bind_rows(
  set_functions,
  term_functions,
  misc_functions,
  string_functions,
  numeric_functions,
  datetime_functions,
  operators
)
usethis::use_data(all_correspondences, overwrite = TRUE)
