from requests import get
from requests.exceptions import RequestException
import pandas as pd

README_URL = "https://raw.githubusercontent.com/ipeaGIT/geobr/master/README.md"
DATASETS_TABLE_HEADER = "| Function | Geographies available | Source | Years available |"


def _split_markdown_row(row):
    return [cell.strip() for cell in row.strip().strip("|").split("|")]


def _parse_available_datasets(readme_data):
    lines = readme_data.splitlines()

    for index, line in enumerate(lines):
        if line.strip() != DATASETS_TABLE_HEADER:
            continue

        columns = _split_markdown_row(line)
        rows = []

        for row in lines[index + 2 :]:
            if not row.strip().startswith("|"):
                break

            values = _split_markdown_row(row)

            if len(values) == len(columns):
                rows.append(dict(zip(columns, values)))

        if rows:
            return pd.DataFrame(rows)

    raise ValueError("Could not find geobr datasets table in README.md")


def list_geobr():
    """Prints available functions, according to latest README.md file

    Example output
    ------------------------------
    Function: read_immediate_region
    Geographies available: Immediate region
    Years available: 2017
    Source: IBGE
    ------------------------------

    """

    try:
        response = get(README_URL, timeout=10)
        response.raise_for_status()
        df = _parse_available_datasets(response.text)
    except (RequestException, ValueError):
        print(
            "Geobr url functions list is broken. "
            'Please report an issue at "https://github.com/ipeaGIT/geobr/issues"'
        )
        return

    for i in range(len(df)):
        for each in df.columns:
            print(f"{each}: {df.loc[i, each]}")

        print("------------------------------")
