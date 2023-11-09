# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/doblabs/easy-as-pypi#🥧
# Copyright © 2020 Landon Bouma. All rights reserved.
# License: MIT

"""Tests for ``easy-as-pypi``."""


class TestOneAndDone(object):
    def test_truthy(self, runner):
        """Make sure that invoking the command passes without exception."""
        result = runner()
        assert result.exit_code == 0
