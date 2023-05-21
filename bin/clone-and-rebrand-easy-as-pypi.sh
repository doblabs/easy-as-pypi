#!/usr/bin/env bash
# vim:tw=0:ts=2:sw=2:et:norl:nospell
# Project: https://github.com/pydob/easy-as-pypi#🥧
# License: MIT

# USAGE: Copy the first function to a new file, customize it,
# source it, then run this file.
#
# - For an example, see:
#
#     make-your-own-branded-pypi-project--example.sh
#
#   for in the same directory as this script.

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

EASY_AS_PYPI_PATH="$(cd "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -L)"

example_prepare_yourapp_boilerplate_envs () {
  # YOU: Set to the path where you want the new project cloned.
  # - This assumes you want the new directory created in the
  #   same directory as (this) the easy-as-pypi project.
  export shared_root="$(cd "${EASY_AS_PYPI_PATH}/.." && pwd -L)"

  # YOU: Set this to the name of the new app.
  export appname_train="easy-as-pypi"

  # Variations on the proper project name.
  export appname_snake="$(recase_train2snake "${appname_train}")"
  export appname_oneword="$(recase_string2plainoneword "${appname_train}")"
  export appname_capitalize="$(recase_string2capitalize "${appname_train}")"
  export appname_capwords="$(recase_string2plaincapwords "${appname_capitalize}")"

  # *** YOU: Set remaining as relevant.

  # Copyright headers.
  # - 1st line: # This file exists within '${appname_train}':
  # - 3rd line: #   ${github_project}
  # - 5th line: # Copyright © ${header_copy_years} ${header_copy_names}. All rights reserved.
  export header_projecturl="https://github.com/pydob/easy-as-pypi#🥧"
  export header_copy_years="2020"
  export header_copy_names="Landon Bouma"

  # AUTHORS.rst
  export entity_name="Tally Bark LLC"
  export entity_ghuser="tallybark"
  export entity_ghaddy="https://github.com/${entity_ghuser}"
  #
  export person_name="Landon Bouma"
  export person_ghuser="landonb"
  export person_ghaddy="https://github.com/${person_ghuser}"
  #
  export person_email="${entity_ghuser}+${appname_oneword} -at- gmail.com"

  # CODE-OF-CONDUCT.rst
  export conduct_email="${entity_ghuser}+${appname_oneword} -at- gmail.com"

  # docs/conf.py
  export project_ghuser="${person_ghuser}"
  export project_htmlhelp_basename="${appname_capwords}doc"
  export project_copy="${person_name}."
  export project_auth="${person_name}"
  export project_orgn="${entity_name}"

  # CONTRIBUTING.rst
  export github_remote_ssh="git@github.com:${project_ghuser}/${appname_train}.git"
  # For adding remote to new Git repo (i.e., what's conventionally 'upstream'):
  export github_remote_name="starter"

  # CONTRIBUTING.rst, setup.cfg,
  #   docs/conf.py, docs/index.rst, docs/installation.rst, docs/make.bat
  export github_project="https://github.com/${project_ghuser}/${appname_train}"

  # CONTRIBUTING.rst, setup.cfg
  export readthedocs_url="https://${appname_train}.readthedocs.io"

  # setup.cfg
  export setup_author="${person_name}"
  export setup_author_email="${entity_ghuser}+${appname_oneword}@gmail.com"
  export setup_description="Bootstrapping your next Python CLI made easy as PyPI"
  export setup_projects_urls_bug_tracker="${github_project}/issues"
  export setup_license="MIT"
  # Ref:
  #   https://pypi.org/classifiers/
  export setup_classifier_license="License :: OSI Approved :: MIT License"
  export setup_classifier_development_status="Development Status :: 5 - Production/Stable"
  export setup_classifier_intended_audience="Intended Audience :: Developers"
  export setup_classifier_topic="Topic :: Software Development :: Libraries :: Application Frameworks"
  export setup_keywords="python boilerplate pyoilerplate scaffolding framework CLI TUI skeleton cookiecutter"
}

# ***

recase_train2snake () {
  # This Bash pattern substitution is equivalent to:
  #   echo "${appname_train}" | tr '-' '_'
  printf '%s\n' "${1//-/_}"
}

recase_string2plainoneword () {
  # Similarly, analogously:
  #   echo "${appname_train}" | tr '-' ''
  # Or, better yet, tackle unexpected nonalphanums, use
  #   translate --complement --delete.
  printf '%s\n' "$(echo "${1}" | tr -cd '[:alnum:]')"
}

recase_string2capitalize () {
  printf '%s\n' "$(echo "${1}" | /bin/sed -e "s/\b\(.\)/\\u\1/g")"
}

recase_string2plaincapwords () {
  # Same translate --complement --delete trick as recase_string2plainoneword.
  printf '%s\n' "$(echo "${1}" | tr -cd '[:alnum:]')"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

print_boilerplate_vars () {
  # Use var_prefix="source_" to print source matching vars.
  local var_prefix="$1"
  local echo_quiet="${2:-false}"

  local errors_found=0

  local what_type='new project being created'
  [ -n "${var_prefix}" ] && what_type='old project being cloned'
  ${echo_quiet} || echo
  ${echo_quiet} || echo "Business Values: A look at values for the ${what_type}..."
  ${echo_quiet} || echo

  for yourapp_var in \
    \
    shared_root \
    \
    appname_train \
    appname_snake \
    appname_oneword \
    appname_capitalize \
    appname_capwords \
    \
    header_projecturl \
    header_copy_years \
    header_copy_names \
    \
    entity_name \
    entity_ghuser \
    entity_ghaddy \
    person_name \
    person_ghuser \
    person_ghaddy \
    person_email \
    \
    conduct_email \
    \
    project_ghuser \
    project_htmlhelp_basename \
    project_copy \
    project_auth \
    project_orgn \
    \
    github_remote_ssh \
    github_remote_name \
    \
    github_project \
    \
    readthedocs_url \
    \
    setup_author \
    setup_author_email \
    setup_description \
    setup_projects_urls_bug_tracker \
    setup_license \
    setup_classifier_license \
    setup_classifier_development_status \
    setup_classifier_intended_audience \
    setup_classifier_topic \
    setup_keywords \
  ; do
    local boiler_var="${var_prefix}${yourapp_var}"
    if [ -n "${!boiler_var}" ]; then
      ${echo_quiet} || echo "${boiler_var}=${!boiler_var}"
    else
      echo "MISSING: ${boiler_var} (or just empty)"
    fi
    [ -z "${!boiler_var}" ] && errors_found=1
  done

  return ${errors_found}
}

verify_yourapp_boilerplate_or_exit () {
  print_boilerplate_vars "$@"

  if [ $? -ne 0 ]; then
    >&2 echo "ERROR: Please ensure all target variables are set."
    exit 1
  fi
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

setup_source_string_matching () {

  # *** Names of (this) the easy-as-pypi source project.

  source_appname_train="easy-as-pypi"

  # Variations on the proper project name.
  source_appname_snake="$(recase_train2snake "${source_appname_train}")"
  source_appname_oneword="$(recase_string2plainoneword "${source_appname_train}")"
  source_appname_capitalize="$(recase_string2capitalize "${source_appname_train}")"
  source_appname_capwords="$(recase_string2plaincapwords "${source_appname_capitalize}")"

  # *** SED regex for matching easy-as-pypi source to change.

  # Copyright headers.
  # - 1st line: # This file exists within '${source_appname_train}':
  # - 3rd line: #   ${source_github_project}
  # - 5th line: # Copyright © ${source_author_copy_years} ${source_author_copy_names}. All rights reserved.
  source_header_projecturl="https://github.com/pydob/easy-as-pypi#🥧"
  source_header_copy_years="2020"
  source_header_copy_names="Landon Bouma"

  # AUTHORS.rst
  source_entity_name="Tally Bark LLC"
  source_entity_ghuser="tallybark"
  source_entity_ghaddy="https://github.com/${source_entity_ghuser}"
  #
  source_person_name="Landon Bouma"
  source_person_ghuser="landonb"
  source_person_ghaddy="https://github.com/${source_person_ghuser}"
  #
  source_person_email="${source_entity_ghuser}+${source_appname_oneword} -at- gmail.com"

  # CODE-OF-CONDUCT.rst
  source_conduct_email="${source_entity_ghuser}+${source_appname_oneword} -at- gmail.com"

  # docs/conf.py
  source_project_ghuser="${source_person_ghuser}"
  source_project_htmlhelp_basename="${source_appname_capwords}doc"
  source_project_copy="${source_person_name}."
  source_project_auth="${source_person_name}"
  source_project_orgn="${source_entity_name}"

  # CONTRIBUTING.rst
  source_github_remote_ssh="git@github.com:${source_project_ghuser}/${source_appname_train}.git"
  # Not necessary:
  #  source_github_remote_name="starter"

  # It's actually landonb's project.
  # CONTRIBUTING.rst, setup.cfg,
  #   docs/conf.py, docs/index.rst, docs/installation.rst, docs/make.bat
  source_github_project="https://github.com/${source_project_ghuser}/${source_appname_train}"

  # CONTRIBUTING.rst, setup.cfg
  source_readthedocs_url="https://${source_appname_train}.readthedocs.io"

  # setup.cfg
  source_setup_author="${source_person_name}"
  source_setup_author_email="${source_entity_ghuser}+${source_appname_oneword}@gmail.com"
  # setup_description="Bootstrapping your next Python TUI made easy as PyPI"
  source_setup_description="Bootstrapping your next Python CLI made easy as PyPI"
  source_setup_projects_urls_bug_tracker="${source_github_project}/issues"
  source_setup_license="MIT"
  # Ref:
  #   https://pypi.org/classifiers/
  source_setup_classifier_license="License :: OSI Approved :: MIT License"
  # Some choices:
  #  Development Status :: 2 - Pre-Alpha
  #  Development Status :: 3 - Alpha
  #  Development Status :: 4 - Beta
  #  Development Status :: 5 - Production/Stable
  source_setup_classifier_development_status="Development Status :: 5 - Production/Stable"
  source_setup_classifier_intended_audience="Intended Audience :: Developers"
  source_setup_classifier_topic="Topic :: Software Development :: Libraries :: Application Frameworks"
  source_setup_keywords="python boilerplate pyoilerplate scaffolding framework CLI TUI skeleton cookiecutter"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# SYNC_ME: Copied from landonb/git-bump-version-tag.

# Use git-tag's simple glob to first filter on tags starting with 'v' or 0-9.
GITSMART_RE_VERSION_TAG='[v0-9]*'
# DEV: Copy-paste test snippet:
#   git --no-pager tag -l "${GITSMART_RE_VERSION_TAG}"

# The git-tag pattern is a simple glob, so use extra grep to really filter.
GITSMART_RE_GREPFILTER='^[0-9]\+\.[0-9.]\+$'

# Match groups: \1: major * \2: minor * \4: patch * \5: seppa * \6: alpha.
GITSMART_RE_VERSPARTS='^v?([0-9]+)\.([0-9]+)(\.([0-9]+)([^0-9]*)(.*))?'

latest_version_basetag () {
  git tag -l "${GITSMART_RE_VERSION_TAG}" |
    grep -e "${GITSMART_RE_GREPFILTER}" |
    /usr/bin/env sed -E "s/${GITSMART_RE_VERSPARTS}/\1.\2.\4/" |
    sort -r --version-sort |
    head -n1
}

set_pypi_version () {
  local before_cd="$(pwd -L)"
  cd "${EASY_AS_PYPI_PATH}"

  PYPI_VERSION="$(latest_version_basetag)"

  cd "${before_cd}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

clone_easy_as_pypi_project () {
  local yourapp_dir_project="${shared_root}/${appname_train}"
  if [ -d "${yourapp_dir_project}" ]; then
    echo "SKIPPING: ${appname_train} already exists"
    return 0
  fi

  local before_cd="$(pwd -L)"
  cd "${shared_root}"

  # ***

  echo
  echo "Cloning: ${EASY_AS_PYPI_PATH} → ${yourapp_dir_project}..."
  echo

  # Easiest way to copy just the published project files:
  git clone -o TBD "${EASY_AS_PYPI_PATH}" "${yourapp_dir_project}"

  cd "${yourapp_dir_project}"

  cloned_project_reset_git

  # ***

  cd "${before_cd}"
}

# ***

cloned_project_reset_git () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # ***

  local first_commit_here="$(git rev-list --max-parents=0 HEAD)"
  local first_commit_real="78dc9f3f3a74004cfaa3eda80ac09b7ab2e53361"

  if [ "${first_commit_here}" != "${first_commit_real}" ]; then
    >&2 echo "ERROR: Unexpected: Does not look like the ${source_appname_train} project was copied!"
    exit 1
  fi

  echo
  echo "Git: Initializing Git repo..."
  echo

  command rm -rf ".git/"

  # Remove the copy of this script, and its helper(s).
  command rm -rf "bin/"

  git init .

  git_commit_initial_clone

  git remote add ${github_remote_name} "${github_remote_ssh}"

  # ***

  cd "${before_cd}"
}

git_commit_initial_clone () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # ***

  git add .

  set_pypi_version

  git ci -m "Init: Cloned from v${PYPI_VERSION} ${source_appname_train} boilerplate.

  - Ref: ${source_github_project}/releases/tag/${PYPI_VERSION}"

  # ***

  cd "${before_cd}"
}

git_commit_refactor () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # ***

  echo
  echo "Git: Committing rebranding changes..."
  echo

  git add .

  git ci -m "Refactor: Rename ${source_appname_train} → ${appname_train} et al."

  # ***

  cd "${before_cd}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

rename_app_name_in_files () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # *** Rename files and project name and resource references.

  echo
  echo "Rebrand: Renaming files..."
  echo

  local toc_postfix=''
  [ "${appname_train}" = "${appname_snake}" ] && toc_postfix="-toc-example"

  # Hrm, no assets/ directory, but it's referenced in conf.py... OH, commented out, derp!
  #   git mv 'assets/${source_appname_train}_logo.png' "assets/${appname_train}_logo.png"
  # Docs are auto-generated, but also committed to Git.
  git mv "docs/${source_appname_snake}.rst" \
         "docs/${appname_snake}.rst"
  git mv "docs/${source_appname_snake}.commands.rst" \
         "docs/${appname_snake}.commands.rst"
  git mv "docs/${source_appname_train}.rst" \
         "docs/${appname_train}${toc_postfix}.rst"
  # Update tests.
  git mv "tests/${source_appname_snake}" \
         "tests/${appname_snake}"
  git mv "tests/${appname_snake}/test_${source_appname_snake}.py" \
         "tests/${appname_snake}/test_${appname_snake}.py"
  # Update runtime.
  git mv "${source_appname_snake}" \
         "${appname_snake}"
  git mv "${appname_snake}/commands/${source_appname_snake}.py" \
         "${appname_snake}/commands/${appname_snake}.py"

  # MAYBE: More granular commits, e.g.:
  #
  #   git ci -m "Refactor: Rename boilerplate-named files."

  # ***

  cd "${before_cd}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

tell_user_to_do_something_and_wait () {
  printf %s "${1} [Y/n] "
  read -e YES_OR_NO
  if [ "${YES_OR_NO^^}" = 'N' ] || [ "${YES_OR_NO^^}" = 'NO' ]; then
    >&2 echo "Apparently not"
    exit 1
  fi
}

# ***

prompt_user_to_edit_copyright_headers () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # ***

  echo "The new project has been cloned, but the copyright headers are not updated."
  echo
  echo "Please edit setup.cfg and set the copyright header how you'd like."
  echo
  echo "We'll run your EDITOR now. Make the edits, then save and quit."
  echo

  tell_user_to_do_something_and_wait "Ready to edit?"

  # Give user's EDITOR a whirl.
  ${EDITOR} setup.cfg

  tell_user_to_do_something_and_wait "Okay to continue rebranding?"

  local editor_ret=$?

  # ***

  cd "${before_cd}"

  return ${editor_ret}
}

prompt_user_to_edit_copyright_headers_or_exit () {
  prompt_user_to_edit_copyright_headers
  [ $? -eq 0 ] || exit $?
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

prepare_setup_cfg_source_copyright_headers () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # ***

  echo "Headers: Updating 1st line..."
  local source_header_line_this_exists="# This file exists within '${source_appname_train}':"
  local reword_header_line_this_exists="# This file exists within '${appname_train}':"
  sed -i'' \
    "s/^${source_header_line_this_exists}$/${reword_header_line_this_exists}/" \
    "setup.cfg"

  echo "Headers: Updating 3rd line..."
  local source_header_line_projecturl="#   ${source_header_projecturl}"
  local reword_header_line_projecturl="#   ${header_projecturl}"
  # Note there are `/` chars. in the variable, so use unconventional regex boundary, `%`.
  sed -i'' \
    "s%^${source_header_line_projecturl}$%${reword_header_line_projecturl}%" \
    "setup.cfg"

  echo "Headers: Updating 5th line..."
  local source_header_line_copy_sentence="# Copyright © ${source_header_copy_years} ${source_header_copy_names}."
  local reword_header_line_copy_sentence="# Copyright © ${header_copy_years} ${header_copy_names}."
  # Note: No trailing '$'. Only matching line.startswith.
  sed -i'' \
    "s/^${source_header_line_copy_sentence}/${reword_header_line_copy_sentence}/" \
    "setup.cfg"

  # ***

  cd "${before_cd}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

update_file_contents_copyright_headers () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # ***

  # Don't really need to wait, but maybe user wants to commit changes
  # (using a different terminal).
  #
  #  tell_user_to_do_something_and_wait "Enter something other than 'N' to update headers."

  echo
  echo "Rebrand: Replacing headers..."
  echo

  # Now propagate new copyright header to other files.
  # - First the headers that include the copyright-landon tail:
  ${EASY_AS_PYPI_PATH}/bin/copy-header-from-setup.cfg-to-all-files.sh "-5"

  # - And then the headers that do not include a copyright-me:
  ${EASY_AS_PYPI_PATH}/bin/copy-header-from-setup.cfg-to-all-files.sh "-3"

  # ***

  cd "${before_cd}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

update_file_contents_first_specific_matches () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # *** Simple edits: more specific changes first.

  echo
  echo "Rebrand: Updating file contents (part 1)..."

  sed -i'' \
    "s#- \`${source_entity_name} <${source_entity_ghaddy}>\`__#- \`${entity_name} <${entity_ghaddy}>\`__#" \
    "AUTHORS.rst"
  sed -i'' \
    "s#- \`${source_person_name} <${source_person_ghaddy}>\`__#- \`${person_name} <${person_ghaddy}>\`__#" \
    "AUTHORS.rst"
  sed -i'' \
    "s/${source_person_email}/${person_email}/" \
    "AUTHORS.rst"
  #
  sed -i'' \
    "s/${source_conduct_email}/${conduct_email}/" \
    "CODE-OF-CONDUCT.rst"
  #
  sed -i'' \
    "s/project_ghuser = '${source_project_ghuser}'/project_ghuser = '${project_ghuser}'/" \
    "docs/conf.py"
  sed -i'' \
    "s/project_htmlhelp_basename = '${source_project_htmlhelp_basename}'/project_htmlhelp_basename = '${project_htmlhelp_basename}'/" \
    "docs/conf.py"
  sed -i'' \
    "s/project_copy = '${source_project_copy}'/project_copy = '${project_copy}'/" \
    "docs/conf.py"
  sed -i'' \
    "s/project_auth = '${source_project_auth}'/project_auth = '${project_auth}'/" \
    "docs/conf.py"
  sed -i'' \
    "s/project_orgn = '${source_project_orgn}'/project_orgn = '${project_orgn}'/" \
    "docs/conf.py"
  #
  sed -i'' \
    "s#${source_readthedocs_url}#${readthedocs_url}#" \
    "CONTRIBUTING.rst"
  sed -i'' \
    "s#${source_github_remote_ssh}#${github_remote_ssh}#" \
    "CONTRIBUTING.rst" \
    "docs/installation.rst"
  #
  sed -i'' \
    "s#${source_github_project}#${github_project}#" \
    "CONTRIBUTING.rst" \
    "setup.cfg" \
    "docs/conf.py" \
    "docs/index.rst" \
    "docs/installation.rst" \
    "docs/make.bat"
  #
  sed -i'' \
    "s/author = ${source_setup_author}/author = ${setup_author}/" \
    "setup.cfg"
  sed -i'' \
    "s/author-email = ${source_setup_author_email}/author-email = ${setup_author_email}/" \
    "setup.cfg"
  sed -i'' \
    "s/description = ${source_setup_description}/description = ${setup_description}/" \
    "setup.cfg"
  sed -i'' \
    "s#    Bug Tracker = ${source_setup_projects_urls_bug_tracker}#    Bug Tracker = ${setup_projects_urls_bug_tracker}#" \
    "setup.cfg"
  sed -i'' \
    "s/license = ${source_setup_license}/license = ${setup_license}/" \
    "setup.cfg"
  sed -i'' \
    "s#    ${source_setup_classifier_license}#    ${setup_classifier_license}#" \
    "setup.cfg"
  sed -i'' \
    "s#    ${source_setup_classifier_development_status}#    ${setup_classifier_development_status}#" \
    "setup.cfg"
  sed -i'' \
    "s#    ${source_setup_classifier_intended_audience}#    ${setup_classifier_intended_audience}#" \
    "setup.cfg"
  sed -i'' \
    "s#    ${source_setup_classifier_topic}#    ${setup_classifier_topic}#" \
    "setup.cfg"
  sed -i'' \
    "s#    ${source_setup_keywords}#    ${setup_keywords}#" \
    "setup.cfg"

  # ***

  cd "${before_cd}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

update_file_contents_then_more_general_matches () {
  local before_cd="$(pwd -L)"
  cd "${shared_root}/${appname_train}"

  # *** Simple edits: more generic changes last.

  echo
  echo "Rebrand: Updating file contents (part 2)..."

  local toc_postfix=''
  [ "${appname_train}" = "${appname_snake}" ] && toc_postfix="-toc-example"

  # ``easy_as_pypi`` → ``your_app_name``
  sed -i'' \
    "s/${source_appname_snake}/${appname_snake}/g" \
    "codecov.yml" \
    "CONTRIBUTING.rst" \
    ".coveragerc" \
    ".gitignore" \
    "Makefile" \
    "MANIFEST.in" \
    "setup.cfg" \
    "setup.py" \
    "tox.ini" \
    "docs/conf.py" \
    "docs/${appname_train}.rst" \
    "docs/${appname_snake}${toc_postfix}.rst" \
    "docs/${appname_snake}.commands.rst" \
    "tests/conftest.py" \
    "${appname_snake}/__init__.py" \
    "${appname_snake}/commands/__init__.py"

  # ``easy-as-pypi`` → ``your-app-name``
  sed -i'' \
    "s/${source_appname_train}/${appname_train}/g" \
    "CONTRIBUTING.rst" \
    ".gitignore" \
    "setup.cfg" \
    "docs/conf.py" \
    "docs/index.rst" \
    "docs/installation.rst" \
    "docs/license.rst" \
    "docs/make.bat" \
    "docs/Makefile" \
    "tests/__init__.py" \
    "tests/${appname_snake}/__init__.py" \
    "tests/${appname_snake}/test_${appname_snake}.py" \
    "${appname_snake}/__init__.py"

  # ***

  cd "${before_cd}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #

# Always set the source variables, whether being executed or sourced.
setup_source_string_matching

main () {
  set -e

  verify_yourapp_boilerplate_or_exit

  clone_easy_as_pypi_project

  rename_app_name_in_files

  # prompt_user_to_edit_copyright_headers_or_exit
  prepare_setup_cfg_source_copyright_headers
  update_file_contents_copyright_headers

  update_file_contents_first_specific_matches
  update_file_contents_then_more_general_matches

  git_commit_refactor

  echo
  echo "Done!"
}

# ***

# Run in executed, else just be sourced.
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  main "$@"
fi
unset -f main

