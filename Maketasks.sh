# vim:tw=0:ts=2:sw=2:et:ft=sh
# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/<varies>
# Pattern: https://github.com/doblabs/easy-as-pypi#🥧
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

make_develop () {
  local VENV_NAME="$1"
  local VENV_PYVER="$2"
  local VENV_ARGS="$3"
  local EDITABLE_DIR="$4"

  _pyenv_prepare_shell "${VENV_PYVER}"

  local VENV_CREATED=false
  _venv_manage_and_activate "${VENV_NAME}" "${VENV_ARGS}" "${VENV_NAME}"

  if ${VENV_CREATED} || ${VENV_FORCE:-false} ; then
    command rm -f ${EDITABLE_DIR}/poetry.lock

    # MAYBE: Also move pip installs herein and skip if VENV_CREATED already?
    #
    #   _venv_install_pip_setuptools_poetry_and_poetry_dynamic_versioning_plugin
  fi

  _venv_install_pip_setuptools_poetry_and_poetry_dynamic_versioning_plugin

  # Don't assume user's pyproject.toml's poetry.group's match ours.
  local install_with="${PO_INSTALL_WITH}"
  if test -z "${install_with}"; then
    # Specific to EAPP's pyproject.toml, and *many* of its followers
    # (but not all).
    install_with="--with dist,i18n,lint,test,docstyle,docs,extras"
  fi

  poetry -C ${EDITABLE_DIR} install ${install_with}
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

make_doc8_pip () {
  local VENV_DOC8="$1"
  local VENV_PYVER="$2"
  local VENV_NAME="$3"

  _pyenv_prepare_shell "${VENV_PYVER}"

  # local VENV_CREATED=false
  _venv_manage_and_activate "${VENV_DOC8}" "" "${VENV_NAME}"

  python -c "import doc8" 2> /dev/null \
    || pip install -U pip doc8>="1.1.1"

  python -m doc8 *.rst docs/
}

# ***

make_doc8_poetry () {
  local PYPROJECT_DOC8_DIR="$1"
  local VENV_PYVER="$2"

  local before_cd="$(pwd -L)"

  # E.g.,
  #   cd ".pyproject-doc8/"
  cd "${PYPROJECT_DOC8_DIR}"

  _pyenv_prepare_shell "${VENV_PYVER}"

  local VENV_DOC8=".venv"

  # local VENV_CREATED=false
  _venv_manage_and_activate "${VENV_DOC8}" "" ""

  _venv_install_pip_setuptools_poetry_and_poetry_dynamic_versioning_plugin

  poetry install --no-interaction --no-root

  cd "${before_cd}"

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
#     - CXREF: See autodoc_default_options and autoclass_content in docs/conf.py.

make_docs_html () {
  local VENV_DOCS="$1"
  local VENV_PYVER="$2"
  local VENV_NAME="$3"
  local EDITABLE_DIR="$4"
  local SOURCE_DIR="$5"
  local PACKAGE_NAME="$6"
  local MAKE="$7"

  _pyenv_prepare_shell "${VENV_PYVER}"

  local VENV_CREATED=false
  _venv_manage_and_activate "${VENV_DOCS}" "" "${VENV_NAME}"

  if ${VENV_CREATED} || ${VENV_FORCE:-false} ; then
    _venv_install_pip_setuptools_poetry_and_poetry_dynamic_versioning_plugin

    poetry -C ${EDITABLE_DIR} install --with docs --extras readthedocs
  fi

  make_docs_html_with_inject "${SOURCE_DIR}" "${PACKAGE_NAME}" "${MAKE}"
}

make_docs_html_with_inject () {
  local SOURCE_DIR="$1"
  local PACKAGE_NAME="$2"
  local MAKE="$3"

  local module_name="$(echo ${PACKAGE_NAME} | sed 's/-/_/g')"

  sphinx-apidoc --force -o docs/ "${SOURCE_DIR}"
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

  if [ -s "${quickfix_file}" ]; then
    gvim_load_quickfix_if_running_gvim "${quickfix_file}"
  elif [ -f "${quickfix_file}" ]; then
    command rm "${quickfix_file}"
  fi
}

gvim_load_quickfix_if_running_gvim () {
  local quickfix_file="$1"

  local servername
  servername="$(gvim_find_first_running_gvim_servername)"
  # If nonzero, means gvim not running, or error.
  [ $? -eq 0 ] || \
    return 0

  gvim --servername "${servername}" \
    --remote-send "<ESC>:set errorformat=%f\ %l:%m<CR>" \
  && gvim --servername "${servername}" \
    --remote-send "<ESC>:cgetfile $(pwd)/${quickfix_file}<CR>"
}

# Check GVim is running, and probe the `--servername`.
#
#   $ ps -fp $(pidof gvim)
#   UID        PID  PPID  C STIME TTY          TIME CMD
#   user     24448     1  1 May20 ?        00:13:21 gvim --servername SAMPI --remote-silent /home/user/README.rst
#
#   $ cat /proc/$(pidof gvim)/cmdline | sed -e "s/\x00/ /g"; echo
#   gvim --servername SAMPI --remote-silent /home/user/README.rst
#
# The `ps` command is more compatible than Linux-specific /proc/ probing.
# - Anb we can print just the args, too:
#
#   $ ps -p $(pidof gvim) -o "%a" --no-headers
#   gvim --servername SAMPI --remote-silent /home/user/README.rst
#
#   - For why the author uses SAMPI, it's used by the DepoXy `fs` command:
#       https://github.com/depoxy/depoxy
#         ~/.depoxy/ambers/core/alias-vim.sh
#
# Finally, we can regex-tract the server name:
#
#   $ ps -p $(pidof gvim) -o "%a" --no-headers | sed -E 's/^.*--servername ([^ ]+).*$/\1/'
#   SAMPI

# Note that --servername defaults to "GVIM" (what a bare `gvim` uses).
# - So if unable to determine servername from gvim process args,
#   then something is wrong with our code.
# - E.g., if your gvim is SAMPI but you omit --servername, you'll see:
#     E247: No registered server named "GVIM": Send failed.

gvim_find_first_running_gvim_servername () {
  local gvim_pids="$(pidof gvim)"

  [ -n "${gvim_pids}" ] || \
    return 1

  local gvim_pid="$(echo "${gvim_pids}" | awk '{ print $1 }')"

  local gvim_args="$(ps -p ${gvim_pid} -o '%a' --no-headers)"

  local servername="$(echo "${gvim_args}" | sed -E 's/^.*--servername ([^ ]+).*$/\1/')"

  local n_gvims=$(echo "${gvim_pids}" | wc -w)

  # GVIM_OPEN_SERVERNAME is a DepoXy setting so you can specify a
  # particular gvim if you often run more than 1.
  if [ -n "${GVIM_OPEN_SERVERNAME}" ]; then
    if gvim_verify_servername_running "${GVIM_OPEN_SERVERNAME}"; then
      servername="${GVIM_OPEN_SERVERNAME}"
    elif [ ${n_gvims} -gt 1 ]; then
      # Don't bother alerting user if only one GVim running; just use it.
      # - Otherwise alert user their GVIM_OPEN_SERVERNAME is invalid.
      >&2 echo "ERROR: No gvim running named “${GVIM_OPEN_SERVERNAME}” (GVIM_OPEN_SERVERNAME)" \
        "— falling back “${servername}”"
    fi
  fi

  if [ "${servername}" = "${gvim_args}" ]; then
    # See comments above: gvim assumes "GVIM" if not given --servername
    # (because bare `gvim` uses "GVIM").
    servername="GVIM"

    if ! gvim_verify_servername_running "${servername}"; then
      >&2 echo "ERROR: Failed to determine gvim --servername (and it's not “GVIM”) — cannot load quickfix"

      return 2
    fi
  fi

  # ***

  if [ ${n_gvims} -gt 1 ] && [ -z "${GVIM_OPEN_SERVERNAME+x}" ]; then
    >&2 echo "Found ${n_gvims} gvim and picked “${servername}”"
    >&2 echo "- Use GVIM_OPEN_SERVERNAME to specify which gvim to always pick,"
    >&2 echo "  or \`GVIM_OPEN_SERVERNAME=\` in your shell inhibits this message."
  fi

  # ***

  echo "${servername}"
}

gvim_verify_servername_running () {
  gvim --servername "$1" --remote-send "<ESC>:<CR>" 2> /dev/null
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
  local venv_args="$2"
  local venv_default="$3"

  if [ ! -d "${venv_name}" ]; then
    python3 -m venv ${venv_args} "${venv_name}"

    VENV_CREATED=true

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

# USAGE: If the derived project has its own custom code, add it to
#   Maketasks.local.sh

MAKETASKS_LOCAL_SH="${MAKETASKS_LOCAL_SH:-Maketasks.local.sh}"
export MAKETASKS_LOCAL_SH

if [ -s "${MAKETASKS_LOCAL_SH}" ]; then
  . "${MAKETASKS_LOCAL_SH}"
fi

