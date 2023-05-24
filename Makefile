# vim:tw=0:ts=2:sw=2:noet:ft=make
# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/pydob/ <varies>
# Pattern: https://github.com/pydob/easy-as-pypi#🥧
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Suss the project name from the directory name. Assumes the project
# directory *is* named like the project, e.g., this file might be:
#   /path/to/my-project/Makefile
PACKAGE_NAME ?= $(shell basename "$$(pwd)")

SOURCE_DIR = src

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

# ***

# Task oursourcer.
MAKEFILESH = ./Makefilesh

# ***

# `make doc8` and `make docs` virtualenvs.

VENV_DOC8 ?= .venv-doc8

VENV_DOCS ?= .venv-docs

# ***

# For Vim devs: Quickfix file names

VIM_QUICKFIX_FLAKE8 ?= .vimquickfix.flake8

VIM_QUICKFIX_PYTEST ?= .vimquickfix.pytest

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
#   $ echo -e "_help_local::\n\t@echo 'More help!'" > Makefile.local

-include Makefile.local

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

help: _help_main _help_local
.PHONY: help

_help_local::
.PHONY: _help_local

_help_main:
	@echo "Please choose a target for make:"
	@echo
	@echo " Installing and Packaging"
	@echo " ------------------------"
	@echo "   build           create sdist and bdist (under ./dist/)"
	@echo "                     sdist is sources dist (tar-gzip)"
	@echo "                     bdist is \"built dist\" (wheel zip)"
	@echo "   develop         install package and \"our\" deps in editable mode"
	@echo "                     uses local virtualenv VENV_NAME [./$(VENV_NAME)]"
	@echo "                     \`cd $$(pwd) && workon\` to activate"
	@echo "   install         install app to \"global\" virtualenv"
	@echo "                     uses virtualenv root WORKON_HOME [$${WORKON_HOME:-$${HOME}/.virtualenvs}]"
	@echo "                     \`workon $(PACKAGE_NAME)\` to activate from anywhere"
	@echo "   publish         package and upload release (bdist) to PyPI"
	@echo "   dist-list       show sdist and bdist contents (from \`build\` target)"
	@echo
	@echo " Developing and Testing"
	@echo " ----------------------"
	@echo "   babel-compile   compile localizations"
	@echo "   babel-extract   extract \`gettext\` _(\"\") strings into messages.pot"
	@echo "   babel-init      create localized language files from messages.pot"
	@echo "   black           lint: run \`black\`"
	@echo "   clean           remove all build, test, coverage and Python artifacts"
	@echo "   clean-build     remove build artifacts (dist/)"
	@echo "   clean-docs      remove RTD build dir (docs/$(DOCS_BUILDDIR)) and generated .rst"
	@echo "   clean-pyc       remove Python bytecode (*.pyc)"
	@echo "   clean-test      remove pytest, tox, and coverage artifacts"
	@echo "   cloc            \"count lines of code\" summary (\`cloc-digest\` alias)"
	@echo "   cloc-complete   print cloc results for each file, sorted by count"
	@echo "   cloc-digest     print cloc project summary"
	@echo "   cloc-file-sort  print cloc results for each file, sorted by path"
	@echo "   cloc-sources    print cloc results for source and tests directories"
	@echo "   coverage        print coverage report after running pytest"
	@echo "   coverage-html   generate line-by-line HTML coverage reports"
	@echo "   dist            'build' alias"
	@echo "   doc8            lint: reST and Sphinx style check"
	@echo "   docs            generate Sphinx HTML documentation, including API docs"
	@echo "   docs-live       watches and regenerates docs as they're edited"
	@echo "   editable        create custom pyproject.toml for \`develop\` command"
	@echo "                     saves under local EDITABLE_DIR dir [./$(EDITABLE_DIR)/]"
	@echo "   editables       run \`editable\` command on all of \"our\" local projects"
	@echo "                     see \`print-ours\` for list of \"our\" projects"
	@echo "   flake8          lint: run \`flake8\` and load errors to Vim quickfix"
	@echo "   help            print this message"
	@echo "   isort           lint: sort and group module imports using \`isort\`"
	@echo "   linkcheck       lint: reST docs HTTP link validation"
	@echo "   lint            lint: runs black, flake8, isort, pydocstyle, doc8,"
	@echo "                     poetry-check, twine-check, and linkcheck"
	@echo "   linty           lint: like 'lint' target but won't stop on failure"
	@echo "   poetry-check    lint: pyproject.toml check"
	@echo "   print-ours      print list of \"our\" projects — those we control"
	@echo "                     and those \`develop\` will make editable if found"
	@echo "   pydocstyle      lint: PEP 257 Docstring conventions"
	@echo "   release         'publish' alias"
	@echo "   test            pytest against active virtualenv or Python"
	@echo "   test-all        pytest all supported Python versions using \`tox\`"
	@echo "   test-debug      prepare pytest results for Vim quickfix"
	@echo "   test-one        run pytest until first test fails"
	@echo "   twine-check     lint: dist check and PyPI validation"
	@echo "   view-coverage   open coverage docs in browser (using BROWSER browser)"
	@echo "   whoami          print project package name [$(PACKAGE_NAME)]"
.PHONY: _help_main

# Not documented (internal): Targets that start with "_" (or "." also works).

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

build: _depends_active_venv clean-build
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

publish: _depends_active_venv clean-build
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
#   install: _warn_unless_virtualenvwrapper clean
#     ...

install: _warn_unless_virtualenvwrapper
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
_warn_unless_virtualenvwrapper:
	@if [ -z "$${_VIRTUALENVWRAPPER_API}" ] && [ -z "$${VIRTUALENVWRAPPER_HOOK_DIR}" ]; then \
		echo "ALERT: Please install workon from: https://github.com/landonb/virtualenvwrapper"; \
		echo; \
	fi;
.PHONY: _warn_unless_virtualenvwrapper

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

_depends_active_venv:
	@if [ -z "${VIRTUAL_ENV}" ]; then \
		>&2 echo "ERROR: Run from a virtualenv!"; \
		\
		exit 1; \
	fi
.PHONY: _depends_active_venv

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# USAGE: Run `make develop` to wire venv for active, "editable" development
#        (so you don't have to always `poetry install` after making changes).
#
# - Caveat: You need to clone dependencies to the same directory
#           and tell make where to find it, e.g.,
#
#             EDITABLES_ROOT=~/.kit/py make develop

develop: editables editable
	@. "$(MAKEFILESH)" && \
		make_develop "$(VENV_NAME)" "$(VENV_PYVER)" "$(VENV_ARGS)" "$(EDITABLE_DIR)"
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

# CXREF/2023-05-18: Nice tutorial:
#
#   https://phrase.com/blog/posts/python-localization/

# TRACK/2023-05-18: *Parse settings from pyproject.toml*
#
#   https://github.com/python-babel/babel/issues/777
#
# - Note that locale/babel.cfg is a *mapping* config file, *not*
#   a config file akin to what Babel supports in the setup.cfg
#   file (used by old setuptools builds).
#
# - Though even if/when Babel adds pyproject.toml support, what
#   would we really put in there? These calls are pretty simple.

babel-extract:
	pybabel extract -F locale/babel.cfg --input-dirs=$(SOURCE_DIR) -o locale/messages.pot
.PHONY: babel-extract

# SAVVY: See list of languages:
#   pybabel --list-locales
babel-init:
	@for lang in en de; do \
		pybabel init -l $${lang} -i locale/messages.pot -d locale/; \
	done
.PHONY: babel-init

babel-compile:
	pybabel compile -d locale/
.PHONY: babel-compile

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# USYNC: The lint target dependency list should match tox.ini's envlist.

# Note that `black` and `flake8` sorta redundant, but by including both,
# we can check that flake8 doesn't counteract black. Also, tox uses
# flake8 but not black.

lint: _depends_active_venv black flake8 isort pydocstyle doc8 poetry-check twine-check linkcheck
.PHONY: lint

# *Make linty!* Call `make linty` to lint and see full lint report.
# - `make lint` will stop of first failed lint task, which is sometimes
#   what you want (to fix the failure), though other times you want the
#   full lint report (see all tasks that failed).
# - The `tox` 'lint' label lets you run all lint tasks, but tox doesn't
#   run `black`, it runs `isort` in no-touchy mode, and its `flake8`
#   won't prepare the quickfix file.
# - So here we present a `make lint` + `tox run -m lint`.

linty: _depends_active_venv black flake8 isort
	tox run -m lint
.PHONY: linty

# ***

black: _depends_active_venv
	@black $(SOURCE_DIR)
.PHONY: black

# ***

# Run flake8, and collect and send errors to Vim quickfix.

# CXREF: See [tool.flake8] `format` option in pyproject.toml.
# - This format should match the sed command pattern, below.
#
# Re: flake8 output:
# - It'd be nice to find something like `tag` for `flake8`
#     https://github.com/aykamko/tag
#   E.g., where `e1` from the shell opens the first lint error in your editor,
#   `e2` opens the second, etc. (While `black` is great, it doesn't fix
#    everything; it would be convenient to open lint errors from the term.)
# - Another option is using Vim quickfix, e.g., from the terminal:
#     flake8 | tee >(sed "s@^./@$(pwd)/@" > .flake8.out)
#   And then within Vim:
#     set errorformat=%f\ %l:%m
#     cgetfile /path/to/project/.flake8.out
#   Which is automated by the gvim_load_quickfix shell-out.

flake8: _depends_active_venv _run_flake8 _gvim_load_quickfix_flake8
.PHONY: flake8

_run_flake8: _depends_active_venv
	@/bin/bash -c "flake8 $(SOURCE_DIR)/ tests/ | tee >(sed -E \"s@^(\./)?@$$(pwd)/@\" > $(VIM_QUICKFIX_FLAKE8))"
.PHONY: _run_flake8

_gvim_load_quickfix_flake8:
	@. "$(MAKEFILESH)" && gvim_load_quickfix "$(VIM_QUICKFIX_FLAKE8)"
.PHONY: _gvim_load_quickfix_flake8

# ***

# If you want additional blather, try --verbose:
#   @isort --verbose $(SOURCE_DIR)/ tests/

isort: _depends_active_venv
	@isort $(SOURCE_DIR)/ tests/
.PHONY: isort

# ISOFF/2023-05-18: In a previous life (because in my current life I
# don't want to fight `black` or have style debates), I'd add a blank
# line to the ends of files. (I like this so that <Ctrl-End> always
# puts the cursor in the first column, just like <Ctrl-Home>.)
# - But black trims blank lines, and there's no option not to, so
#   adding blanks is no longer an option. But here's the code for
#   posterity:
#
# end-files-with-blank-line:
#   @git ls-files -- :/$(SOURCE_DIR)/ :/tests/ | while read file; do \
#     if [ -n "$$(tail -n1 $$file)" ]; then \
#       echo "Blanking: $$file"; \
#       echo >> $$file; \
#     else \
#       echo "DecentOk: $$file"; \
#     fi \
#   done
#   @echo "ça va"
# .PHONY: end-files-with-blank-line

# ***

pydocstyle: _depends_active_venv
	@pydocstyle $(SOURCE_DIR)/ tests/
.PHONY: pydocstyle

# ***

# See comments in pyproject.toml: Latest doc8 and sphinx-rtd-theme conflict,
# because latter requires older docutils.
# - So here we install and run `doc8` in its own virtualenv, outside the
#   purview of Poetry.
# - Essentially, we have to pick one or the other (or neither) package to
#   install in the `make develop` virtualenv; we can't have them both.
#   - Furthermore, because Poetry checks dependencies across groups, we
#     need to omit one or the other (or both) from the pyproject.toml
#     Poetry config, lest Poetry still complain about the conflict
#     (i.e., we cannot use different --with options to poetry-install).
# - For simplicity, we choose to omit doc8 from pyproject.toml.
#   - It's just the one package, whereas sphinx is more than one package.
#     So if we leave the sphinx packages in pyproject.toml, then Poetry
#     will check for dependency conflicts between the sphinx packages.
#   - Also because we `pip install doc8` in the dedicated virtualenv, we
#     know there won't be any conflicts, as it's the only package installed.
# - Alternatively, we could manage another pyproject.toml for doc8,
#   but that's way more overhead and doesn't afford us any gains.

doc8:
	@. "$(MAKEFILESH)" && make_doc8 "$(VENV_DOC8)" "$(VENV_PYVER)" "$(VENV_NAME)"
.PHONY: doc8

# ***

# Verify pyproject.toml.

poetry-check: _depends_active_venv
	poetry check
.PHONY: poetry-check

# For parity with `tox -e poetry_check` (i.e., so most `tox -e <cmd>`
# can also be executed via `make <cmd>`).
poetry_check: poetry-check
.PHONY: poetry_check

# ***

# Verify build artifacts (incl. that README.* will render on PyPI).

# For parity with `tox -e twine_check`.
twine-check: _depends_active_venv clean-build
	poetry build
	twine check dist/*
.PHONY: twine-check

# For parity with `tox -e twine_check`.
twine_check: twine-check
.PHONY: twine_check

# ***

linkcheck: _depends_active_venv
	@make --directory=docs linkcheck
.PHONY: linkcheck

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# *** Collection of pytest runners.

# SAVVY: Consider other useful options we don't expose via this Makefile, e.g.,:
#
#     pytest --pdb -vv -k test_function tests/
#
#                      ^^^^^^^^^^^^^^^^  Test specific function or class
#                  ^^^                   Increase verbosity
#            ^^^^^                       Start pdb on error or KeyboardInterrupt

test: _depends_active_venv
	pytest $(TEST_ARGS) tests/
.PHONY: test

test-all: _depends_active_venv
	tox
.PHONY: test-all

test-debug: _test_local _quickfix
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
#     _test_local:
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
#     _test_local:
#       set -o pipefail; \
#       pytest ... | tee ...
#
#   But, as mentioned above, then we're applying Bash to all shell-outs,
#   and this author would prefer POSIX-compatible shell code when possible.
test-local: _depends_active_venv
	pytest $(TEST_ARGS) tests/ | tee $(VIM_QUICKFIX_PYTEST)
	# Express the exit code of pytest, not the tee.
	exit ${PIPESTATUS[0]}
.PHONY: test-local

# ALTLY: Use `TEST_ARGS=-x make test`
test-one: _depends_active_venv
	pytest $(TEST_ARGS) -x tests/
.PHONY: test-one

_quickfix:
	# Convert partial paths to full paths, for Vim quickfix.
	sed -r "s#^([^ ]+:[0-9]+:)#$(shell pwd)/\1#" -i $(VIM_QUICKFIX_PYTEST)
	# Convert double-colons in messages (not file:line:s) -- at least
	# those we can identify -- to avoid quickfix errorformat hits.
	sed -r "s#^(.* .*):([0-9]+):#\1∷\2:#" -i $(VIM_QUICKFIX_PYTEST)
.PHONY: _quickfix

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Note: `tox -e coverage` is different:
#   pytest --cov=./src tests/

coverage: _depends_active_venv
	coverage run -m pytest $(TEST_ARGS) tests
	coverage report
.PHONY: coverage

_coverage_to_html:
	coverage html
.PHONY: _coverage_to_html

coverage-html: coverage _coverage_to_html view-coverage
.PHONY: coverage-html

view-coverage:
	$(PYBROWSER) htmlcov/index.html
.PHONY: view-coverage

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# As mentioned alongside doc8 target, doc8 conflicts with sphinx-rtd-theme.
# - 2023-05-18: doc8 v1.1.1 depends on recent docutils (>=0.19,<0.21) but
#               sphinx-rtd-theme v1.2.0 requires older docutils (<0.19).
# - So those two packages cannot coexist in the same virtualenv, e.g.,
#   we cannot install them both in the `make develop` virtualenv.
#   - Furthermore, then cannot both be listed in pyproject.toml, because
#     Poetry checks dependencies across groups, regardless of what's being
#     installed.
#   - So we decided to boot doc8 from pyproject.toml, because it has no
#     other dependencies, whereas sphinx-rtd-theme works with Sphinx.
#     - Meaning, Poetry will check that sphinx-rtd-theme and sphinx don't
#       conflict. But there will be no conflicts with doc8 given that it'll
#       be the only package installed in its virtualenv.
# - All that said, we could build docs in the `make develop` virtualenv,
#   but we'll use a dediciated virtualenv like we do for doc8. (It's not
#   bad practice to isolate some tools, either, and this code was a gimme
#   considering we isolated the doc8 task, so we'll just use the same code.)

clean-docs:
	$(MAKE) -C docs clean BUILDDIR=$(DOCS_BUILDDIR)
	/bin/rm -f docs/$(SOURCE_DIR).*rst
	/bin/rm -f docs/modules.rst
.PHONY: clean-docs

docs: _docs_html _docs_browse
.PHONY: docs

_docs_browse:
	$(PYBROWSER) docs/$(DOCS_BUILDDIR)/html/index.html
.PHONY: _docs_browse

_docs_html: clean-docs
	@. "$(MAKEFILESH)" && \
		make_docs_html "$(VENV_DOCS)" "$(VENV_PYVER)" "$(VENV_NAME)" \
			"$(EDITABLE_DIR)" "$(SOURCE_DIR)" "$(PACKAGE_NAME)" "$(MAKE)"
.PHONY: _docs_html

docs-live: docs
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .
.PHONY: docs-live

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Depends: The following code tested against cloc v1.81.
# - See `_depends_cloc` below for verifying cloc version.

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

cloc-digest: _depends_cloc
	@cloc \
		--exclude-dir=sphinx_rtd_theme \
		$$(git ls-files | grep -v -x -F "$${CLOC_IGNORE_FILES}")
.PHONY: cloc-digest

cloc-complete: _depends_cloc
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
cloc-file-sort: _depends_cloc
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

_depends_cloc:
ifndef CLOC
	$(error "ERROR: Please install `cloc` from: https://github.com/AlDanial/cloc")
endif
	@if ! echo "$$(cloc --version)" | grep -q "^[1]\."; then \
		echo; \
		echo "ALERT: Unsupported cloc version?: $$(cloc --version) (or update Makefile)"; \
		echo; \
	fi
.PHONY: _depends_cloc

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

whoami:
	@echo $(PACKAGE_NAME)
.PHONY: whoami

