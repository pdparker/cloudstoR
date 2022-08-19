#' cloud_auth
#'
#' @description
#' `cloud_auth()` gets the user's credentials and stores them securely in
#' keyring.
#'
#' @param reset_keys Override existing keys.
#'
#' @return Nothing. Keys are stored in keyring.
#' @export
cloud_auth <- function(reset_keys = FALSE) {
  current_keys <- keyring::key_list()$service

  if ((!reset_keys) &
    ("Cloudstor_USER" %in% current_keys) &
    ("Cloudstor_PWD" %in% current_keys)) {
    # No reason to run script
    return(NULL)
  }

  cli::cli_div(theme = list(span.emph = list(color = "orange")))
  cli::cli_text(
    "cloudstoR will save your credentials to your device using ",
    "{.pkg keyring}. You can read about keyring here: ",
    "{.url https://cran.r-project.org/web/packages/keyring/index.html}"
  )
  cli::cli_text(
    "You should use an {.emph App Password} for authentication. ",
    "For details about app passwords, see ",
    "{.url https://support.aarnet.edu.au/hc/en-us/articles/",
    "236034707-How-do-I-manage-change-my-passwords-}"
  )
  cli::cli_end()

  if (utils::menu(c("Yes", "No"), title = "Proceed?") == 2) {
    stop(
      "Not storing credentials. ",
      "Please provide arguements to username and password."
    )
  }

  # Get username
  keyring::key_set_with_value("CLOUDSTOR_USER",
    password = readline("What is your CloudStor email address?")
  )
  # Get password
  keyring::key_set_with_value("CLOUDSTOR_PWD",
    password = getPass::getPass(msg = "Password/Token")
  )

  cli::cli_alert_success("Credentials stored.")
}


#' cloud_auth_user
#'
#' Used to return a stored Cloudstor username, or request the user set one.
#' Not a user-facing function.
#' @return user id as string.
#' @keywords internal
cloud_auth_user <- function() {
  if (!"CLOUDSTOR_USER" %in% keyring::key_list()$service) {
    cloud_auth()
  }
  return(keyring::key_get("CLOUDSTOR_USER"))
}

#' cloud_auth_pwd
#'
#' Used to return a stored Cloudstor password, or request the user set one.
#' Not a user-facing function.
#' @return user password as string.
#' @keywords internal
cloud_auth_pwd <- function() {
  if (!"CLOUDSTOR_PWD" %in% keyring::key_list()$service) {
    cloud_auth()
  }
  return(keyring::key_get("CLOUDSTOR_PWD"))
}
