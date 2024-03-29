# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/doblabs/easy-as-pypi#🥧
# Copyright © 2020, 2023 Landon Bouma. All rights reserved.
# License: MIT

"""Top-level package for this CLI-based application."""

import gettext
import inspect
import os
import sys

import click

import easy_as_pypi
from easy_as_pypi import commands

__all__ = (
    "__arg0name__",
    "__author_name__",
    "__author_link__",
    "__package_name__",
)

# NOT_DRY: (lb): These strings also found in setup.cfg, but I'm not sure how best
# to DRY. Fortunately, they're not likely to change. Useful for UX copyright text.
__author_name__ = "Landon Bouma"
__author_link__ = "https://tallybark.com"

# (lb): Not sure if the package name is available at runtime. Seems kinda meta,
# like, "Who am I?" Useful for calling get_distribution, or to avoid hardcoding
# the package name in text generated for the UX.
__package_name__ = "easy-as-pypi"
__arg0name__ = os.path.basename(sys.argv[0])

# This version value is substituted on poetry-build. See pyproject.toml:
#   [tool.poetry-dynamic-versioning.substitution]
# - However, when installed in 'editable' mode, the substitution does not
#   happen. So either we live with "0.0.0", or we check Git tags (because
#   we can assume an 'editable' mode install only happens on a dev machine).
__version__ = ""


def __version_probe__():
    if __version__:
        return __version__

    # CXREF: `git-latest-version` is from git-smart:
    #   https://github.com/landonb/git-smart#💡
    #     https://github.com/landonb/git-smart/blob/release/bin/git-latest-version
    # MEH: There is a Pythonic way to find the version from Git tags,
    #      using setuptools_scm.
    #      - CXREF: ~/.kit/py/easy-as-pypi-getver/src/easy_as_pypi_getver/__init__.py
    #          https://github.com/doblabs/easy-as-pypi-getver#🔢
    #      But we're not gonna use that code, b/c DRY (in a sense,
    #      easy-as-pypi-getver should really just be easy-as-pypi itself).
    # - But this path only followed on a dev install (e.g., `make develop`),
    #   and I'd encourage co-devs to install git-smart (and git-extras, and
    #   lots of other brilliant Git projects).
    # - Also this code works without git-smart, just prints "<unknown>".
    # - So while somewhat esoteric and mostly about making one dev happy
    #   (I'm happy!), this is harmless and does not impose upon normal users.

    import subprocess

    completed_proc = subprocess.run(["git", "latest-version"], capture_output=True)

    if completed_proc.returncode == 0:
        # Raw stdout is bytes with newline, e.g.,
        #   b'1.0.1-a-3\n'
        # So decode the output.
        return completed_proc.stdout.decode().strip()
        # Alternatively:
        #   return str(completed_proc.stdout, 'UTF-8').strip()

    return "<unknown>"


# ***

# Determine path to localization files, which are installed alongside
# sources (i.e., under site-packages).
# - We call `inspect.getfile` to be pedantic, but you could as easily:
#     os.path.dirname(easy_as_pypi.__file__),
locale_path = os.path.join(
    os.path.dirname(inspect.getfile(easy_as_pypi)),
    "locale",
)

# Initialize translation engine.
lang_en = gettext.translation("messages", localedir=locale_path, languages=["en"])

# Set current locale to 'en'.
# - Install will also wire `_`, akin to:
#     from gettext import gettext as _
#   (Which applies to all modules; no need to map `_` ourselves.)
lang_en.install()


@click.group()
def cli():
    pass


# Add commands
# YOU: Change as appropriate.
cli.add_command(commands.easy_as_pypi.eat)
cli.add_command(commands.easy_as_pypi.version)
