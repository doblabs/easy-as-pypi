# vim:tw=0:ts=2:sw=2:noet:ft=make:

# This file exists within 'easy-as-pypi':
#
#   https://github.com/landonb/easy-as-pypi#🥧

PROJNAME = easy_as_pypi

BUILDDIR = _build

# DEV: Set BROWSER environ to pick your browser, otherwise webbrowser ignores
# the system default and goes through its list, which starts with 'mozilla'.
# E.g.,
#
#   BROWSER=chromium-browser make view-coverage
#
# Alternatively, one could be less distro-friendly and leverage sensible-utils, e.g.,
#
#   PYBROWSER := sensible-browser
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
# NOTE: Cannot name BROWSER, else overrides environ of same name.
PYBROWSER := python -c "$$BROWSER_PYSCRIPT"

# YOU/DEV: If you want to define your own tasks, add your own Makefile.
# You could e.g., define a help task extension thusly:
#
#   $ echo -e "help-local::\n\t@echo 'More help!'" > Makefile.local

-include Makefile.local

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
	@echo "   clean-pyc       remove Python file artifacts"
	@echo "   clean-test      remove test and coverage artifacts"
	@echo "   cloc            \"count lines of code\""
	@echo "   coverage        check code coverage quickly with the default Python"
	@echo "   coverage-html   generate HTML coverage reference for every source file"
	@echo "   docs            generate Sphinx HTML documentation, including API docs"
	@echo "   isort           run isort; sorts and groups imports in every module"
	@echo "   lint            check style with flake8"
	@echo "   test            run tests quickly with the default Python"
	@echo "   test-all        run tests on every Python version with tox"
	@echo "   test-one        run tests until the first one fails"
	@echo "   view-coverage   open coverage docs in new tab (set BROWSER to specify app)"
.PHONY: help-main

venvforce:
	@if [ -z "${VIRTUAL_ENV}" ]; then \
		>&2 echo "ERROR: Run from a virtualenv!"; \
		exit 1; \
	fi
.PHONY: venvforce

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

develop: venvforce
	pip install -U pip setuptools wheel
	pip install -U -r requirements/dev.pip
	pip install -U -e .
.PHONY: develop

lint: venvforce
	flake8 setup.py $(PROJNAME)/ tests/
	doc8
.PHONY: lint

test: venvforce
	py.test $(TEST_ARGS) tests/
.PHONY: test

test-all: venvforce
	tox
.PHONY: test-all

test-debug: test-local quickfix
.PHONY: test-debug

test-local: venvforce

	# (lb) The pipe to tee, `| tee`, masks the return code from py.test. I.e., on its own,
	# `py.test | tee` will always return true (0), regardless of py.test's exit code. As
	# such, don't run this task from Travis CI. Or, if you do, change shells and set pipefail.
	# E.g., at the top of the file, include:

	# If you want Make to fail if py.test fails, you want pipefail.
	# Put this at the top of the Makefile:
	#     SHELL = /bin/bash -o pipefail
	# or don't call tasks that pipe from Travis CI (avoid false positives).
	#
	# EXPLAIN/2020-01-24: The previous comment does not jive with the next one-
	#                     I'm wondering if that's why I added the exit $PIPESTATUS.
	#
	# (lb): I tried using pipefail to catch failure, but it didn't trip. E.g.,:
	#           SHELL = /bin/bash
	#           ...
	#           test-local:
	#             set -o pipefail
	#             py.test ... | tee ...
	#       Alternatively, we can access the special PIPESTATUS environ instead.
	py.test $(TEST_ARGS) tests/ | tee .make.out
	# Express the exit code of py.test, not the tee.
	exit ${PIPESTATUS[0]}
.PHONY: test-local

test-one: venvforce
	# You can also obviously: TEST_ARGS=-x make test
	# See also, e.g.,:
	#   py.test --pdb -vv -k test_function tests/
	py.test $(TEST_ARGS) -x tests/
.PHONY: test-one

quickfix:
	# Convert partial paths to full paths, for Vim quickfix.
	sed -r "s#^([^ ]+:[0-9]+:)#$(shell pwd)/\1#" -i .make.out
	# Convert double-colons in messages (not file:line:s) -- at least
	# those we can identify -- to avoid quickfix errorformat hits.
	sed -r "s#^(.* .*):([0-9]+):#\1∷\2:#" -i .make.out
.PHONY: quickfix

coverage: venvforce
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

clean-docs:
	$(MAKE) -C docs clean BUILDDIR=$(BUILDDIR)
	/bin/rm -f docs/$(PROJNAME).*rst
	/bin/rm -f docs/modules.rst
.PHONY: clean-docs

docs: docs-html
	$(PYBROWSER) docs/_build/html/index.html
.PHONY: docs

docs-html: venvforce clean-docs
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
	sphinx-apidoc --force -o docs/ $(PROJNAME)
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
.PHONY: docs-html

isort: venvforce
	isort --recursive setup.py $(PROJNAME)/ tests/
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

servedocs: docs
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .
.PHONY: servedocs

release: venvforce clean
	python setup.py sdist bdist_wheel
	twine upload -r pypi -s dist/*
.PHONY: release

dist: venvforce clean
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist
.PHONY: dist

install: venvforce clean
	python setup.py install
.PHONY: install

whoami:
	@echo $(PROJNAME)
.PHONY: whoami

CLOC := $(shell command -v cloc 2> /dev/null)
.PHONY: CLOC

cloc:
ifndef CLOC
	$(error "Please install cloc from: https://github.com/AlDanial/cloc")
endif
	@cloc --exclude-dir=build,dist,docs,$(PROJNAME).egg-info,.eggs,.git,htmlcov,.pytest_cache,.tox .
.PHONY: cloc

