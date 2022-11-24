#! /usr/bin/env bash

printStatus() {
    status=$1

    [ "$status" -eq 0 ] && echo -en "\x1b[32mpass\x1b[0m" || echo -en "\x1b[31mfail\x1b[0m"
}

standardTests() (
    set +e
    echo -e "\n\x1b[1;36mBlack:\x1b[0m"
    black --check . 2>&1 | sed 's/^/  /'
    blackStatus=$?

    echo -e "\n\x1b[1;36mIsort:\x1b[0m"
    isort --check . 2>&1 | sed 's/^/  /'
    isortStatus=$?

    echo -e "\n\x1b[1;36mPylint:\x1b[0m"
    # shellcheck disable=SC2046
    pylint $(find . -name '*.py') 2>&1 | sed 's/^/  /'
    pylintStatus=$?

    echo -e "\n\x1b[1;36mFlake8:\x1b[0m"
    flake8 . 2>&1 | sed 's/^/  /'
    flake8Status=$?

    echo -e "\n\x1b[1;36mMypy:\x1b[0m"
    mypy . 2>&1 | sed 's/^/  /'
    mypyStatus=$?

    echo -e "\n\x1b[1;36mPytest:\x1b[0m"
    pytest . 2>&1 | sed 's/^/  /'
    pytestStatus=$?

    # no tests ran
    if [ $pytestStatus -eq 5 ]; then
        pytestStatus=0
    fi

    echo -e "Summary:
  black: $(printStatus $blackStatus)
  isort: $(printStatus $isortStatus)
  pylint: $(printStatus $pylintStatus)
  flake8: $(printStatus $flake8Status)
  mypy: $(printStatus $mypyStatus)
  pytest: $(printStatus $pytestStatus)"

    exit $((blackStatus + isortStatus + pylintStatus + flake8Status + mypyStatus + pytestStatus))
)

# If there is a checkPhase declared, mk-python-component in nixpkgs will put it in
# installCheckPhase so we use that phase as well (since this is executed later).
if [ -n "${doStandardTests-}" ] && [ -z "${installCheckPhase-}" ]; then
    installCheckPhase=standardTests
fi
