@@@@@@@@@@@@
easy-as-pypi
@@@@@@@@@@@@

.. FEAT-REQU/2020-01-25: (lb): Add kcov Bash coverage of the release script.

.. .. image:: https://travis-ci.com/landonb/easy-as-pypi.svg?branch=develop
..   :target: https://travis-ci.com/landonb/easy-as-pypi
..   :alt: Build Status
..
.. .. image:: https://codecov.io/gh/landonb/easy-as-pypi/branch/develop/graph/badge.svg
..   :target: https://codecov.io/gh/landonb/easy-as-pypi
..   :alt: Coverage Status
..
.. .. image:: https://readthedocs.org/projects/easy-as-pypi/badge/?version=latest
..   :target: https://easy-as-pypi.readthedocs.io/en/latest/
..   :alt: Documentation Status
..
.. .. image:: https://img.shields.io/github/release/landonb/easy-as-pypi.svg?style=flat
..   :target: https://github.com/landonb/easy-as-pypi/releases
..   :alt: GitHub Release Status
..
.. .. image:: https://img.shields.io/pypi/v/easy-as-pypi.svg
..   :target: https://pypi.org/project/easy-as-pypi/
..   :alt: PyPI Release Status

.. image:: https://img.shields.io/github/license/landonb/easy-as-pypi.svg?style=flat
  :target: https://github.com/landonb/easy-as-pypi/blob/release/LICENSE
  :alt: License Status

One dev's boilerplate PyPI project.

.. Install with ``pip``::
..
..     pip3 install easy-as-pypi

########
Overview
########

This project contains Python project boilerplate
for your next CLI project.

.. FIXME/2020-12-13: Enumerate contents, and add links.
Includes Click, config-decorator, app_dirs, etc.

See ``bin/clone-and-rebrand-easy-as-pypi.sh`` for automatically
generating a new PyPI-ready project from this repository.

You'll need to diff some files against this project to stay current
with some of the boilerplate (like setup.py, tox.ini, etc.), but
those files rarely change, and most functionality is included by
way of PyPI dependencies, which you can easily keep up to date with
CI tools (like requires.io).

