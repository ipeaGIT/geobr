from jinja2 import Template
from itertools import takewhile
from pathlib import Path
import sys
import re

from fire import Fire


def get_R_parameters(config, path):

    r_code = open(path / f'{config["name"]}.R', "r").read()

    config["first_liner"] = r_code.split("\n")[0].strip("#'")

    config["documentation"] = "\n".join(
        [
            s.strip("#'")
            for s in (takewhile(lambda x: x != "#'", r_code.split("\n")[2:]))
        ]
    )

    try:
        config["default_year"] = [
            re.search(r"\d+", s).group(0)
            for s in r_code.split("\n")
            if "@param year" in s
        ][0]
    except:
        pass

    config["metadata_key"] = [
        re.search(r'"([A-Za-z0-9_\./\\-]*)"', s).group(0).strip('"')
        for s in r_code.split("\n")
        if "select_metadata(geography=" in s
    ][0]

    return config


def create_file_from_template(kind, config, path=Path("helpers/template")):

    temp = open(path / (kind + ".py"), "r").read()

    temp = Template(temp).render(**config)

    if kind == "function":
        open(f'geobr/{config["name"]}.py', "w").write(temp)

    elif kind == "test":
        open(f'tests/test_{config["name"]}.py', "w").write(temp)


def main(name, overwrite=False):

    config = {"name": name}

    geobr_path = Path(__file__).absolute().parent.parent.parent

    if (geobr_path / f'{config["name"]}.py').exists() and not overwrite:
        raise Exception(
            f"Function already translated." "Pass --overwrite flag to overwrite file"
        )

    try:
        config = get_R_parameters(config, geobr_path / "r-package/R/")

    except FileNotFoundError:
        raise Exception(f"Function {name} was not implemented in R")

    create_file_from_template("function", config)
    create_file_from_template("test", config)

    open("geobr/__init__.py", "a").write(f"\nfrom .{name} import {name}")


if __name__ == "__main__":

    Fire(main)
