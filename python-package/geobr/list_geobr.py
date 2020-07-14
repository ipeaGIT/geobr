import pandas as pd
from urllib.error import HTTPError


def list_geobr():
    """ Prints available functions, according to latest README.md file

        Example output
        ------------------------------
        Function: read_immediate_region
        Geographies available: Immediate region
        Years available: 2017
        Source: IBGE
        ------------------------------

    """

    try:
        df = pd.read_html("https://github.com/ipeaGIT/geobr/blob/master/README.md")[1]

    except HTTPError:
        print(
            "Geobr url functions list is broken"
            'Please report an issue at "https://github.com/ipeaGIT/geobr/issues"'
        )

    for i in range(len(df)):
        for each in df.columns:
            print(f"{each}: {df.loc[i, each]}")

        print("------------------------------")
