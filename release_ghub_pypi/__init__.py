# This file exists within 'release-ghub-pypi':
#
#   https://github.com/hotoffthehamster/release-ghub-pypi
#
# Copyright © 2020 Landon Bouma. All rights reserved.
#
# Permission is hereby granted,  free of charge,  to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge,  publish,  distribute, sublicense,
# and/or  sell copies  of the Software,  and to permit persons  to whom the
# Software  is  furnished  to do so,  subject  to  the following conditions:
#
# The  above  copyright  notice  and  this  permission  notice  shall  be
# included  in  all  copies  or  substantial  portions  of  the  Software.
#
# THE  SOFTWARE  IS  PROVIDED  "AS IS",  WITHOUT  WARRANTY  OF ANY KIND,
# EXPRESS OR IMPLIED,  INCLUDING  BUT NOT LIMITED  TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE  FOR ANY
# CLAIM,  DAMAGES OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE,  ARISING FROM,  OUT OF  OR IN  CONNECTION WITH THE
# SOFTWARE   OR   THE   USE   OR   OTHER   DEALINGS  IN   THE  SOFTWARE.

"""Top-level package for this CLI-based application."""

import os
import sys

import click
from click_alias import ClickAliasedGroup

from release_ghub_pypi import commands

__all__ = (
    '__arg0name__',
    '__author__',
    '__author_email__',
    '__package_name__',
)

# (lb): These are duplicated in setup.cfg:[metadata], but not sure how to DRY.
#   Fortunately, they're not likely to change.
__author__ = 'HotOffThe Hamster'
__author_email__ = 'hotoffthehamster+releaseghubpypi@gmail.com'

# (lb): Not sure if the package name is available at runtime. Seems kinda meta,
# anyway, like, Who am I? I just want to avoid hard coding this string in docs.
__package_name__ = 'release-ghub-pypi'
__arg0name__ = os.path.basename(sys.argv[0])


# ***

@click.group()
def cli():
    pass


# Add commands
cli.add_command(commands.release_ghub_pypi.die)

