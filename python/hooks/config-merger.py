import argparse
import os
import sys
import re
from pathlib import Path
from configparser import ConfigParser

import toml


def merge(source: dict, destination: dict) -> dict:
    for key, value in source.items():
        if isinstance(value, dict):
            node = destination.setdefault(key, {})
            merge(value, node)
        else:
            destination[key] = value

    return destination


def change_header(config: dict, from_header: str, to_header: str) -> dict:
    sub_config = config
    if from_header:
        sub_keys = from_header.split(".")
        for sub_key in sub_keys:
            if _sub_config := sub_config.get(sub_key):
                sub_config = _sub_config
            else:
                return {}

    return {to_header: sub_config}


def parse_toml(config_file: str) -> dict:
    with open(config_file) as cfg:
        return toml.load(cfg)


def parse_ini(config_file: str) -> dict:
    config = ConfigParser()
    config.read(config_file)
    return config._sections


def parse_lists_for_toml(config_file) -> None:
    for key, value in config_file.items():
        if isinstance(value,str):
            arr = re.sub("\s*|\r?\n|#.*$", "", value, flags=re.MULTILINE).rstrip(",").split(",")

            if len(arr) > 1:
                config_file[key] = arr

        elif isinstance(value, dict):
            parse_lists_for_toml(value)


def fix_mypy_overrides(config_file, key, tool_name) -> None:
    overrides = config_file
    for v in key.split('.'):
        overrides = overrides.get(v)
        if overrides is None:
            return config_file

    root = {}
    for override in overrides:
        module_name = f'mypy-{override.pop("module")}'
        root.update({
            module_name: override,
        })

    return root

def clean_up_fields(read_config, config_file, key, remove_fields):
    if key in remove_fields and config_file in remove_fields[key]:
        for remove in remove_fields[key][config_file]:
            root = read_config
            split = remove.split('.')
            length = len(split)
            indexes = split[:length-1]
            to_remove = split[-1]
            for v in indexes:
                root = root.get(v)
                if root is None:
                    break
            else:
                root.pop(to_remove)

    return read_config

def parse_remove_fields(remove_fields_raw):
    remove_fields = {}
    for v in remove_fields_raw:
        split = v.split('=', 1)
        key_file = split[0]
        remove_values = split[1].split(',')
        split = key_file.split(':')
        key = split[0]
        config_file = split[1]

        remove_fields.setdefault(key, {
            config_file: [],
        })
        values = remove_fields.get(key).get(config_file)
        values.extend(remove_values)

    return remove_fields


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog='config-merger',
        description='Merges config files')
    parser.add_argument('-t', '--tool', help='The tool the config files are for')
    parser.add_argument('--remove-fields',
                        metavar="KEY=VALUES",
                        nargs='*',
                        help='Fields to be removed',
                        default=[])
    parser.add_argument('-f', '--files', nargs='+', default=[])
    args = parser.parse_args()
    tool_name = args.tool
    remove_fields = parse_remove_fields(args.remove_fields)

    combined_config = {}
    out_file = Path(os.environ["out"])

    for config_file, key in filter(
        lambda cfg: cfg[0].exists(),
        map(
            lambda item: (Path(item.split("=")[0]),
            item.split("=")[1]), args.files,
        ),
    ):
        print(f"Using {tool_name} settings from {config_file.absolute()}")
        match config_file.suffix:
            case ".toml":
                read_config = parse_toml(config_file)
            case _:
                read_config = parse_ini(config_file)
                if out_file.suffix == ".toml" and tool_name == "pylint":
                    parse_lists_for_toml(read_config)

        read_config = clean_up_fields(read_config, os.path.basename(config_file), key, remove_fields)

        if out_file.suffix != ".toml" and tool_name == "mypy" and key == "tool.mypy.overrides":
            read_config = fix_mypy_overrides(read_config, key, tool_name)
        else:
            read_config = change_header(read_config, key, tool_name)

        combined_config = merge(combined_config, read_config)

    with open(out_file, "w") as output_file:
        if out_file.suffix == ".toml":
            toml.dump({ "tool": combined_config }, output_file)
        else:
            config_parser = ConfigParser()
            config_parser.read_dict(combined_config)
            config_parser.write(output_file)

