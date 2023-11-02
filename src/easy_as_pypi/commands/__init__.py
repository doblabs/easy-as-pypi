# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/doblabs/easy-as-pypi#🥧
# Copyright © 2020, 2023 Landon Bouma. All rights reserved.
# License: MIT

"""Convenience reference definitions.

Root sub-module convenience references/aliases.

- So you can call, e.g.,

  .. code-block:: python

      from my_package.commands import my_command

  instead of

  .. code-block:: python

      from my_package.commands.my_module import my_command
"""

from . import easy_as_pypi

__all__ = ("easy_as_pypi",)
