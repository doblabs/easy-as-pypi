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

This project is installable and includes a minimalist
`Click <https://palletsprojects.com/p/click/>`__ CLI::

  pip install easy-as-pypi

  easy-as-pypi

But this project is so much more!

This is *living* boilerplate.

- Use this project to start a new Python project.

- Use this project to manage your CI checks.

- Use this project to automate your releases.

- And keep your project up-to-date with the latest "boilerplate" by running::

   bin/update-faithful

- Because boilerplate is *never* static!

Here are the selling points, because we're all here to make gold:

- Modern Poetry and ``pyproject.toml`` setup.

  - Much of any project's ``pyproject.toml`` is already prescribed, like,
    90% of your projects' ``pyproject.toml`` is the same between all your
    projects.

    - So this project *generates* ``pyproject.toml``.

      It uses a simple template, located at ``.pyproject.project.tmpl``,
      and applies it to a base ``pyproject.toml`` template
      (named ``.pyproject.tmpl``).

    - Use ``.pyproject.project.tmpl`` to add the few bits that are unique
      to your project, then run ``bin/update-faithful`` to generate
      ``pyproject.toml`` for your project.

    - Most of ``pyproject.toml`` is already boilerplate — think of
      ``pytest`` options, ``black`` options, ``flake8`` options,
      ``isort`` options, as well as ``poetry install --with``
      dependencies, like those for testing, or creating docs,
      etc. — these are usually the same for all of your projects!
      So why repeat yourself?

      As such, we consider ``pyproject.toml`` to be essentially
      boilerplate — it's half boilerplate, half project-specific,
      and generated when you run ``bin/update-faithful``.

- *Editable* installs.

  - Run ``make develop`` to install your project in editable mode,
    as well as any dependencies that you have sources for locally.

  - This project (the boilerplate) will manage an alternative
    ``.pyproject-editable/pyproject.toml`` automatically.

  - Edit ``Makefile`` to tell it which projects are *editable*
    (specifically the ``EDITABLE_PJS`` environ).

- Pre-release installs.

  - Publish pre-release builds to https://test.pypi.org

  - This project (the boilerplate) manages an alternative
    ``.pyproject-prerelease/pyproject.toml`` and ``poetry.lock``,
    as well as using the appropriate ``pip install --pre`` options,
    so you can test changes to your stack before releasing to PyPI,

- All the lints.

  - Run ``make lint`` to run all the lints: ``black``, ``flake8``,
    ``isort``, ``pydocstyle``, ``doc8``, ``linkcheck``,
    ``poetry check``, and ``twine check``.

- All the tests.

  - Run ``tox`` to test against all supported Python versions.

- All the other dev tasks.

  - Run ``make develop`` to create an editable virtualenv (using local sources).

    - Then you can run your app locally, against local sources,
      by calling ``make test``, or ``pytest``.

    - You can also use ``pyenv`` and modify the Python version in
      ``Makefile`` to test against different Python versions, e.g.,::

         pyenv install -s 3.12

         sed -i 's/^VENV_PYVER.*/VENV_PYVER ?= 3.12/' Makefile

         make develop

         workon

         make test

  - Run ``make install`` to create a release virtualenv (using PyPI sources),
    so you can test what end-users will experience (though not the same as
    publishing to PyPI and running ``pip install``, but close).

  - Run ``make docs`` to generate docs for *ReadTheDocs*.

  - Run ``make coverage`` to, ya know, run coverage.

  - Also Babel support, e.g., run ``make babel-compile`` to localize user
    messages.

- All the CI.

  - Look under ``.github/workflows`` for what some might consider an
    over-engineered GitHub Actions workflow.

    But that's really where's there gold:

    - When you push a branch, checks run.

    - When you push a version tag, a release happens.

    - After checks run, and after a release is published,
      a "smoke test" runs: Both ``pip`` and ``pipx`` are
      called to verify your package is viable.

      - And lemme tell you, Poetry might work, publishing
        to PyPI might work, but that still doesn't mean
        the release works. The smoke test lets you know
        it works for certain.

    - And if you maintain multiple projects, the CI job
      will dispatch and kick-off the release of the next
      downstream project.

Point being, this is the Python "boilerplate" to end all boilerplate.

