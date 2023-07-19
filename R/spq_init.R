#' Initialize a query object.
#' @return A query object
#' @export
#' @section Printing:
#' SPARQL queries are shown using the cli package,
#' with a built-in theme.
#' You can change it by using the `cli.user_theme` option.
#' We use
#' - `.emph` for keywords and functions,
#' - `.field` for variables,
#' - `.pkg` for prefixes,
#' - `.val` for strings,
#' - `.url` for prefix URLs.
#'
#' You can also turn off the cli behavior by setting the environment variable
#' `"GLITTER.NOCLI"` to any non-empty string.
#' That's what we do in glitter snapshot tests.
spq_init = function(){
  query = list(
    prefixes_provided = tibble::tibble(name = NULL, url = NULL),
    prefixes_used = NULL,
    previous_subject = NULL,
    select = NULL,
    spq_duplicate = NULL,
    body = "",
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
    .emph = list(color = "darkgreen", "font-weight" = "bold", "font-style" = "normal"),
    .field = list(color = "midnightblue"),
    .pkg = list(color = "mediumblue", "font-weight" = "bold"),
    .val = list(color = "darkred"),
    .url = list(color = "purple")
  )

  text = spq_assemble(x, strict = FALSE)

  text <- strsplit(text, "\n")[[1]]

  text <- gsub("\\{", "{{", text)
  text <- gsub("\\}", "}}", text)

  text[!grepl("^PREFIX", text)] <- gsub(
    "([A-Za-z0-9]*(?=\\:))",
    "{.pkg \\1}",
    text[!grepl("^PREFIX", text)],
    perl = TRUE
  )

  text[!grepl("^PREFIX", text)] <- gsub(
    "((?<=\\:)[A-Za-z0-9]*)",
    "{.emph \\1}",
    text[!grepl("^PREFIX", text)],
    perl = TRUE
  )

  text <- gsub(
    "([A-Z]*(?=\\())",
    "{.emph \\1}",
    text,
    perl = TRUE
  )

  text <- gsub(
    "(BIND|IN|OPTIONAL|AS|SELECT|DISTINCT|REDUCED|WHERE|PREFIX|FILTER|OFFSET|LIMIT|ORDER BY|GROUP BY|SERVICE)",
    "{.emph \\1}",
    text,
    perl = TRUE
  )

  text <- gsub(
    "\\<(.*)\\>",
    "{.url \\1}",
    text,
    perl = TRUE
  )

  text <- gsub(
    "(\\?[a-zA-Z0-9\\_]+)",
    "{.field \\1}",
    text,
    perl = TRUE
  )

  text <-  gsub(
    '"(.*)"',
    "{.val \\1}",
    text,
    perl = TRUE
  )

  cli::cli_format_method({
    cli::cli_bullets(text)
  },
    theme = getOption("cli.user_theme") %||% spq_theme)
}

#' @export
print.sparqle_query <- function(x, ...) {
  if (nzchar(Sys.getenv("GLITTER.NOCLI"))) {
    spq_assemble(x, strict = FALSE) %>% cat()
  } else {
    cat(format(x, ...), sep = "\n")
  }
}
