#' Initialize a query object.
#'
#' @param endpoint Endpoint, either name if it is in `usual_endpoints`,
#' or an URL
#' @param endpoint_info Do not use for an usual endpoint in `usual_endpoints`!
#' Information about
#' the endpoint
#' @param request_control An object as returned by [`spq_control_request()`]
#'
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
spq_init = function(
    endpoint = "wikidata",
    request_control = spq_control_request(
      user_agent = getOption("glitter.ua", "glitter R package (https://github.com/lvaudor/glitter)"),
      max_tries = getOption("glitter.max_tries", 3L),
      max_seconds = getOption("glitter.max_seconds", 120L),
      timeout = getOption("glitter.timeout", 1000L),
      request_type = c("url", "body-form")
    ),
    endpoint_info = spq_endpoint_info(
      label_property = "rdfs:label"
    )
  ) {
 if (!inherits(request_control, "glitter_request_control")) {
    cli::cli_abort("{.arg request_control} must be created by {.fun spq_control_request}.")
 }
 if (!inherits(endpoint_info, "glitter_endpoint_info")) {
    cli::cli_abort("{.arg endpoint_info} must be created by {.fun spq_endpoint_info}.")
  }

  # if endpoint passed as name, get url
  endpoint = tolower(endpoint)
  usual_endpoint_info = usual_endpoints %>%
    dplyr::filter(.data$name == endpoint)
  if (nrow(usual_endpoint_info) > 0) {
    endpoint = dplyr::pull(usual_endpoint_info, .data$url)
    label_property = dplyr::pull(usual_endpoint_info, .data$label_property)
  } else {
    endpoint
    label_property = NULL
  }

  endpoint_info = list(
    endpoint_url = endpoint,
    label_property = label_property %||% endpoint_info[["label_property"]]
  )

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
    offset = NULL,
    endpoint_info = endpoint_info,
    request_control = request_control
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

  text <- strsplit(text, "\n", fixed = TRUE)[[1]]

  text <- gsub("\\{", "{{", text, fixed = TRUE)
  text <- gsub("\\}", "}}", text, fixed = TRUE)

  text[!is.na(text) & !startsWith(text, "PREFIX")] <- gsub(
    "([A-Za-z0-9]*(?=\\:))",
    "{.pkg \\1}",
    text[!is.na(text) & !startsWith(text, "PREFIX")],
    perl = TRUE
  )

  text[!is.na(text) & !startsWith(text, "PREFIX")] <- gsub(
    "((?<=\\:)[A-Za-z0-9]*)",
    "{.emph \\1}",
    text[!is.na(text) & !startsWith(text, "PREFIX")],
    perl = TRUE
  )

  text <- gsub(
    "([AZ][A-Z_]*(?=\\())",
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
