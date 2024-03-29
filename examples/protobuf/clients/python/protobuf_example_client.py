""" Example illustrating a transitive dependency on a protobuf module """
from diplodocus.foundation.core_pb2 import (  # pylint: disable=no-name-in-module
    DependOnMe,
)
from ext.ext_pb2 import DependingOnIt  # pylint: disable=no-name-in-module


def main() -> None:
    """Entrypoint"""
    sune = DependingOnIt(here=DependOnMe(yes="rune"))
    print(sune)


def test_main() -> None:
    """We just run main to see that the code is somewhat correct"""
    main()


if __name__ == "__main__":
    main()
