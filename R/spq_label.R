#' Label variables
#'
#' @inheritParams spq_select
#' @inheritParams spq_add
#' @param .languages Languages for which to query labels. Use `NULL` for removing
#' restrictions on language (defined or not), `"*"` for any defined language.
#' If you write "en" you
#' can get labels for regional variants such as "en-GB". If you want results for
#' "en" only, write "en$".
#' @param .overwrite whether to replace variables with their labels.
#' `spq_select(blop)` means you get both `blop` and `blop_label`.
#' `spq_select(blop, .overwrite = TRUE)` means you get the label as `blop`,
#' the "original" blop variable isn't returned.
#'
#' @return A query object
#' @export
#'
#' @section Example:
#' ```r
#' spq_init() %>%
#'   spq_add("?mayor wdt:P31 ?species") %>%
#' # dog, cat or chicken
#'   spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780')) %>%
#' # who occupy the function
#'   spq_add("?mayor p:P39 ?node") %>%
#' # of mayor
#'   spq_add("?node ps:P39 wd:Q30185") %>%
#' # of some places
#'   spq_add("?node pq:P642 ?place") %>%
#'   spq_label(mayor, place, .languages = c("fr", "en", "de")) %>%
#'   spq_perform()
#' ```
spq_label <- function(.query,
                      ...,
                      .required = FALSE,
                      .languages = getOption("glitter.lang", "en$"),
                      .overwrite = FALSE) {

  label_property <- .query[["endpoint_info"]][["label_property"]] %||%
    "rdfs:label"

  vars = purrr::map_chr(rlang::enquos(...), spq_treat_argument)

  if (!is.null(.languages)) .languages = tolower(.languages)

  .query = purrr::reduce(
    vars,
    function(query, x) {
      if (is.null(.languages)) {
        filter = NA
      } else {

        languages_filter <- purrr::map_chr(.languages, create_lang_filter, x = x)

        filter = paste(
          languages_filter,
          collapse = " || "
        )
      }
      if (.required) {
       q = spq_add(
        query,
        sprintf("%s %s %s_labell", x, label_property, x),
        .required = .required
      )
       q = spq_filter(q, spq(filter))
      } else {
      q = spq_add(
        query,
        sprintf("%s %s %s_labell", x,label_property, x),
        .required = .required,
        .filter = filter
      )
      }


      mutate_left <- sprintf("%s_label", sub("\\?", "", x))
      mutate_right <- sprintf("coalesce(%s_labell, '')", un_question_mark(x))
      args_list <- list(.query = q, m = mutate_right)
      names(args_list)[2] <- mutate_left
      q = do.call(spq_mutate, args_list)
      q = spq_select(q, sprintf("-%s_labell", un_question_mark(x)))

      # we add the language of the label
      # because of regional variants
      if (!is.null(.languages)) {
        if (length(.languages) > 1 || !grepl("\\$$", .languages)) {
          mutate_left <- sprintf("%s_label_lang", un_question_mark(x))
          mutate_right <- sprintf("lang(%s_labell)", un_question_mark(x))
          args_list <- list(.query = q, m = mutate_right)
          names(args_list)[2] <- mutate_left
          q = do.call(spq_mutate, args_list)
        }
      }
      q
    },
    .init = .query
  )

  if (.overwrite) {
    .query <- purrr::reduce(
      vars,
      \(.query, x) overwrite_with_label(.query, x),
      .init = .query
    )
  }

  .query

}

create_lang_filter = function(language, x) {
  if (grepl("\\$$", language)) {
    language <- sub("\\$$", "", language)
    sprintf("lang(%s_labell) IN ('%s')", x, language)
  } else{
    sprintf("langMatches(lang(%s_labell), '%s')", x, language)
  }
}

overwrite_with_label <- function(.query, x) {
  remove_x <- sprintf("-%s", un_question_mark(x))
  .query <- spq_select(.query, remove_x)
  .query <- spq_rename_var(
    .query,
    old = un_question_mark(x),
    new = sprintf("%s0", un_question_mark(x))
  )
  .query <- spq_rename_var(
    .query,
    old = sprintf("%s_label", un_question_mark(x)),
    new = un_question_mark(x)
  )

  .query
}
