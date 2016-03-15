#' @export
install_hooks <- function(pkg = ".", overwrite = TRUE) {
  pkg <- devtools::as.package(pkg)

  hooks_path <- system.file("gitflow", package = PACKAGE_NAME)
  hooks_files <- dir(hooks_path)
  hooks_abs_files <- file.path(hooks_path, hooks_files)

  target_path <- file.path(pkg$path, ".git", "hooks")

  if (overwrite)
    unlink(file.path(target_path, hooks_files), force = TRUE)

  invisible(setNames(file.symlink(hooks_abs_files, target_path), hooks_files))
}

#' @export
install_makefile <- function(pkg = ".", filename = "Makefile",
                             overwrite = FALSE) {
  pkg <- devtools::as.package(pkg)

  text <- c(
    "MAKEFILE_LOC := $(shell Rscript -e \"cat(system.file('Makefile',package='" %+%
      .packageName %+% "'))\" )",
    "include ${MAKEFILE_LOC}"
  )

  file_path <- file.path(pkg$path, filename)
  if (!overwrite && file.exists(file_path)) {
    stop("Package ", pkg$package, " already has file ", filename,
         call. = FALSE)
  }

  writeLines(text, file_path)
}
