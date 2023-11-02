@@@@@@@@@@@@
easy-as-pypi
@@@@@@@@@@@@

.. CXREF:
   https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/adding-a-workflow-status-badge

.. image:: https://github.com/doblabs/easy-as-pypi/actions/workflows/checks-unspecial.yml/badge.svg?branch=release
  :target: https://github.com/doblabs/easy-as-pypi/actions/workflows/checks-unspecial.yml/badge.svg?branch=release
  :alt: Build Status

.. CXREF: https://app.codecov.io/github.com/doblabs/easy-as-pypi/settings/badge

.. image:: https://codecov.io/gh/doblabs/easy-as-pypi/branch/release/graph/badge.svg?token=AlKUyOgTGY
  :target: https://app.codecov.io/gh/doblabs/easy-as-pypi
  :alt: Coverage Status

.. image:: https://readthedocs.org/projects/easy-as-pypi/badge/?version=latest
  :target: https://easy-as-pypi.readthedocs.io/en/latest/
  :alt: Documentation Status

.. image:: https://img.shields.io/github/v/release/doblabs/easy-as-pypi.svg?style=flat
  :target: https://github.com/doblabs/easy-as-pypi/releases
  :alt: GitHub Release Status

.. image:: https://img.shields.io/pypi/v/easy-as-pypi.svg
  :target: https://pypi.org/project/easy-as-pypi/
  :alt: PyPI Release Status

.. image:: https://img.shields.io/pypi/pyversions/easy-as-pypi.svg
  :target: https://pypi.org/project/easy-as-pypi/
  :alt: PyPI Supported Python Versions

.. image:: https://img.shields.io/github/license/doblabs/easy-as-pypi.svg?style=flat
  :target: https://github.com/doblabs/easy-as-pypi/blob/release/LICENSE
  :alt: License Status

|

Boilerplate PyPI project.

.. Install with ``pip``::
..
..     pip3 install easy-as-pypi

########
Overview
########

Boilerplate for modern, bathroom-tub-included Python projects.

The boilerplate itself is installable and includes minimalist Click CLI.

But most of the gold is buried within:

- Modern Poetry and ``pyproject.toml`` setup.

- Supports cascading editable installs (install current project in
  editable mode, as well as any dependencies you might have source
  for locally; boilerplate manages alternative ``pyproject.toml``
  automatically).

- All the lints: ``black``, ``flake8``, ``isort``, ``pydocstyle``,
  ``doc8``, ``linkcheck``, ``poetry check``, and ``twine check``.

- Test against all active Python versions and lint using ``tox``.

- Run tasks, tests, and setup virtualenvs quickly using ``make``
  commands in your active virtualenv.

  - Generate docs for *ReadTheDocs*.

  - Localize user messages using ``Babel``.

  - Easily install to shared or isolated virtualenvs.

- GitHub Actions linting, testing, and coverage upload.

Most of the files are designed to be hard linked from the derived
projects themselves, as they won't need to be customized (such as
``Makefile``).

- Then when the boilerplate changes, you can just commit the
  changes in the derived project, call them "dependency updates"
  or something, and not have to worry about merging changes manually
  (and running ``meld`` or something).

