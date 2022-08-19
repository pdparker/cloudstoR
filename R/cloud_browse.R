#' cloud_browse
#'
#' @description
#' Navigate the folder tree interactively. This is useful for finding a file or
#' folder path which can then be used in `cloud_get()` or `cloud_put()`.
#' This function is only intended to be used interactively - you should not use
#' this function programmatically.
#'
#' When you call `cloud_browse()` you are given a list of files and folders
#' (either at the top-level, or from the provided `path`). You provide the
#' numeric number of the folder or file you wish to move to to continue. If you
#' are not at the top level, you can select "../" to move up one folder. At any
#' time you can select 0 to exit the interactive navigation.
#'
#' If you select a folder, you are shown the files and folders within that
#' folder. If you select a file, the full path for the file is shown (so that
#' it can be passed to another function) and the interactive session is ended.
#'
#' @param path The initial path to start the search. If not provided, the
#' function starts at the top-level folder.
#' @param user Your Cloudstor username.
#' @param password Your Cloudstor password.
#'
#' @return the last file path
#' @export
cloud_browse <- function(path = "",
                         user = cloud_auth_user(),
                         password = cloud_auth_pwd()) {
  choice <- 1
  first_run <- TRUE
  new_path <- path

  while (choice != 0) {
    opts <- cloud_list(
      path = new_path,
      user = user,
      password = password
    )

    if (new_path != "") {
      # Append only if not at the top of the tree
      opts <- append(opts, "../")
    }

    if (first_run) {
      # Instructions are only shown for the first run
      cli::cli_h1("Cloud Browser")
      cli::cli_text(cli::style_bold("Instructions"))
      cli::cli_text(
        "Select the next location or file.
                    Select \"../\" to move up a level, if possible.
                    Use 0 to exit."
      )
    }

    choice <- utils::menu(opts)
    if (choice != 0) {
      opt_chosen <- opts[[choice]]
      if (opt_chosen == "../") {
        # If move up tree is chosen
        temp_path <- dirname(new_path)
        if (temp_path == ".") {
          new_path <- ""
        } else {
          new_path <- temp_path
        }
      } else {
        # Append the option to the existing path
        if (nchar(new_path) > 0 &
          substr(new_path, nchar(new_path), nchar(new_path)) != "/") {
          new_path <- paste(new_path, opt_chosen, sep = "/")
        } else {
          new_path <- paste(new_path, opt_chosen, sep = "")
        }
      }
    }

    # If the selection is a file, force exit
    if (nchar(new_path) > 0 &
      substr(new_path, nchar(new_path), nchar(new_path)) != "/") {
      choice <- 0
    }
    first_run <- FALSE
  }
  return(new_path)
}
