R	:= R --no-save --no-restore
RSCRIPT	:= Rscript
DELETE	:= rm -fR
PKGNAME := $(shell Rscript ./makeR/get-pkg-name)
VERSION := $(shell Rscript ./makeR/get-pkg-version)
TARGZ   := $(PKGNAME)_$(VERSION).tar.gz

.SILENT:
.PHONEY: clean roxygenize package windows install dependencies test check

usage:
	echo "Available targets:"
	echo ""
	echo " clean          - Clean everything up"
	echo " roxygenize     - roxygenize in-place"
	echo " package        - build source package"
	echo " install        - install the package"
	echo " dependencies   - install package dependencies, including suggests"
	echo " test           - run unit tests"
	echo " check          - run R CMD check on the package"
	echo " check-rev-dep  - run a reverse dependency check against packages on CRAN"
	echo " check-rd-files - run Rd2pdf on each doc file to track hard-to-spot doc/latex errors"
	echo " winbuilder     - ask for email and build on winbuilder"
	echo " upgrade        - upgrade installation of makeR"

clean:
	echo  "Cleaning up ..."
	${DELETE} src/*.o src/*.so *.tar.gz
	${DELETE} *.Rcheck
	${DELETE} .RData .Rhistory

git:
	test "$$(git status --porcelain | wc -c)" = "0"

master: git
	test $$(git rev-parse --abbrev-ref HEAD) = "master"

inst/web:
	git branch gh-pages origin/gh-pages || true
	git clone --branch gh-pages . inst/web

gh-pages-build: staticdocs
	cd inst/web && git fetch && git merge --no-edit origin/master --strategy ours && git add . && git commit --amend --no-edit && git push -f origin gh-pages

gh-pages-push:
	git push origin gh-pages

rd: git
	Rscript -e "library(methods); devtools::document()"
	git add man/ NAMESPACE
	test "$$(git status --porcelain | wc -c)" = "0" || git commit -m "document"

inst/NEWS.Rd: git NEWS.md
	Rscript -e "tools:::news2Rd('$(word 2,$^)', '$@')"
	sed -r -i 's/`([^`]+)`/\\code{\1}/g' $@
	git add $@
	test "$$(git status --porcelain | wc -c)" = "0" || git commit -m "update NEWS.Rd"

tag:
	(echo Release v$$(sed -n -r '/^Version: / {s/.* ([0-9.-]+)$$/\1/;p}' DESCRIPTION); echo; sed -n '/^===/,/^===/{:a;N;/\n===/!ba;p;q}' NEWS.md | head -n -3 | tail -n +3) | git tag -a -F /dev/stdin v$$(sed -n -r '/^Version: / {s/.* ([0-9.-]+)$$/\1/;p}' DESCRIPTION)

bump-cran-desc: master rd
	crant -u 2 -C

bump-gh-desc: master rd
	crant -u 3 -C

bump-desc: master rd
	test "$$(git status --porcelain | wc -c)" = "0"
	sed -i -r '/^Version: / s/( [0-9.]+)$$/\1-0.0/' DESCRIPTION
	git add DESCRIPTION
	test "$$(git status --porcelain | wc -c)" = "0" || git commit -m "add suffix -0.0 to version"
	crant -u 4 -C

bump-cran: bump-cran-desc inst/NEWS.Rd tag

bump-gh: bump-gh-desc inst/NEWS.Rd tag

bump: bump-desc inst/NEWS.Rd tag

install:
	Rscript -e "sessionInfo()"
	Rscript -e "devtools::install_github('hadley/testthat')"
	Rscript -e "options(repos = 'http://cran.rstudio.com'); devtools::install_deps(dependencies = TRUE)"

test:
	Rscript -e "devtools::check(document = FALSE, check_dir = '.', cleanup = FALSE)"
	! egrep -A 5 "ERROR|WARNING|NOTE" *.Rcheck/00check.log

covr:
	Rscript -e 'if (!requireNamespace("covr")) devtools::install_github("jimhester/covr"); covr::codecov()'

lintr:
	Rscript -e 'if (!requireNamespace("lintr")) devtools::install_github("jimhester/lintr"); lintr::lint_package()'

staticdocs: inst/web
	Rscript -e 'if (!requireNamespace("staticdocs")) devtools::install_github("gaborcsardi/staticdocs@crayon-colors"); staticdocs::build_site()'

view-docs:
	chromium-browser inst/web/index.html

wercker-build:
	wercker build --docker-host=unix://var/run/docker.sock --no-remove

wercker-deploy:
	wercker deploy --docker-host=unix://var/run/docker.sock --no-remove

roxygenize: clean
	echo "Roxygenizing package ..."
	${RSCRIPT} ./makeR/roxygenize

package: roxygenize
	echo "Building package file $(TARGZ)"
	${R} CMD build .

install: package
	echo "Installing package $(TARGZ)"
	${R} CMD INSTALL --install-tests $(TARGZ)

test: install
	echo "Testing package $(TARGZ)"
	${RSCRIPT} ./test_all.R

check: package
	echo "Running R CMD check ..."
	${R} CMD check $(TARGZ)

dependencies:
	${RSCRIPT} ./makeR/dependencies

check-rev-dep: install
	echo "Running reverse dependency checks for CRAN ..."
	${RSCRIPT} ./makeR/check-rev-dep

check-rd-files: install
	echo "Checking RDs one by one ..."
	${RSCRIPT} ./makeR/check-rd-files

winbuilder: roxygenize
	echo "Building via winbuilder"
	${RSCRIPT} ./makeR/winbuilder

upgrade: git master
	echo "Upgrading makeR"
	./makeR/upgrade
