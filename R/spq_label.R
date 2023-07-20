#' Label variables
#'
#' @inheritParams spq_select
#' @inheritParams spq_add
#' @param .languages Languages for which to query labels. Use `NULL` for removing
#' restrictions on language (defined or not), `"*"` for any defined language.
#' If you write "en" you
#' can get labels for regional variants such as "en-GB". If you want results for
#' "en" only, write "en$".
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
spq_label <- function(.query, ..., .required = FALSE,.languages = getOption("glitter.lang", "en$")) {
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
        sprintf("%s rdfs:label %s_labell", x, x),
        .required = .required
      )
       q = spq_filter(q, spq(filter))
      } else {
      q = spq_add(
        query,
        sprintf("%s rdfs:label %s_labell", x, x),
        .required = .required,
        .filter = filter
      )
      }


      mutate_left <- sprintf("%s_label", sub("\\?", "", x))
      mutate_right <- sprintf("coalesce(%s_labell, '')", sub("\\?", "", x))
      args_list <- list(.query = q, m = mutate_right)
      names(args_list)[2] <- mutate_left
      q = do.call(spq_mutate, args_list)
      q = spq_select(q, sprintf("-%s_labell", sub("\\?", "", x)))

      # we add the language of the label
      # because of regional variants
      if (!is.null(.languages)) {
        if (length(.languages) > 1 || !grepl("\\$$", .languages)) {
          mutate_left <- sprintf("%s_label_lang", sub("\\?", "", x))
          mutate_right <- sprintf("lang(%s_labell)", sub("\\?", "", x))
          args_list <- list(.query = q, m = mutate_right)
          names(args_list)[2] <- mutate_left
          q = do.call(spq_mutate, args_list)
        }
      }
      q
    },
    .init = .query
  )
# TODO add .overwrite
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
