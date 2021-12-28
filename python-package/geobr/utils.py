import os
from functools import lru_cache
from urllib.error import HTTPError

import geopandas as gpd
import pandas as pd
import requests
import unicodedata

from geobr.constants import DataTypes


def _get_unique_values(_df, column):

    return ", ".join([str(i) for i in _df[column].unique()])


@lru_cache(maxsize=124)
def download_metadata(url="http://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv"):
    """Support function to download metadata internally used in geobr.

    It caches the metadata file to avoid reloading it in the same session.

    Parameters
    ----------
    url : str, optional
        Metadata url, by default 'http://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'

    Returns
    -------
    pd.DataFrame
        Table with all metadata of geopackages

    Raises
    ------
    Exception
        Leads user to Github issue page if metadata url is not found

    Examples
    --------
    >>> metadata = download_metadata()
    >>> metadata.head(1)
                  geo  year code                                      download_path      code_abrev
    0  amazonia_legal  2012   am  http://www.ipea.gov.br/geobr/data_gpkg/amazoni...  amazonia_legal
    """

    try:
        return pd.read_csv(url)

    except HTTPError:
        raise Exception(
            "Perhaps this is an internet connection problem."
            "If this is not a connection problem in your network, "
            " please try geobr again in a few minutes. "
            "Please report to https://github.com/ipeaGIT/geobr/issues"
        )


def select_year(metadata, year):
    """Apply year to metadata and checks its existence.

    If it do not exist, raises an informative error.

    Parameters
    ----------
    metadata : pd.DataFrame
        Filtered metadata table
    year : int
        Year selected by user

    Returns
    -------
    pd.DataFrame
        Filtered dataframe by year.

    Raises
    ------
    Exception
        If year does not exists, raises exception with available years.
    """

    if year is None:
        year = max(metadata["year"])

    elif year not in list(metadata["year"]):

        years = ", ".join([str(i) for i in metadata["year"].unique()])

        raise Exception(
            "Error: Invalid Value to argument year. "
            "It must be one of the following: "
            f'{_get_unique_values(metadata, "year")}'
        )

    return metadata.query(f"year == {year}")


def select_simplified(metadata, simplified):
    """Filter metadata by data type. It can be simplified or normal.
    If 'simplified' is True, it returns a simplified version of the shapefiles.
    'normal' returns the complete version. Usually, the complete version
    if heavier than the simplified, demanding more resources.

    Parameters
    ----------
    metadata : pd.DataFrame
        Filtered metadata table
    simplified : boolean
        Data type, either True for 'simplified' or False for 'normal'

    Returns
    -------
    pd.DataFrame
        Filtered metadata table by type

    """

    if simplified:
        return metadata[metadata["download_path"].str.contains("simplified")]

    else:
        return metadata[~metadata["download_path"].str.contains("simplified")]


@lru_cache(maxsize=1240)
def load_gpkg(url):
    """Internal function to donwload and convert to geopandas one url.

    It caches url result for the active session.

    Parameters
    ----------
    url : str
        Address with gpkg

    Returns
    -------
    gpd.GeoDataFrame
         Table with metadata and shapefiles contained in url.
    """

    try:
        content = requests.get(url).content

    except Exception as e:

        raise Exception(
            "Some internal url is broken."
            "Please report to https://github.com/ipeaGIT/geobr/issues"
        )

    # This below does not work in Windows -- see the Docs
    # Whether the name can be used to open the file a second time, while the named temporary file is still open,
    # varies across platforms (it can be so used on Unix; it cannot on Windows NT or later).
    # https://docs.python.org/2/library/tempfile.html

    # with tempfile.NamedTemporaryFile(suffix='.gpkg') as fp:
    with open("temp.gpkg", "wb") as fp:

        fp.write(content)

        gdf = gpd.read_file(fp.name)

    os.remove("temp.gpkg")

    return gdf


def enforce_types(df):
    """Enforce correct datatypes according to DataTypes constant

    Parameters
    ----------
    df : gpd.GeoDataFrame
        Raw output data

    Returns
    -------
    gpd.GeoDataFrame
        Output data with correct types
    """

    for column in df.columns:

        if column in DataTypes.__members__.keys():

            df[column] = df[column].astype(DataTypes[column].value)

    return df


def download_gpkg(metadata):
    """Generalizes gpkg dowload and conversion to geopandas
    for one or many urls

    Parameters
    ----------
    metadata : pd.DataFrame
        Filtered metadata

    Returns
    -------
    gpd.GeoDataFrame
        Table with metadata and shapefiles contained in urls.
    """

    urls = metadata["download_path"].tolist()

    gpkgs = [load_gpkg(url) for url in urls]

    df = gpd.GeoDataFrame(pd.concat(gpkgs, ignore_index=True))

    df = enforce_types(df)

    return df


def select_metadata(geo, simplified=None, year=False):
    """Downloads and filters metadata given `geo`, `simplified` and `year`.

    Parameters
    ----------
    geo : str
        Shapefile category. I.e: state, biome, etc...
    simplified : boolean
        `simplified` or `normal` shapefiles
    year : int
        Year of the data

    Returns
    -------
    pd.DataFrame
        Filtered metadata

    Raises
    ------
    Exception
        if a parameter is not found in metadata table
    """

    # Get metadata with data addresses
    metadata = download_metadata()

    if len(metadata.query(f'geo == "{geo}"')) == 0:
        raise Exception(
            f"The `geo` argument {geo} does not exist."
            "Please, use one of the following:"
            f'{_get_unique_values(metadata, "geo")}'
        )

    # Select geo
    metadata = metadata.query(f'geo == "{geo}"')

    if simplified is not None:
        # Select data type
        metadata = select_simplified(metadata, simplified)

    if year != False:
        # Verify year input
        metadata = select_year(metadata, year)

    return metadata


def change_type_list(lst, astype=str):
    return [astype(l) for l in lst]


def test_options(choosen, name, allowed=None, not_allowed=None):

    if allowed is not None:
        if choosen not in allowed:
            raise Exception(
                f"Invalid value to argument '{name}'. "
                f"It must be either {' or '.join(change_type_list(allowed))}"
            )

    if not_allowed is not None:
        if choosen in not_allowed:
            raise Exception(
                f"Invalid value to argument '{name}'. "
                f"It cannot be {' or '.join(change_type_list(allowed))}"
            )


def strip_accents(text):
    """
    Strip accents from input String.

    Parameters
    ----------
    text: str, The input string

    Returns
    ----------
    str, The processed string
    """
    text = unicodedata.normalize("NFD", text)
    text = text.encode("ascii", "ignore")
    text = text.decode("utf-8")
    return str(text)
