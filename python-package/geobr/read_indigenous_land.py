
from geobr.utils import select_metadata, download_gpkg


def read_indigenous_land(date=201907, tp='simplified', verbose=False):
    """ Download official data of indigenous lands as an sf object.
    
     The data set covers the whole of Brazil and it includes indigenous lands from all ethnicities and
 in different stages of demarcation. The original data comes from the National Indian Foundation (FUNAI)
 and can be found at http://www.funai.gov.br/index.php/shape. Although original data is updated monthly,
 the geobr package will only keep the data for a few months per year.

    Parameters
    ----------
    date : int, optional
        A date numer in YYYYMM format, by default 201907
    tp : str, optional
        Data 'type', indicating whether the function returns the 'original' dataset 
        with high resolution or a dataset with 'simplified' borders (Default)
    verbose : bool, optional
        by default False
    
    Returns
    -------
    gpd.GeoDataFrame
        Metadata and geopackage of selected states
    
    Raises
    ------
    Exception
        If parameters are not found or not well defined

    Example
    -------
    >>> from geobr import read_indigenous_land

    # Read specific state at a given year
    >>> df = read_indigenous_land(date=201907)
    """

    metadata = select_metadata('indigenous_land', year=date, data_type=tp)

    gdf = download_gpkg(metadata)

    return gdf