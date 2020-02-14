import requests
import pandas as pd
import tempfile
from functools import lru_cache

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

def check_year(metadata, year=None):
    """Check if year exists in metadata.

    If it do not exist, raises an informative error.
    
    Parameters
    ----------
    metadata : pd.DataFrame
        Filtered metadata table
    year : int
        Year selected by user

    Returns
    -------
    int
        The last year if year is None. The inputed year, if it exists.
    
    Raises
    ------
    Exception
        If year does not exists, raises exception with available years.
    """
    

    if year is None:
        year = max(metadata['year'])
      
    elif not year in list(metadata['year']):

        raise Exception('Error: Invalid Value to argument year. \
                        It must be one of the following: ' + 
                        ', '.join([str (i) for i in metadata['year'].unique()]))
    return year
