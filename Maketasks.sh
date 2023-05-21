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

  _venv_install_pip_setuptools_poetry_and_poetry_dynamic_versioning_plugin

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

# - Note that `sphinx-apidoc` generates two files, docs/modules.rst and
#   docs/<package_name>.rst, the latter of which lists all the Submodule
#   names and the top-level package, and specifies `automodule` directives.
#   - You can edit the `automodule` directives in the generated reST before
#     generating the HTML to tweak different options.
#   - But to keep `sphinx-apidoc` a part of CI, you'd want to automate this:
#     - Call sphinx-apidoc, edit the reST, and then generate the HTML.
#     The example below shows how to do this.
#     - You could copy and customize the example, using a project-specific
#       "Maketasks.local.sh" file (MAKETASKS_LOCAL_SH).
#   - And I checked: It does not seem possible to specify those directives
#     otherwise, at least not docs/conf.py or any `sphinx-apidoc` options.

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
    _venv_install_pip_setuptools_poetry_and_poetry_dynamic_versioning_plugin

    poetry -C ${EDITABLE_DIR} install --with docs
  fi

  local module_name="$(echo ${PACKAGE_NAME} | sed 's/-/_/g')"

  sphinx-apidoc --force -o docs/ ${SOURCE_DIR}
  sphinx_docs_inject "${module_name}"
  make_docs_html_make_docs "${PACKAGE_NAME}" "${MAKE}"
}

make_docs_html_make_docs () {
  local PACKAGE_NAME="$1"
  local MAKE="$2"

  PROJNAME=${PACKAGE_NAME} ${MAKE} -C docs clean
  PROJNAME=${PACKAGE_NAME} ${MAKE} -C docs html
}

# USAGE: Copy `sphinx_docs_inject` to "Maketasks.local.sh" file
#        (MAKETASKS_LOCAL_SH) and customize for your project.
#
# - This example only adds two options to the final package `automodule`,
#   but you could easily craft a `sed` or `awk` script to craft a more
#   interesting injection.
#
# - To see what changes in the generated HTML when you inject changes,
#   you could generate two sets of docs, e.g.,
#
#     $ make docs
#     $ mv docs/_build docs/_build_cmp
#     $ sensible-open docs/_build_cmp/html/index.html
#
#     # Skip `sphinx_docs_inject` and open index.html.
#     $ make _docs_raw

# Example injector.
sphinx_docs_inject () {
  local module_name="$1"

cat << EOF >> docs/${module_name}.rst
   :special-members: __new__
   :noindex:
EOF
}

# For the easy-as-pypi reference project, not injecting.
# - Linting: Yes, this replaces the previous definition.
sphinx_docs_inject () {
  :
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

gvim_load_quickfix () {
  local quickfix_file="$1"

  local servername=""

  if [ -n "${GVIM_OPEN_SERVERNAME}" ] || [ -z "${GVIM_OPEN_SERVERNAME+x}" ]; then
    servername="--servername ${GVIM_OPEN_SERVERNAME:-SAMPI}"
  fi

  if [ -s "${quickfix_file}" ]; then
    gvim ${servername} \
      --remote-send "<ESC>:set errorformat=%f\ %l:%m<CR>" \
    && gvim ${servername} \
      --remote-send "<ESC>:cgetfile $(pwd)/${quickfix_file}<CR>"
  else
    command rm "${quickfix_file}"
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

_venv_install_pip_setuptools_poetry_and_poetry_dynamic_versioning_plugin () {
  pip install -U pip setuptools
  pip install poetry
  poetry self add "poetry-dynamic-versioning[plugin]"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

