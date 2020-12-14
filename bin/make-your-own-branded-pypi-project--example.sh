#!/usr/bin/env bash
# vim:tw=0:ts=2:sw=2:et:norl:nospell
# Project: https://github.com/landonb/easy-as-pypi#🥧
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# YOU: Set this path to base of the easy-as-pypi repo:
EASY_AS_PYPI_PATH="/path/to/easy-as-pypi"

prepare_yourapp_boilerplate_envs () {
  # YOU: Set to the path where you want the new project cloned.
  # - This assumes you want the new directory created in the
  #   same directory as (this) the easy-as-pypi project.
  export shared_root="$(cd "${EASY_AS_PYPI_PATH}/.." && pwd -L)"

  # YOU: Set this to the name of the new app.
  export appname_train="YOUr-fabulous-app"

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
  export header_projecturl="https://github.com/YOUr-org-username/YOUr-fabulous-app#🏆"
  export header_copy_years="2020-2021"
  export header_copy_names="YOUr Name"

  # AUTHORS.rst
  export entity_name="YOUr Company LLC"
  export entity_ghuser="YOUr-org-username"
  export entity_ghaddy="https://github.com/${entity_ghuser}"
  #
  export person_name="YOUr Name"
  export person_ghuser="YOUr-own-username"
  export person_ghaddy="https://github.com/${person_ghuser}"
  #
  export person_email="${entity_ghuser}+${appname_oneword} -at- gmail.com"

  # CODE-OF-CONDUCT.rst
  export conduct_email="${entity_ghuser}+${appname_oneword} -at- gmail.com"

  # docs/conf.py
  export project_ghuser="${entity_ghuser}"
  export project_htmlhelp_basename="${appname_capwords}doc"
  export project_copy="${person_name}."
  export project_auth="${person_name}"
  export project_orgn="${entity_name}"

  # CONTRIBUTING.rst
  export github_remote_ssh="git@github.com:${project_ghuser}/${appname_train}.git"
  # For adding remote to new Git repo (i.e., what's conventionally 'upstream'):
  export github_remote_name="upstream"

  # CONTRIBUTING.rst, setup.cfg,
  #   docs/conf.py, docs/index.rst, docs/installation.rst, docs/make.bat
  export github_project="https://github.com/${project_ghuser}/${appname_train}"

  # tox.ini, .travis.yml
  export travis_user="${entity_ghuser}"
  export travis_url="https://travis-ci.com/${travis_user}/${appname_train}"

  # CONTRIBUTING.rst, setup.cfg
  export readthedocs_url="https://${appname_train}.readthedocs.io"

  # setup.cfg
  export setup_author="${entity_name}"
  export setup_author_email="YOUr-email-user@YOUr-email-domain"
  export setup_description="YOUr awesome application description"
  export setup_projects_urls_bug_tracker="${github_project}/issues"
  export setup_license="MIT"
  # Ref:
  #   https://pypi.org/classifiers/
  export setup_classifier_license="License :: OSI Approved :: MIT License"
  export setup_classifier_development_status="Development Status :: 5 - Production/Stable"
  export setup_classifier_intended_audience="Intended Audience :: Developers"
  export setup_classifier_topic="Topic :: Software Development :: Libraries :: Application Frameworks"
  export setup_keywords="fabulous python CLI"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #

main () {
  set -e

  prepare_yourapp_boilerplate_envs

  ${EASY_AS_PYPI_PATH}/bin/clone-and-rebrand-easy-as-pypi.sh

  echo
  echo "Done!!"
}

# +++

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  main "$@"
fi
unset -f main

