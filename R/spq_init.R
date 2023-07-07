#' Initialize a query object.
#' @return A query object
#' @export
spq_init = function(){
  query = list(
    prefixes_provided = tibble::tibble(name = NULL, url = NULL),
    prefixes_used = NULL,
    previous_subject = NULL,
    select = NULL,
    spq_duplicate = NULL,
    body = "",
    service = NULL,
    filter = NULL,
    limit = NULL,
    group_by = NULL,
    order_by = NULL,
    offset = NULL
  )

  structure(query, class = c("sparqle_query", "list"))
}

#' @export
format.sparqle_query <- function(x, ...) {

  spq_theme = list(
    .emph = list(color = "darkred", "font-weight" = "bold", "font-style" = "normal"),
    .pkg = list(color = "darkgreen")
  )

  text = spq_assemble(x, strict = FALSE)
browser()
  text <- strsplit(text, "\n")[[1]]
  text <- gsub("^[A-Z]* ", "{.emph \\1}", text)

  text <- gsub("\\{", "{{", text)
  text <- gsub("\\}", "}}", text)

  cli::cli_format_method({
    cli::cli_text(text)
  },
    theme = spq_theme)
}

#' @export
print.sparqle_query <- function(x, ...) {
  if (nzchar(Sys.getenv("GLITTER.NOCLI"))) {
    spq_assemble(x, strict = FALSE) %>% cat()
  } else {
    cat(format(x, ...), sep = "\n")
  }
}
