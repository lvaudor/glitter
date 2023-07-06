#' Initialize a query object.
#' @param endpoint SPARQL endpoint to send the query to
#' @return A query object
#' @export
spq_init=function(endpoint = NULL){
  query=list(
    endpoint = NULL,
    prefixes_provided = tibble::tibble(name=NULL,url=NULL),
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
    .emph = list(color = "black", "font-weight" = "bold", "font-style" = "normal"),
    .pkg = list(color = "cyan")
  )

  pieces <- build_pieces(x, strict = FALSE)
  body <- stringr_str_replace_all(pieces[["body"]], "\{", "{{")
  body <- stringr_str_replace_all(body, "\}", "}}")
  body <- stringr::str_replace_all(body, "(\\?[a-zA-Z0-9]+)", "{{.pkg \\1}} ")
browser()
  cli::cli_format_method({
    cli::cli_text(pieces[["part_prefixes"]])
    cli::cli_text('{.emph SELECT} {cli_text(pieces[["spq_duplicate"]])} {.pkg {paste0(pieces[["select"]], collapse = " ")}}')
    cli::cli_text('{.emph WHERE} {{')
    cli::cli_text('{body}')
    cli::cli_text('{pieces[["binded"]]}')
    cli::cli_text('{pieces[["filters"]]}')
    cli::cli_text('{pieces[["service"]]}')
    cli::cli_text('{}}}')
    cli::cli_text('{pieces[["group_by"]]}')
    cli::cli_text('{pieces[["order_by"]]}')
    cli::cli_text('{pieces[["limit"]]}')
    cli::cli_text('{pieces[["offset"]]}')
  },
    theme = spq_theme)
}

#' @export
print.sparqle_query <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
}
