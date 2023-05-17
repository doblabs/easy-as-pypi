# vim:tw=0:ts=2:sw=2:noet:ft=make:
# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/landonb/easy-as-pypi#🥧
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

PACKAGE_NAME = easy_as_pypi

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# `make docs` docs/ subdir HTML target, e.g.,
#   ./docs/_build/html/index.html
DOCS_BUILDDIR ?= _build

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# USAGE: Set BROWSER environ to pick your browser, otherwise webbrowser
# ignores the system default and goes through its list, which starts
# with 'mozilla'.
#
# E.g.,
#
#   BROWSER=chromium-browser make view-coverage
#
# Alternatively, you could leverage sensible-utils (Linux), e.g.,
#
#   BROWSER=sensible-browser make view-coverage
#
# (and probably `open` on macOS, I'd guess).

# Here we define a macro used to set a local variable we can run later.
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

PYBROWSER := python -c "$$BROWSER_PYSCRIPT"

# Note that setting the Makefile "BROWSER" variable  — or any variable with
# the same name as an existing environ from the shell (e.g., try "HOME") —
# changes the same-named environ name, e.g.,
#
#   - Herein:
#
#       BROWSER := python -c "$$BROWSER_PYSCRIPT"
#
#       print-browser-vars:
#         @echo "\$$(BROWSER): $(BROWSER)"
#         @echo "\$${BROWSER}: $${BROWSER}"
#       .PHONY: print-browser-vars
#
#   - Shell:
#
#       $ make print-browser-vars
#       $(BROWSER): python -c import os, webbrowser, sys try: from urllib ...
#       ${BROWSER}: python -c "$BROWSER_PYSCRIPT"
#
#   I.e., $(BROWSER) was set to the macro we defined (as the result of
#   the := assignment), and ${BROWSER} was set to the assignment statement
#   itself.
#
# But if we set a variable with a unique name that doesn't match an
# existing environ, that the shell variable of the same name is left
# unset, e.g.,
#
#   - Herein:
#
#     PYBROWSER := python -c "$$BROWSER_PYSCRIPT"
#
#     print-pybrowser-vars:
#       @echo "\$$(PYBROWSER): $(PYBROWSER)"
#       @echo "\$${PYBROWSER}: $${PYBROWSER}"
#     .PHONY: print-browser-vars
#
#   - Shell:
#
#     $ make print-pybrowser-vars
#     $(PYBROWSER): python -c import os, webbrowser, sys try: from urllib ...
#     ${PYBROWSER}:
#
#
# This I cannot explain (though I'd assume it's documented or at least
# there's a reasonable explanation).

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# USAGE: If you want to define your own tasks, add your own Makefile.
#
# You could e.g., define a help task extension thusly:
#
#   $ echo -e "help-local::\n\t@echo 'More help!'" > Makefile.local

-include Makefile.local

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

help: help-main help-local
.PHONY: help

help-local::
.PHONY: help-local

help-main:
	@echo "Please choose a target for make:"
	@echo
	@echo " Installing and Packaging"
	@echo " ------------------------"
	@echo "   install         install the package to the active Python's site-packages"
	@echo "   develop         install (or update) all packages required for development"
	@echo "   dist            package"
	@echo "   release         package and upload a release"
	@echo
	@echo " Developing and Testing"
	@echo " ----------------------"
	@echo "   clean           remove all build, test, coverage and Python artifacts"
	@echo "   clean-build     remove build artifacts"
	@echo "   clean-docs      remove docs from the build"
	@echo "   clean-pyc       remove compiled bytecode files"
	@echo "   clean-test      remove test and coverage artifacts"
	@echo "   cloc            run \`cloc-digest\` command aka \"count lines of code\""
	@echo "   cloc-complete   print cloc results for each file, sorted by count"
	@echo "   cloc-digest     print cloc project summary"
	@echo "   cloc-file-sort  print cloc results for each file, sorted by path"
	@echo "   cloc-sources    print cloc results for source and tests directories"
	@echo "   coverage        print coverage report after running pytest"
	@echo "   coverage-html   generate line-by-line HTML coverage reports"
	@echo "   docs            generate Sphinx HTML documentation, including API docs"
	@echo "   servedocs       watches and regenerates docs as they're edited"
	@echo "   help            print this message"
	@echo "   isort           sort and group module imports using \`isort\`"
	@echo "   lint            automatically make style fixes with \`flake8\`"
	@echo "   test            run pytest against active virtualenv or Python"
	@echo "   test-all        run tox (pytest all supported Python versions)"
	@echo "   test-debug      prepare pytest results for Vim quickfix"
	@echo "   test-one        run pytest until first test fails"
	@echo "   view-coverage   open coverage docs in browser (using BROWSER browser)"
	@echo "   whoami          print project package name [$(PACKAGE_NAME)]"
.PHONY: help-main

# Not documented (internal):
#           coverage-to-html  converts completed coverage run results to HTML
#           docs-html       called by \`docs\` to generate HTML docs
#           quickfix        called by \`test-debug\` to prepare .make.out for Vim quickfix
#           test-local      called by \`test-debug\` to generate .make.out from pytest
#           depends-active-venv  fails make command unless virtualenv active
#           depends-cloc    fails make command unless \`cloc\` installed
#           CLOC            set to \`cloc \` if cloc installed

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

clean: clean-build clean-pyc clean-test
.PHONY: clean

clean-build:
	/bin/rm -fr build/
	/bin/rm -fr dist/
	/bin/rm -fr .eggs/
	find . -name '*.egg-info' -exec /bin/rm -fr {} +
	find . -name '*.egg' -exec /bin/rm -f {} +
.PHONY: clean-build

clean-pyc:
	find . -name '*.pyc' -exec /bin/rm -f {} +
	find . -name '*.pyo' -exec /bin/rm -f {} +
	find . -name '*~' -exec /bin/rm -f {} +
	find . -name '__pycache__' -exec /bin/rm -fr {} +
.PHONY: clean-pyc

clean-test:
	/bin/rm -fr .tox/
	/bin/rm -f .coverage
	/bin/rm -fr htmlcov/
.PHONY: clean-test

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

dist: depends-active-venv clean-build
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist
.PHONY: dist

release: depends-active-venv clean-build
	python setup.py sdist bdist_wheel
	twine upload -r pypi -s dist/*
.PHONY: release

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

install: depends-active-venv clean
	python setup.py install
.PHONY: install

depends-active-venv:
	@if [ -z "${VIRTUAL_ENV}" ]; then \
		>&2 echo "ERROR: Run from a virtualenv!"; \
		exit 1; \
	fi
.PHONY: depends-active-venv

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

develop: depends-active-venv
	pip install -U pip setuptools wheel
	pip install -U -r requirements/dev.pip
	pip install -U -e .
.PHONY: develop

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

lint: depends-active-venv
	flake8 setup.py $(PACKAGE_NAME)/ tests/
	doc8
.PHONY: lint

isort: depends-active-venv
	isort --recursive setup.py $(PACKAGE_NAME)/ tests/
	# DX: End files with blank line.
	git ls-files | while read file; do \
		if [ -n "$$(tail -n1 $$file)" ]; then \
			echo "Blanking: $$file"; \
			echo >> $$file; \
		else \
			echo "DecentOk: $$file"; \
		fi \
	done
	@echo "ça va"
.PHONY: isort

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# *** Collection of pytest runners.

# SAVVY: Consider other useful options we don't expose via this Makefile, e.g.,:
#
#     pytest --pdb -vv -k test_function tests/
#
#                      ^^^^^^^^^^^^^^^^  Test specific function or class
#                  ^^^                   Increase verbosity
#            ^^^^^                       Start pdb on error or KeyboardInterrupt

test: depends-active-venv
	pytest $(TEST_ARGS) tests/
.PHONY: test

test-all: depends-active-venv
	tox
.PHONY: test-all

test-debug: test-local quickfix
.PHONY: test-debug

# SAVVY: By default, a pipeline returns the exit code of the final command,
# so if you pipe to `tee`, the pipeline always returns true, e.g.,
#
#   pytest ... | tee ...
#
# will always return true, regardless of py.text failing or not.
#
# - One work-around is the pipefail option,
#   e.g., put this at the top of the Makefile:
#
#     SHELL = /bin/bash -o pipefail
#     ...
#     test-local:
#       set -o pipefail
#       pytest ... | tee ...
#
#   But then pipefail (and bash) apply to all targets that shell-out.
#
# - A better approach is to use the PIPESTATUS environ.
#
# - Another approach that I didn't care to test — I like the PIPESTATUS
#   approach — but that might work would be to combine the operation in-
#   to one command, e.g.,
#
#     SHELL = /bin/bash
#     ...
#     test-local:
#       set -o pipefail; \
#       pytest ... | tee ...
#
#   But, as mentioned above, then we're applying Bash to all shell-outs,
#   and this author would prefer POSIX-compatible shell code when possible.
test-local: depends-active-venv
	pytest $(TEST_ARGS) tests/ | tee .make.out
	# Express the exit code of pytest, not the tee.
	exit ${PIPESTATUS[0]}
.PHONY: test-local

# ALTLY: Use `TEST_ARGS=-x make test`
test-one: depends-active-venv
	pytest $(TEST_ARGS) -x tests/
.PHONY: test-one

quickfix:
	# Convert partial paths to full paths, for Vim quickfix.
	sed -r "s#^([^ ]+:[0-9]+:)#$(shell pwd)/\1#" -i .make.out
	# Convert double-colons in messages (not file:line:s) -- at least
	# those we can identify -- to avoid quickfix errorformat hits.
	sed -r "s#^(.* .*):([0-9]+):#\1∷\2:#" -i .make.out
.PHONY: quickfix

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

coverage: depends-active-venv
	coverage run -m pytest $(TEST_ARGS) tests
	coverage report
.PHONY: coverage

coverage-to-html:
	coverage html
.PHONY: coverage-html

coverage-html: coverage coverage-to-html view-coverage
.PHONY: coverage-html

view-coverage:
	$(PYBROWSER) htmlcov/index.html
.PHONY: view-coverage

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

clean-docs:
	$(MAKE) -C docs clean BUILDDIR=$(DOCS_BUILDDIR)
	/bin/rm -f docs/$(PACKAGE_NAME).*rst
	/bin/rm -f docs/modules.rst
.PHONY: clean-docs

docs: docs-html
	$(PYBROWSER) docs/$(DOCS_BUILDDIR)/html/index.html
.PHONY: docs

# Docstrings ref:
#   https://www.python.org/dev/peps/pep-0257/
# (lb): We auto-generate docs/modules.rst and docs/<package_name>.rst
# so that :ref:`genindex` and :ref:`modindex`, etc., work, but we might
# instead maintain a separate docs/<project-name>.rst, so that we can
# include special method docs, such as those for and __new__ methods.
# - I tried to disable the generation of modules.rst and easy_as_pypi.rst
#   using options in conf.py, but failed. And I thought maybe one could
#   comment-off 'sphinx.ext.autodoc' to stop them, but no. It's all in the
#   command.
#   - Use -T to disable modules.rst creation, e.g.,
#           sphinx-apidoc -T -o docs/ easy_as_pypi
#   - Use appended exclude patterns to include command docs, e.g.,
#           sphinx-apidoc -T -o docs/ easy_as_pypi easy_as_pypi/commands/
#     will stop docs/easy_as_pypi.commands.rst.
#   - To not generate docs/easy_as_pypi.rst, just don't call sphinx-apidoc!
#     That is, neither of these calls that use exclude patterns will work:
#           sphinx-apidoc -T -o docs/ easy_as_pypi easy_as_pypi/
#           sphinx-apidoc -T -o docs/ easy_as_pypi easy_as_pypi/__init__.py
docs-html: depends-active-venv clean-docs
	sphinx-apidoc --force -o docs/ $(PACKAGE_NAME)
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
.PHONY: docs-html

servedocs: docs
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .
.PHONY: servedocs

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Depends: The following code tested against cloc v1.81.
# - See `depends-cloc` below for verifying cloc version.

CLOC := $(shell command -v cloc 2> /dev/null)
.PHONY: CLOC

# ***

cloc: cloc-digest
.PHONY: cloc

# ***

define CLOC_IGNORE_FILES
docs/conf.py
endef
export CLOC_IGNORE_FILES

cloc-digest: depends-cloc
	@cloc \
		--exclude-dir=sphinx_rtd_theme \
		$$(git ls-files | grep -v -x -F "$${CLOC_IGNORE_FILES}")
.PHONY: cloc-digest

cloc-complete: depends-cloc
	@cloc \
		--by-file \
		--exclude-dir=sphinx_rtd_theme \
		$$(git ls-files | grep -v -x -F "$${CLOC_IGNORE_FILES}")
.PHONY: cloc-complete

# ***

cloc-sources:
	@echo "\n  *** Source files under $(SOURCE_DIR)/:\n"
	@cloc --by-file "$(SOURCE_DIR)"
	@echo "\n  *** Pytest files under tests/:\n"
	@cloc --by-file "tests"
.PHONY: cloc-sources

# ***

# Show results for each file, like `cloc --by-file`, except cloc doesn't
# sort the results. So use SQL pipeline to sort it ourselves, then feed
# the results back to cloc's sqlite_formatter to pretty-print.
cloc-file-sort: depends-cloc
	@( \
		( \
			cloc \
				--sql 1 \
				--exclude-dir="sphinx_rtd_theme" \
				$$(git ls-files); \
			echo ".header on"; \
			echo "select \
							File, \
							nBlank   as '    blank', \
							nComment as '  comment', \
							nCode    as '     code' \
						from t \
						order by File"; \
		) \
		| sqlite3; \
		echo "|         |         |         "; \
	) | "$$(dirname "$$(realpath "$$(which cloc)")")"/sqlite_formatter
.PHONY: cloc-file-sort

# ***

depends-cloc:
ifndef CLOC
	$(error "ERROR: Please install `cloc` from: https://github.com/AlDanial/cloc")
endif
	@if ! echo "$$(cloc --version)" | grep -q "^[1]\."; then \
		echo; \
		echo "ALERT: Unsupported cloc version?: $$(cloc --version) (or update Makefile)"; \
		echo; \
	fi
.PHONY: depends-cloc

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

whoami:
	@echo $(PACKAGE_NAME)
.PHONY: whoami

