# vim:tw=0:ts=2:sw=2:noet:ft=make:
# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/pydob/ <varies>
# Pattern: https://github.com/pydob/easy-as-pypi#🥧
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

PACKAGE_NAME = easy-as-pypi

SOURCE_DIR = easy_as_pypi

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Path to package and dependency source code clones, necessary if
# you want to run `make develop` to setup an editable virtualenv.
EDITABLES_ROOT ?= $(shell echo ~/.kit/py)

# Local dir wherein to place editable pyproject.toml,
#   e.g., `.editable/pyproject.toml`.
EDITABLE_DIR ?= .editable

# Local "editable" virtualenv directory (`make develop`).
VENV_NAME ?= .venv-$(PACKAGE_NAME)

# The "editable" virtualenv Python version (`make develop`).
# - USYNC: Keep current with tox.ini's `basepython`.
VENV_PYVER ?= 3.11

# Additional `python -m venv` options.
#
# - You most likely won't need this except for special cases, e.g.,
#   if you installed GnuCash and want access to its bindings, you
#   may need to fallback on system site-packages to find `gnucash`.
#
#     VENV_ARGS = --system-site-packages
VENV_ARGS =

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
	@echo "   build           create sdist and bdist (under ./dist/)"
	@echo "                     sdist is sources dist (tar-gzip)"
	@echo "                     bdist is \"built dist\", aka wheel (zip)"
	@echo "   develop         install package and \"our\" deps in editable mode"
	@echo "                     uses local virtualenv VENV_NAME [./$(VENV_NAME)]"
	@echo "                     \`cd $$(pwd) && workon\` to activate"
	@echo "   install         install app to \"global\" virtualenv"
	@echo "                     uses virtualenv root WORKON_HOME [$${WORKON_HOME:-$${HOME}/.virtualenvs}]"
	@echo "                     \`workon $(PACKAGE_NAME)\` to activate (from anywhere)"
	@echo "   publish         package and upload release (bdist) to PyPI"
	@echo "   dist-list       show sdist and bdist contents (from \`build\` target)"
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
	@echo "   docs-live       watches and regenerates docs as they're edited"
	@echo "   editable        create custom pyproject.toml for \`develop\` command"
	@echo "                     saves under local EDITABLE_DIR dir [./$(EDITABLE_DIR)/]"
	@echo "   editables       run \`editable\` command on all of \"our\" local projects"
	@echo "                     see \`print-ours\` for list of \"our\" projects"
	@echo "   help            print this message"
	@echo "   isort           sort and group module imports using \`isort\`"
	@echo "   lint            automatically make style fixes with \`flake8\`"
	@echo "   print-ours      print list of \"our\" projects — those we control"
	@echo "                     and those \`develop\` will make editable if found"
	@echo "   test            run pytest against active virtualenv or Python"
	@echo "   test-all        run tox (pytest all supported Python versions)"
	@echo "   test-debug      prepare pytest results for Vim quickfix"
	@echo "   test-one        run pytest until first test fails"
	@echo "   view-coverage   open coverage docs in browser (using BROWSER browser)"
	@echo "   whoami          print project package name [$(PACKAGE_NAME)]"
.PHONY: help-main

# Not documented (internal):
#           coverage-to-html  converts completed coverage run results to HTML
#           depends-active-venv  fails make command unless virtualenv active
#           depends-cloc    fails make command unless \`cloc\` installed
#           docs-html       called by \`docs\` to generate HTML docs
#           quickfix        called by \`test-debug\` to prepare .make.out for Vim quickfix
#           test-local      called by \`test-debug\` to generate .make.out from pytest
#           warn-unless-virtualenvwrapper  prints message if virtualenvwrapper not wired
#           CLOC            set to \`cloc \` if cloc installed
#           WORKON          set to \`workon \` if workon (virtualenvwrapper) installed

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

clean: clean-build clean-pyc clean-test
.PHONY: clean

clean-build:
	/bin/rm -rf dist/
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

build: depends-active-venv clean-build
	poetry build
	ls -l dist
	@echo 'HINT: Run `make dist-list` to bdist and sdist contents.'
.PHONY: build

dist: build
.PHONY: dist

# USAGE: Run `make build && make dist-list` to ensure that the
# pyproject.toml 'include' and 'exclude' rules work as expected.

dist-list:
	@echo
	@printf "$$ "
	tar -tvzf dist/*.tar.gz
	@echo
	@printf "$$ "
	unzip -l dist/*.whl
.PHONY: dist-list

# ***

publish: depends-active-venv clean-build
	poetry publish
.PHONY: publish

release: publish
.PHONY: release

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# USAGE: Run `make install` to create a "global" virtualenv.
#
# - A "global" virtualenv installs to WORKON_HOME (~/.virtualenvs by
#   default) as inspired by virtualenvwrapper.
#
#   - But note we call `python -m venv` directly and don't bother
#     with virtualenvwrapper's `mkvirtualenv` command.
#
# CXREF: https://github.com/landonb/virtualenvwrapper (our fork)
#   https://github.com/python-virtualenvwrapper/virtualenvwrapper (original)

# USEIT: The author only uses a subset of virtualenvwrapper commands:
#
# - The `workon` command lets you start a virtualenv easily from any
#   directory, e.g.,
#
#     $ workon <project-name>
#
#   It also supports tab completion.
#
# - The `cdproject` command changes to the project directory.
#
# - The `cdsitepackages` command changes to the current environment's
#   site-packages/ directory.
#
#   This is especially useful if you're digging into a package issue,
#   or if you want to edit a dependency's sources (the author sometimes
#   sets a breakpoint in a package dependency to help diagnose an issue
#   or to learn more about the code).

# SAVVY: Note that you *could* install to system Python using
# Poetry directly (there's no make task to do so), e.g.,
#
#   $ deactivate
#   $ poetry install
#
# But you likely want to isolate the environment, because there's no
# way we can guarantee that our dependencies match whatever else you
# might have installed to the system Python. Hence the somewhat
# opinionated virtualenv installation choices — you should use a
# virtualenv, and we're just providing the framework we like to use.

# SAVVY: There's no target for deleting and recreating the virtualenv.
# - You could call virtualenvwrapper's `rmvirtualenv <project-name>`,
#   or just remove it directly.
# MAYBE/2023-05-16: Make a cleanup-venv task?

# IGNOR: If you run make-install again, pip-install-poetry downgrades libs:
#
#   ERROR: pip's dependency resolver does not currently take into account
#     all the packages that are installed. This behaviour is the source of
#     the following dependency conflicts.
#   click-hotoffthehamster 0.0.1 requires platformdirs<4.0.0,>=3.5.0, but you have platformdirs 2.6.2 which is incompatible.
#   click-hotoffthehamster 0.0.1 requires virtualenv<21.0.0,>=20.23.0, but you have virtualenv 20.21.1 which is incompatible.
#   tox 4.5.1 requires platformdirs>=3.2, but you have platformdirs 2.6.2 which is incompatible.
#
# But then the subsequent poetry-install restores them:
#
#   Package operations: 0 installs, 4 updates, 0 removals
#
#     • Updating packaging (21.3 -> 23.1)
#     • Updating filelock (3.8.0 -> 3.12.0)
#     • Updating platformdirs (2.5.2 -> 3.5.1)
#     • Updating virtualenv (20.16.5 -> 20.23.0)
#
# - So just don't worry about it (if you see that ERROR and corresponding red text).

# INERT/2023-05-16: This used to `clean`, but I don't see any reason.
#   install: warn-unless-virtualenvwrapper clean
#     ...

install: warn-unless-virtualenvwrapper
	eval "$$($$(which pyenv) init -)"; \
	pyenv shell --unset; \
	\
	project_dir="$$(pwd)"; \
	workon_home="$${WORKON_HOME:-$${HOME}/.virtualenvs}"; \
	mkdir -p "$${workon_home}"; \
	cd "$${workon_home}"; \
	if [ ! -d "$(PACKAGE_NAME)" ]; then \
		python3 -m venv $(VENV_ARGS) "$(PACKAGE_NAME)"; \
		echo "$${project_dir}" > "$(PACKAGE_NAME)/.project"; \
	fi; \
	. "$(PACKAGE_NAME)/bin/activate"; \
	cd "$${project_dir}"; \
	\
	echo; \
	echo "pip install -U pip setuptools"; \
	pip install -U pip setuptools; \
	\
	echo; \
	echo "pip install poetry"; \
	pip install poetry; \
	\
	echo; \
	echo "poetry self add 'poetry-dynamic-versioning[plugin]'"; \
	poetry self add "poetry-dynamic-versioning[plugin]"; \
	\
	echo; \
	echo "poetry install"; \
	poetry install; \
	\
	echo; \
	echo "Ready to rock:"; \
	echo "  . $${workon_home}/bin/activate"; \
	echo "Or if using virtualenvwrapper:"; \
	echo "  workon $(PACKAGE_NAME)";
.PHONY: install

# ***

# SAVVY: virtualenvwrapper.sh defines VIRTUALENVWRAPPER_HOOK_DIR, and
#        virtualenvwrapper_lazy.sh defines _VIRTUALENVWRAPPER_API.
warn-unless-virtualenvwrapper:
	@if [ -z "$${_VIRTUALENVWRAPPER_API}" ] && [ -z "$${VIRTUALENVWRAPPER_HOOK_DIR}" ]; then \
		echo "ALERT: Please install workon from: https://github.com/landonb/virtualenvwrapper"; \
		echo; \
	fi;
.PHONY: warn-unless-virtualenvwrapper

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

depends-active-venv:
	@if [ -z "${VIRTUAL_ENV}" ]; then \
		>&2 echo "ERROR: Run from a virtualenv!"; \
		\
		exit 1; \
	fi
.PHONY: depends-active-venv

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# USAGE: Run `make develop` to wire venv for active, "editable" development
#        (so you don't have to always `poetry install` after making changes).
#
# - Caveat: You need to clone dependencies to the same directory
#           and tell make where to find it, e.g.,
#
#             EDITABLES_ROOT=~/.kit/py make develop

develop: editables editable
	eval "$$(~/.local/bin/pyenv init -)"; \
	pyenv install -s $(VENV_PYVER); \
	pyenv shell $(VENV_PYVER); \
	if [ ! -d "$(VENV_NAME)" ]; then \
		python3 -m venv $(VENV_ARGS) "$(VENV_NAME)"; \
	fi; \
	. "$(VENV_NAME)/bin/activate"; \
	pip install -U pip setuptools; \
	pip install poetry; \
	poetry self add "poetry-dynamic-versioning[plugin]"; \
	poetry -C $(EDITABLE_DIR) install --with dist,lint,test,docstyle,docs,extras; \

	@echo
	@echo "$(VENV_NAME) is ready — if \`workon\` is installed, run that"
.PHONY: develop

# ***

# SYNC_ME: List of "our" related projects to make --editable.
# - These projects are all managed by tallybark (hence "our")
#   and will each be installed in editable mode (akin to the
#   `pip install -e <path/to/proj>` command, but using Poetry).
EDITABLE_PJS = \
	dob \
	birdseye \
	\
	ansi-escape-room \
	click-hotoffthehamster \
	click-hotoffthehamster-alias \
	config-decorator \
	easy-as-pypi-appdirs \
	easy-as-pypi-config \
	easy-as-pypi-getver \
	easy-as-pypi-termio \
	human-friendly_pedantic-timedelta \
	pep440-version-compare-cli \
	sqlalchemy-migrate-hotoffthehamster \
	\
	dob-bright \
	dob-prompt \
	dob-viewer \
	nark \
	\
	dob-plugin-git-hip \
	dob-plugin-hamster-dance \
	dob-plugin-my-post-processor \
	dob-plugin-stale-fact-goader \

# ***

# USAGE: Run `EDITABLES_ROOT=<path> make editable` to create dev-friendly
# `.editable/pyproject.toml` that'll install the project in editable mode.
#
# - E.g., after you've cloned EDITABLE_PJS projects to ~/.kit/py, run:
#
#     EDITABLES_ROOT=~/.kit/py make editable
#
# to create `.editable/pyproject.toml` with the correct local paths.
#
# - You wouldn't normally run this task: `make develop` runs it.
#
#   - But it would be useful to run on its own if you're diagnosing
#     a poetry-install failure.

# USEIT: If you are using our virtualenvwrapper fork, you can activate
# the editable virtualenv easily:
#
#   $ cd <path-to-project>
#   $ workon
#
# - If not, just do it the old-fashioned way:
#
#   $ . <venv-name>/bin/activate

# - Note we use quoted [ -d ] test [ -d "$${pyprojs_full}/$${project}" ]
#   to support space characters in path name, but the shell won't expand
#   a *quoted* tilde '~', so we do that ourselves.
#   - But because not Bash, we cannot use variable pattern substitution:
#       "$${pyprojs_root/#\~/$$HOME}"
#     So we use `sed` instead, but we use '@' delimiters and not normal '/',
#     because path contains '/' (so then path now cannot contain @ symbol).

# - If a project is not found locally, an ALERT is printed, but you don't
#   need to care unless you want to hack on that project, too. E.g., if
#   you only care that the main project is editable, say, Birdseye, just
#   clone that repo locally and don't worry about the dependency repos.
#   - Otherwise, clone 'em all, though maybe consider `myrepos` or a similar
#     multiple repository tool to ease the burden of fetching and maintaining
#     them all.

# - The second sed simply strips the trailing '|' the for-loop might leave.

# - The third sed adds "../" prefixes to the new .editable/pyproject.toml,
#   so it references the README.rst and pacakge from its parent directory.
#
#   - Note the sed expects a specific pyproject format:
#
#     - The README is easy, just keep the line like this:
#
#         readme = "README.rst"
#
#       and it'll be transformed to:
#
#         readme = "../README.rst"
#
#     - The packages list is trickier.
#
#       - An old-school setup, foregoing a src/ directory, might look like this:
#
#           packages = [{include = "easy_as_pypi"}]
#
#         which will be transformed to:
#
#           packages = [{include = "../easy_as_pypi"}]
#
#       - A setup using the conventional src/ directory could look like this:
#
#           packages = [{include = "easy_as_pypi", from = "src"}]
#
#         which is transformed to:
#
#           packages = [{include = "easy_as_pypi", from = "../src"}]
#
#         But note that Poetry looks for a src/<package> dir by default, so
#         you may be able to omit the 'packages' setting in your project TOML.
#
#         - The ../SOURCE_DIR symlink (possibly src -> ../src) will steer
#           Poetry to the correct location.

editable:
	@mkdir -p $(EDITABLE_DIR)
	@#
	@echo \
		"# This file is automatically @generated by Makefile and should not be changed by hand.\n" \
		> $(EDITABLE_DIR)/pyproject.toml
	@#
	@concat_pjs=""; \
	pyprojs_full="$$(echo "$(EDITABLES_ROOT)" | sed "s@~@$${HOME}@")"; \
	for project in $(EDITABLE_PJS); do \
		if [ -d "$${pyprojs_full}/$${project}" ]; then \
			concat_pjs="$${concat_pjs}$${project}|"; \
		else \
			echo "ALERT: Missing project: $${pyprojs_full}/$${project}"; \
		fi; \
	done; \
	concat_pjs="$$(echo "$${concat_pjs}" | sed 's@|$$@@')" ; \
	sed -E \
		-e 's#^(packages = \[\{include = ")([^"]*"}])#\1../\2#' \
		-e 's#^(packages = \[\{include = "[^"]*", from = ")#\1../#' \
		-e 's#^(readme = ")#\1../#' \
		pyproject.toml \
	| awk \
			-v pyprojs_root="$(EDITABLES_ROOT)" \
			' \
				match($$0, /^('$${concat_pjs}')( |$$)/, matches) { \
					print matches[1] " = {path = \"" pyprojs_root "/" matches[1] "/$(EDITABLE_DIR)\", develop = true}"; \
					next; \
				} 1 \
			' - \
		>> $(EDITABLE_DIR)/pyproject.toml;
	@#
	@editable_link="$(EDITABLE_DIR)/$(SOURCE_DIR)"; \
	[ -h "$${editable_link}" ] && command rm "$${editable_link}"; \
	command ln -s "../$(SOURCE_DIR)" "$${editable_link}";
.PHONY: editable

# USAGE: Call `make editables` to call `make editable` on each of "our"
# projects (EDITABLE_PJS), which creates all dependencies' ".editable/"
# dirs. and the assets therein (currently just a symlink to source dir).
#
# - This is called by `make develop` to prep all the dependencies, but
#   you can also call it yourself, e.g.,
#
#     EDITABLES_ROOT=~/.kit/py make editables
editables:
	@for project in $(EDITABLE_PJS); do \
		make editable -C "$(EDITABLES_ROOT)/$${project}"; \
		echo; \
	done
.PHONY: editables

print-ours:
	@for project in $(EDITABLE_PJS); do \
		echo "$${project}"; \
	done
.PHONY: print-ours

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

lint: depends-active-venv
	flake8 $(SOURCE_DIR)/ tests/
	doc8
.PHONY: lint

isort: depends-active-venv
	isort $(SOURCE_DIR)/ tests/
	@# DX: End files with blank line.
	@git ls-files -- :/$(SOURCE_DIR)/ :/tests/ | while read file; do \
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
	/bin/rm -f docs/$(SOURCE_DIR).*rst
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
# - I tried to disable the generation of modules.rst and $(SOURCE_DIR).rst
#   using options in conf.py, but failed. And I thought maybe one could
#   comment-off 'sphinx.ext.autodoc' to stop them, but no. It's all in the
#   command.
#   - Use -T to disable modules.rst creation, e.g.,
#       sphinx-apidoc -T -o docs/ $(SOURCE_DIR)
#   - Use appended exclude patterns to include command docs, e.g.,
#       sphinx-apidoc -T -o docs/ $(SOURCE_DIR) $(SOURCE_DIR)/commands/
#     will stop docs/$(SOURCE_DIR).commands.rst.
#   - To not generate docs/$(SOURCE_DIR).rst, just don't call sphinx-apidoc!
#     That is, neither of these calls that use exclude patterns will work:
#       sphinx-apidoc -T -o docs/ $(SOURCE_DIR) $(SOURCE_DIR)/
#       sphinx-apidoc -T -o docs/ $(SOURCE_DIR) $(SOURCE_DIR)/__init__.py
docs-html: depends-active-venv clean-docs
	sphinx-apidoc --force -o docs/ $(SOURCE_DIR)
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
.PHONY: docs-html

docs-live: docs
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .
.PHONY: docs-live

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

