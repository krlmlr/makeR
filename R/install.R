#' @export
install_hooks <- function(pkg = ".") {
  pkg <- devtools::as.package(pkg)

  hooks_path <- system.file("gitflow", package = PACKAGE_NAME)
  hooks_files <- dir(hooks_path)
  hooks_abs_files <- file.path(hooks_path, hooks_files)

  target_path <- file.path(pkg$path, ".git", "hooks")

  invisible(setNames(file.symlink(hooks_abs_files, target_path), hooks_files))
}
