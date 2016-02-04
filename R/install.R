#' @export
install_hooks <- function(pkg = ".") {
  pkg <- devtools::as.package(pkg)

  hooks_path <- system.file("gitflow", package = PACKAGE_NAME)
  target_path <- file.path(pkg$path, ".git", "hooks")

  file.symlink(dir(hooks_path, full.names = TRUE), target_path)
}
