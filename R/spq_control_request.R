#' Create the request control object for `spq_init()`
#'
#' @param user_agent a string indicating the user agent to send with the query.
#' @param max_tries,max_seconds Cap the maximal number of
#' attemps with `max_tries` or the total elapsed time from the first request
#' with `max_seconds`.
#' @param timeout maximum number of seconds to wait (`httr2::req_timeout()`).
#' @param request_type a string indicating how the query should be sent: in the
#' URL (`url`, default, most common) or as a body form (`body-form`).
#' @inheritParams httr2::req_throttle
#'
#' @return A list to be used in `spq_init()`'s `request_control` argument.
#' @export
#'
#' @examples
#' # Defaults
#' spq_control_request()
#' # Tweaking values
#' spq_control_request(
#'   user_agent = "Jane Doe https://example.com",
#'   max_tries = 1L,
#'   max_seconds = 10L,
#'   timeout = 10L,
#'   request_type = "url"
#' )
spq_control_request <- function(user_agent = getOption("glitter.ua", "glitter R package (https://github.com/lvaudor/glitter)"),
                                max_tries = getOption("glitter.max_tries", 3L),
                                max_seconds = getOption("glitter.max_seconds", 120L),
                                timeout = getOption("glitter.timeout", 1000L),
                                request_type = c("url", "body-form"),
                                rate = NULL,
                                realm = NULL) {


  if (!is.character(user_agent)) {
    cli::cli_abort("Must provide a character as {.arg user_agent}.")
  }

  if (!is.integer(max_tries)) {
    cli::cli_abort(c(
      "Must provide an integer as {.arg max_tries}.",
      i = "You provided a {.val {typeof(max_tries)}}."
      ))
  }

  if (!is.integer(max_seconds)) {
    cli::cli_abort(c(
      "Must provide an integer as {.arg max_seconds}.",
      i = "You provided a {.val {typeof(max_seconds)}}."
      ))
  }

  if (!is.integer(timeout)) {
    cli::cli_abort(c(
      "Must provide an integer as {.arg timeout}.",
      i = "You provided a {.val {typeof(timeout)}}."
      ))
  }

  request_type = rlang::arg_match(request_type, c("url", "body-form"))
  structure(
    list(
      user_agent = user_agent,
      max_tries = max_tries,
      max_seconds = max_seconds,
      timeout = timeout,
      request_type = request_type,
      rate = rate,
      realm = realm
    ),
    class = "glitter_request_control"
  )

}
