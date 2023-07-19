#' Label variables
#'
#' @inheritParams spq_select
#' @param .languages
#'
#' @return A query object
#' @export
#'
#' @examples
#' \dontrun{
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
#' }
spq_label <- function(.query, ..., .languages = getOption("glitter.lang", "en")) {
  vars = purrr::map_chr(rlang::enquos(...), spq_treat_argument)
  .languages = tolower(.languages)

  .query = purrr::reduce(
    vars,
    function(query, x) {

      q <- spq_add(
        query,
        sprintf("%s rdfs:label %s_labell", x, x),
        .required = FALSE,
        .filter = paste(
          sprintf("langMatches(lang(%s_labell), '%s')", x, .languages),
          collapse = " || "
        )
      )

      mutate_left <- sprintf("%s_label", sub("\\?", "", x))
      mutate_right <- sprintf("coalesce(%s_labell, '')", sub("\\?", "", x))
      args_list <- list(.query = q, m = mutate_right)
      names(args_list)[2] <- mutate_left
      q = do.call(spq_mutate, args_list)
      q = spq_select(q, sprintf("-%s_labell", sub("\\?", "", x)))

      # we add the language of the label in all cases
      # because of regional variants
      mutate_left <- sprintf("%s_label_lang", sub("\\?", "", x))
      mutate_right <- sprintf("lang(%s_labell)", sub("\\?", "", x))
      args_list <- list(.query = q, m = mutate_right)
      names(args_list)[2] <- mutate_left
      do.call(spq_mutate, args_list)
    },
    .init = .query
  )
# TODO add .overwrite
  .query

}
