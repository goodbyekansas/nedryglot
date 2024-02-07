#! /usr/bin/env bash
# Shellcheck has some false positives
# seems to be multiple issues on github
# so ignore for now. Please retest later.
# shellcheck disable=SC2030,SC2031

printStatus() {
    case "$1" in
        0)
            echo -en "\x1b[32mpass\x1b[0m"
            ;;
        skipped)
            echo -en "\x1b[33mskipped\x1b[0m"
            ;;
        *)
            echo -en "\x1b[31mfail\x1b[0m"
            ;;
    esac
}

runTool() {
    local tool
    tool="$1"
    shift 1

    local displayTool
    displayTool="$1"
    shift 1

    local disableVar
    disableVar="dontRun${tool^}"
    local statusVar
    statusVar="${tool}Status"

    if [ -z "${!disableVar:-}" ] && [[ "$(command -v "$tool")" =~ ^/nix/store/.*$ ]]; then
        echo -e "\n\x1b[1;36m${displayTool^}:\x1b[0m"
        "$tool" "$@" 2>&1 | sed 's/^/  /'
        declare -xg "$statusVar"=$?
    else
        echo "$tool is disabled."
    fi
}

standardTests() (
    # clean up after pip
    rm -rf build/

    set +e
    set -o pipefail

    # shellcheck disable=SC2086
    runTool black black ${blackArgs:-} --check .

    # shellcheck disable=SC2086
    runTool isort isort ${isortArgs:-} --check .

    # shellcheck disable=SC2046,SC2086
    HOME=$TMP runTool pylint pylint ${pylintArgs:-} --recursive=y .

    # shellcheck disable=SC2086
    runTool flake8 flake8 ${flake8Args:-} .

    # shellcheck disable=SC2086
    runTool mypy mypy ${mypyArgs:-} .

    # shellcheck disable=SC2086
    runTool pytest pytest ${pytestArgs:-} .

    # no tests ran
    if [ "${pytestStatus:-0}" -eq 5 ]; then
        local pytestStatus
        pytestStatus=0
    fi

    echo -e "Summary:
  black: $(printStatus "${blackStatus:-skipped}")
  isort: $(printStatus "${isortStatus:-skipped}")
  pylint: $(printStatus "${pylintStatus:-skipped}")
  flake8: $(printStatus "${flake8Status:-skipped}")
  mypy: $(printStatus "${mypyStatus:-skipped}")
  pytest: $(printStatus "${pytestStatus:-skipped}")"

    : "${blackStatus:=0}" "${isortStatus:=0}" "${pylintStatus:=0}"
    : "${flake8Status:=0}" "${mypyStatus:=0}" "${pytestStatus:=0}"
    exit $((blackStatus + isortStatus + pylintStatus + flake8Status + mypyStatus + pytestStatus))
)

ruffStandardTests() (
    # clean up after pip
    rm -rf build/

    set +e
    set -o pipefail

    # shellcheck disable=SC2086
    runTool ruff "Ruff Check" check ${ruffArgs:-} .
    local ruffCheckStatus
    ruffCheckStatus=${ruffStatus:-}

    # shellcheck disable=SC2086
    runTool ruff "Ruff Check Imports" check ${ruffArgs:-} --select I --diff .
    local ruffImportsStatus
    ruffImportsStatus=${ruffStatus:-}

    # shellcheck disable=SC2086
    runTool ruff "Ruff Format" format --diff ${ruffArgs:-} .
    local ruffFormatStatus
    ruffFormatStatus=${ruffStatus:-}

    # shellcheck disable=SC2086
    runTool mypy mypy ${mypyArgs:-} .

    # shellcheck disable=SC2086
    runTool pytest pytest ${pytestArgs:-} .

    # no tests ran
    if [ "${pytestStatus:-0}" -eq 5 ]; then
        local pytestStatus
        pytestStatus=0
    fi

    echo -e "Summary:
  ruff check: $(printStatus "${ruffCheckStatus:-skipped}")
  ruff imports: $(printStatus "${ruffImportsStatus:-skipped}")
  ruff format: $(printStatus "${ruffFormatStatus:-skipped}")
  mypy: $(printStatus "${mypyStatus:-skipped}")
  pytest: $(printStatus "${pytestStatus:-skipped}")"

    : "${ruffCheckStatus:=0}" "${ruffFormatStatus:=0}"
    : "${mypyStatus:=0}" "${pytestStatus:=0}" "${ruffImportsStatus:=0}"
    exit $((ruffCheckStatus + ruffFormatStatus + mypyStatus + pytestStatus + ruffImportsStatus))
)

# If there is a checkPhase declared, mk-python-component in nixpkgs will put it in
# installCheckPhase so we use that phase as well (since this is executed later).
if [ -n "${doStandardTests-}" ] && [ -z "${installCheckPhase-}" ]; then
    installCheckPhase=@defaultCheckPhase@
fi

runStandardFormat() {
    black .
    isort .
}

runRuffFormat() {
    ruff format .
    ruff check --select I --fix .
}

runFormat() {
    if [ "${formatter:-}" = "standard" ]; then
        runStandardFormat
    elif [ "${formatter:-}" = "ruff" ] || [[ "${installCheckPhase:-}" =~ "ruffStandardTests" ]]; then
        runRuffFormat
    else
        runStandardFormat
    fi
}
