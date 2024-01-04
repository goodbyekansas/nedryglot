""" Tests for ormgrop in ormgrop """
import pytest

import ormgrop.main


def test_main() -> None:
    """Tests for the main function"""
    with pytest.raises(NotImplementedError):
        ormgrop.main.main()
