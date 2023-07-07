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
    .emph = list(color = "darkred", "font-weight" = "bold", "font-style" = "normal"),
    .pkg = list(color = "darkgreen")
  )

  pieces = build_pieces(x, strict = FALSE)
  body = pieces[["body"]] %>%
    stringr::str_replace_all("\\{", "{{") %>%
    stringr::str_replace_all("\\}", "}}") %>%
    stringr::str_replace_all("(\\?[a-zA-Z0-9]+)", "{.pkg \\1}") %>%
    stringr::str_replace_all("OPTIONAL", "{.emph OPTIONAL}") %>%
    stringr::str_replace_all("VALUES", "{.emph VALUES}") %>%
    stringr::str_replace_all("BIND", "{.emph BIND}")


  select = pieces[["select"]] %>%
    stringr::str_replace_all("(\\?[a-zA-Z0-9]+)", "{.pkg \\1}")
  select = gsub(" [A-Z]*\\(", "{.emph \\2}", select, perl = TRUE)
  select = gsub("^[A-Z]*\\(", "{.emph \\1_}", select, perl = TRUE)
  select = gsub("\\)", "{.emph \\1}", select, perl = TRUE)
  select = paste(select, collapse = " ")
  select = sprintf('{.emph SELECT} {pieces[["spq_duplicate"]]} %s', select)

  order_by = if (is.null(pieces[["select"]])) {
    NULL
    } else {
      order_by = pieces[["select"]] %>%
        stringr::str_replace_all("(\\?[a-zA-Z0-9]+)", "{.pkg \\1}")
        order_by = paste(order_by, collapse = " ")
        sprintf('{.emph ORDER BY} %s', order_by)
    }

  offset = if (is.null(pieces[["offset"]])) {
    NULL
    } else {
      sprintf('{.emph OFFSET} %s', pieces[["offset"]])
    }

  limit = if (is.null(pieces[["limit"]])) {
    NULL
    } else {
      sprintf('{.emph LIMIT} %s', pieces[["limit"]])
    }

  prefixes = if (is.null(pieces[["prefixes_provided"]])) {
    NULL
  } else {
    purrr::map2_chr(
      pieces[["prefixes_provided"]][["name"]],
      pieces[["prefixes_provided"]][["url"]],
      ~sprintf('{.emph PREFIX} %s: <%s>', .x, .y)
    )
  }

  service = if (is.null(pieces[["service"]])) {
    NULL
  } else {
   service =  pieces[["service"]] %>%
      stringr::str_replace_all("\\{", "{{") %>%
      stringr::str_replace_all("\\}", "}}")
    sub("SERVICE", "{.emph SERVICE}", service)
  }

  cli::cli_format_method({
    cli::cli_bullets(prefixes)
    cli::cli_text(select)
    cli::cli_text('{.emph WHERE} {{')
    cli::cli_bullets(body)
    cli::cli_text('{pieces[["binded"]]}')
    cli::cli_text('{pieces[["filters"]]}')
    cli::cli_text(service)
    cli::cli_text('{}}}')
    cli::cli_text('{pieces[["group_by"]]}')
    cli::cli_text(order_by)
    cli::cli_text(limit)
    cli::cli_text(offset)
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
