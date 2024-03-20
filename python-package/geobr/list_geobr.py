from requests import get
import pandas as pd
from io import StringIO
from urllib.error import HTTPError


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
        html_data = get("https://github.com/ipeaGIT/geobr/blob/master/README.md").text

        df = pd.read_html(StringIO(html_data))[1]

    except HTTPError:
        print(
            "Geobr url functions list is broken"
            'Please report an issue at "https://github.com/ipeaGIT/geobr/issues"'
        )

    for i in range(len(df)):
        for each in df.columns:
            print(f"{each}: {df.loc[i, each]}")

        print("------------------------------")
