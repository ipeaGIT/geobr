from requests import get
import pandas as pd
from io import StringIO
from urllib.error import HTTPError
import re

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
        find_emoji = html_data.index("👉")
        html_data =  html_data[find_emoji:]
        escaped_data = html_data.replace("\\u003c", "<").replace("\\u003e", ">")
        tables = re.findall("<table>(.+?)</table>", escaped_data)
        available_datasets = "<table>" + tables[0].replace("\\n", "") + "</table>"
        df = pd.DataFrame(pd.read_html(StringIO(available_datasets))[0])

    except HTTPError:
        print(
            "Geobr url functions list is broken"
            'Please report an issue at "https://github.com/ipeaGIT/geobr/issues"'
        )

    for i in range(len(df)):
        for each in df.columns:
            print(f"{each}: {df.loc[i, each]}")

        print("------------------------------")
