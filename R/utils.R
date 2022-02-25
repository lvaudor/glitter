assert_whether_character <- function(eval_try) {
  if (!inherits(eval_try, "try-error") && is.character(eval_try)) {
    rlang::abort(
      message = c(
        x = sprintf('Cannot use "%s"', eval_try),
        i = "Did you mean to pass a string? Use spq() to wrap it."
      )
    )
  }
}
