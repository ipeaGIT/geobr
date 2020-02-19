import requests
import pandas as pd
import tempfile
import geopandas as gpd
from functools import lru_cache
import os


def _get_unique_values(_df, column):

    return ', '.join([str(i) for i in _df['{column}'].unique()])


@lru_cache(maxsize=124)
def download_metadata(
    url='http://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'):
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
        raise Exception('Metadata file not found. \
            Please report to https://github.com/ipeaGIT/geobr/issues')


def apply_year(metadata, year):
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
        year = max(metadata['year'])
      
    elif year not in list(metadata['year']):

        years = ', '.join([str(i) for i in metadata['year'].unique()])

        raise Exception('Error: Invalid Value to argument year. '
                        'It must be one of the following: '
                        f'{_get_unique_values[metadata, "year"]}'
                        )
    
    return metadata.query(f'year == {year}')


def apply_data_type(metadata, data_type):
    """Filter metadata by data type. It can be simplified or normal. 
    The 'simplified' returns a simplified version of the shapefiles.
    'normal' returns the complete version. Usually, the complete version
    if heavier than the simplified, demanding more resources.

    If tp is not found, raises informative error
    
    Parameters
    ----------
    metadata : pd.DataFrame
        Filtered metadata table
    tp : str
        Data type, either 'simplified' or 'normal'
    
    Returns
    -------
    pd.DataFrame
        Filtered metadata table by type
    
    Raises
    ------
    Exception
        If 'tp' is not found.
    """

    if data_type == "simplified":    
        return metadata[metadata['download_path'].str.contains("simplified")]
    
    elif data_type == "normal":
        return metadata[~metadata['download_path'].str.contains("simplified")]
    
    else:
        raise Exception("Error: Invalid Value to argument 'tp'. \
                        It must be 'simplified' or 'normal'")


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
            'Some internal url is broken.'
            'Please report to https://github.com/ipeaGIT/geobr/issues'
        )

    # This below does not work in Windows -- see the Docs
    # Whether the name can be used to open the file a second time, while the named temporary file is still open,
    # varies across platforms (it can be so used on Unix; it cannot on Windows NT or later).
    # https://docs.python.org/2/library/tempfile.html

    # with tempfile.NamedTemporaryFile(suffix='.gpkg') as fp:
    with open('temp.gpkg', 'wb') as fp:

        fp.write(content)

        gdf = gpd.read_file(fp.name)

    os.remove('temp.gpkg')
        
    return gdf


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
    
    urls = metadata['download_path'].tolist()

    gpkgs = [load_gpkg(url) for url in urls]
    
    return gpd.GeoDataFrame(pd.concat(gpkgs, ignore_index=True))


def get_metadata(geo, data_type, year):
    """Downloads and filters metadata given `geo`, `data_type` and `year`.
    
    Parameters
    ----------
    geo : str
        Shapefile category. I.e: state, biome, etc...
    data_type : str
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
            f'The `geo` argument {geo} does not exist.'
            'Please, use one of the following:'
            f'{_get_unique_values[metadata, "geo"]}'
    )

    # Select geo
    metadata = metadata.query(f'geo == "{geo}"')

    # Select data type
    metadata = apply_data_type(metadata, data_type)
    
    # Verify year input
    metadata = apply_year(metadata, year)

    return metadata
