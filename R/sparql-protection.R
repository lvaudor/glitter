# Adapted from https://github.com/tidyverse/dbplyr/blob/27dec37db0187328ba9080e56603bacc4ec708f9/R/sql.R
#' SPARQL escaping.
#'
#' Like `dbplyr::spq()`.
#'
#' @param ... Character vectors that will be combined into a single SPARQL
#'   expression.
#' @export
spq <- function(...) {
  x <- c_character(...)
  structure(x, class = c("spq", "character"))
}

#' @export
print.spq <- function(x, ...) cat(format(x, ...), sep = "\n")
#' @export
format.spq <- function(x, ...) {
  if (length(x) == 0) {
    paste0("<SPARQL> [empty]")
  } else {
    if (!is.null(names(x))) {
      paste0("<SPARQL> ", paste0(x, " AS ", names(x)))
    } else {
      paste0("<SPARQL> ", x)
    }
  }
}

#' @rdname spq
#' @export
is.spq <- function(x) inherits(x, "spq")

c_character <- function(...) {
  x <- c(...)
  if (length(x) == 0) {
    return(character())
  }

  if (!is.character(x)) {
    abort("Character input expected")
  }

  x
}



#' @rdname spq
#' @export
#' @param x Object to coerce
as.spq <- function(x) UseMethod("as.spq")

#' @export
as.spq.spq <- function(x) x
#' @export
as.spq.character <- function(x) spq(x)
