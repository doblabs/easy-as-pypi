# vim:tw=0:ts=2:sw=2:et:ft=sh
# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/pydob/ <varies>
# Pattern: https://github.com/pydob/easy-as-pypi#🥧
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

make_develop () {
	local VENV_NAME="$1"
	local VENV_PYVER="$2"
	local VENV_ARGS="$3"
	local EDITABLE_DIR="$4"

	_pyenv_prepare_shell "${VENV_PYVER}"

	# local venv_created=false
	_venv_manage_and_activate "${VENV_NAME}" "${VENV_ARGS}" "${VENV_NAME}"

	pip install -U pip setuptools
	pip install poetry
	poetry self add "poetry-dynamic-versioning[plugin]"

	poetry -C ${EDITABLE_DIR} install --with dist,i18n,lint,test,docstyle,docs,extras
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

make_doc8 () {
	local VENV_DOC8="$1"
	local VENV_PYVER="$2"
	local VENV_NAME="$3"

	_pyenv_prepare_shell "${VENV_PYVER}"

	# local venv_created=false
	_venv_manage_and_activate "${VENV_DOC8}" "" "${VENV_NAME}"

	python -c "import doc8" 2> /dev/null \
		|| pip install -U pip doc8>="1.1.1"

	python -m doc8 *.rst docs/
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Docstrings ref:
#   https://www.python.org/dev/peps/pep-0257/
# (lb): We auto-generate docs/modules.rst and docs/<package_name>.rst
# so that :ref:`genindex` and :ref:`modindex`, etc., work, but we might
# instead maintain a separate docs/<project-name>.rst, so that we can
# include special method docs, such as those for and __new__ methods.
# - I tried to disable the generation of modules.rst and ${SOURCE_DIR}.rst
#   using options in conf.py, but failed. And I thought maybe one could
#   comment-off 'sphinx.ext.autodoc' to stop them, but no. It's all in the
#   command.
#   - Use -T to disable modules.rst creation, e.g.,
#       sphinx-apidoc -T -o docs/ ${SOURCE_DIR}
#   - Use appended exclude patterns to include command docs, e.g.,
#       sphinx-apidoc -T -o docs/ ${SOURCE_DIR} ${SOURCE_DIR}/commands/
#     will stop docs/${SOURCE_DIR}.commands.rst.
#   - To not generate docs/${SOURCE_DIR}.rst, just don't call sphinx-apidoc!
#     That is, neither of these calls that use exclude patterns will work:
#       sphinx-apidoc -T -o docs/ ${SOURCE_DIR} ${SOURCE_DIR}/
#       sphinx-apidoc -T -o docs/ ${SOURCE_DIR} ${SOURCE_DIR}/__init__.py

make_docs_html () {
	local VENV_DOCS="$1"
	local VENV_PYVER="$2"
	local VENV_NAME="$3"
	local EDITABLE_DIR="$4"
	local SOURCE_DIR="$5"
	local PACKAGE_NAME="$6"
	local MAKE="$7"

	_pyenv_prepare_shell "${VENV_PYVER}"

	local venv_created=false
	_venv_manage_and_activate "${VENV_DOCS}" "" "${VENV_NAME}"

	if ${venv_created} || ${VENV_FORCE:-false} ; then
		pip install -U pip setuptools
		pip install poetry
		poetry self add "poetry-dynamic-versioning[plugin]"

		poetry -C ${EDITABLE_DIR} install --with docs
	fi

	sphinx-apidoc --force -o docs/ ${SOURCE_DIR}
	PROJNAME=${PACKAGE_NAME} ${MAKE} -C docs clean
	PROJNAME=${PACKAGE_NAME} ${MAKE} -C docs html
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# - Note that 'SAMPI' is the default GVim server name
#   used by Depoxy: https://github.com/depoxy/depoxy
#   which the author uses to setup and orchestrate
#   their development machines.
#   - Personalize GVIM_OPEN_SERVERNAME as necessary for yours.

gvim_load_quickfix () {
	local quickfix_file="$1"

	local servername=""

	if [ -n "${GVIM_OPEN_SERVERNAME}" ] || [ -z "${GVIM_OPEN_SERVERNAME+x}" ]; then
		servername="--servername ${GVIM_OPEN_SERVERNAME:-SAMPI}"
	fi

	if [ -s "${gvim_load_quickfix}" ]; then
		gvim ${servername} \
			--remote-send "<ESC>:set errorformat=%f\ %l:%m<CR>" \
		&& gvim ${servername} \
			--remote-send "<ESC>:cgetfile $(pwd)/${gvim_load_quickfix}<CR>"
	else
		command rm "${gvim_load_quickfix}"
	fi
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

_pyenv_prepare_shell () {
	local venv_pyver="$1"

	eval "$(~/.local/bin/pyenv init -)"

	pyenv install -s ${venv_pyver}

	pyenv shell ${venv_pyver}
}

_venv_manage_and_activate () {
	local venv_name="$1"
	local venv_args="$3"
	local venv_default="$2"

	if [ ! -d "${venv_name}" ]; then
		python3 -m venv ${venv_args} "${venv_name}"

		venv_created=true

		if [ -d "${venv_default}" ]; then
			# So that bare `workon` picks the `make develop` virtualenv.
			touch "${venv_default}/bin/activate"
		fi
	fi

	. "${venv_name}/bin/activate"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

