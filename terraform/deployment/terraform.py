"""
Terraform deployment wrapper
"""

import argparse
import os
import pathlib
import shutil
import signal
import subprocess
import sys
import time
import types
import typing

"""Have we received an abort signal (SIGINT/SIGTERM)?"""
abort_requested: bool = False

def _setup_sources(source: pathlib.Path) -> None:
    shutil.copytree(src=source, dst=os.getcwd(), dirs_exist_ok=True)
    os.chmod(path=os.getcwd(), mode=0o755)
    for root, dirs, _ in os.walk(os.getcwd()):
        for content in dirs:
            os.chmod(path=os.path.join(root, content), mode=0o755)


def _handle_termination(signum: int, frame: typing.Optional[types.FrameType]):
    # Make sure we always wait for terraform to exit
    # so it can remove lock files and exit cleanly.
    print(f"Abort requested ({signal.strsignal(signum)}).")
    global abort_requested
    abort_requested = True


def _run_terraform(command: str, args: typing.List[str] = None) -> None:
    global abort_requested
    if abort_requested:
        raise subprocess.CalledProcessError(1, "did-not-start-terraform")

    aborted = False
    cmd = ["terraform", command, "-lock-timeout=300s", "-input=false"] + (args or [])
    with subprocess.Popen(cmd, start_new_session=True) as process:
        while process.poll() is None:
            if abort_requested:
                os.killpg(os.getpgid(process.pid), signal.SIGINT)
                abort_requested = False
                aborted = True
                print("Waiting for terraform to exit")

            time.sleep(0.25)

        # terraform returns 0 when aborted via SIGINT
        if aborted:
            raise subprocess.CalledProcessError(-signal.SIGINT, " ".join(cmd))
        elif process.returncode != 0:
            raise subprocess.CalledProcessError(process.returncode, " ".join(cmd))


def apply(args: argparse.Namespace) -> None:
    """
    Applies the terraform plan
    """
    _setup_sources(source=args.source)
    _run_terraform(command="init")
    _run_terraform(command="apply", args=["-auto-approve"])


def plan(args: argparse.Namespace) -> None:
    """
    Plans the terraform
    """
    _setup_sources(source=args.source)
    _run_terraform(command="init")
    _run_terraform(
        command="plan",
        args=["-no-color"] + ([f"-out={args.out}"] if args.out else []),
    )


def main() -> None:
    """
    The main method of this program. Pls use as entrypoint.
    """
    parser = argparse.ArgumentParser(description="Terraform deployment wrapper")
    subparsers = parser.add_subparsers(
        help="sub-command help", title="Sub commands", dest="subcommand"
    )

    parser.add_argument(
        "--source", type=str, help="Path to the terraform sources", required=True
    )
    sub_apply = subparsers.add_parser("apply", help="Applies the terraform plan.")
    sub_apply.set_defaults(func=apply)

    sub_plan = subparsers.add_parser(
        "plan", help="Creates a terraform plan without applying anything."
    )
    sub_plan.add_argument(
        "--out", type=str, help="Path to output terraform plan, default is stdout"
    )
    sub_plan.set_defaults(func=plan)

    args = parser.parse_args()

    signal.signal(signal.SIGTERM, _handle_termination)
    signal.signal(signal.SIGINT, _handle_termination)

    try:
        if args.subcommand is None:
            apply(args)
        else:
            args.func(args)
    except subprocess.CalledProcessError as cpe:
        print(f"Failed to run terraform: {cpe}")
        sys.exit(cpe.returncode)


if __name__ == "__main__":
    main()
