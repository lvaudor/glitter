#' Label variables
#'
#' @inheritParams spq_select
#' @param .languages
#'
#' @return A query object
#' @export
#'
#' @examples
spq_label <- function(.query, ..., .languages = getOption("glitter.lang", "en")) {
  vars = purrr::map_chr(rlang::enquos(...), spq_treat_argument)

  .query = purrr::reduce(
    vars,
    function(query, x) {
      filter <- sprintf("lang(%sLabel) %%in%% c(%s)", sub("\\?", "", x), toString(sprintf("'%s'", .languages)))

      q <- spq_add(query, sprintf("%s rdfs:label %sLabel", x, x), .required = FALSE) %>%
        spq_filter(filter)

      mutate_left <- sprintf("%sLabelLang", sub("\\?", "", x))
      mutate_right <- sprintf("lang(%sLabel)", sub("\\?", "", x))
      args_list <- list(.query = q, m = mutate_right)
      names(args_list)[2] <- mutate_left
      do.call(spq_mutate, args_list)
    },
    .init = .query
  )

  .query

}
