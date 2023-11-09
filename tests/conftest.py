# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/doblabs/easy-as-pypi#🥧
# Copyright © 2020 Landon Bouma. All rights reserved.
# License: MIT

"""Provides CLI runner() test fixture, for interacting with Click app."""

import pytest
from click.testing import CliRunner

import easy_as_pypi


@pytest.fixture
def runner():
    """Provide a convenient fixture to simulate execution of (sub-) commands."""

    def runner(args=[], **kwargs):
        env = {}
        return CliRunner().invoke(easy_as_pypi.cli, args, env=env, **kwargs)

    return runner
