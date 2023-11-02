# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/doblabs/easy-as-pypi#🥧
# Copyright © 2020, 2023 Landon Bouma. All rights reserved.
# License: MIT

"""A simple Click command for YOU: to replace."""

import click


@click.command()
def eat():
    """Eats."""
    click.echo(_("nom nom"))


@click.command()
def version():
    """Print the package version."""
    from .. import __package_name__, __version_probe__

    click.echo(f"{__package_name__} version {__version_probe__()}")
