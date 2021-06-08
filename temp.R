cloud_auth <- function(reset_keys = FALSE) {
  current_keys <- keyring::key_list()$service

  if ((!reset_keys) &
    ("Cloudstor_USR" %in% current_keys) &
    ("Cloudstor_PWD" %in% current_keys)) {
    # No reason to run script
    return(NULL)
  }
  else {
    # Check if we can use Rstudioapi
    if ("rstudioapi" %in% rownames(installed.packages())) {
      rstudio <- rstudioapi::isAvailable()
    } else {
      rstudio <- FALSE
    }

    cli::cli_alert_warning("cloudstoR will save your credentials to your device keyring.")
    cli::cli_alert_warning("These are secure, but can be read by other programs on your machine.")
    cli::cli_alert_warning("You can read about keyring here: https://cran.r-project.org/web/packages/keyring/index.html")

    if (utils::menu(c("Yes","No"), title="Proceed?") == 2){
      stop("Not storing credentials. Please provide arguements to username and password.")
    }




    }
}


cloud_auth_user <- function(){
  if ("CLOUDSTOR_USER" %in% keyring::key_list()$service){
    return(keyring::key_get("CLOUDSTOR_USER"))
  } else {
    cloud_auth()
    return(keyring::key_get("CLOUDSTOR_USER"))
  }
}

cloud_auth_pwd <- function(){
  if ("CLOUDSTOR_PWD" %in% keyring::key_list()$service){
    return(keyring::key_get("CLOUDSTOR_PWD"))
  } else {
    cloud_auth()
    return(keyring::key_get("CLOUDSTOR_PWD"))
  }
}
}
