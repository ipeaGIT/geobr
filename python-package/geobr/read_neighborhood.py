
from geobr.utils import select_metadata, download_gpkg


def read_neighborhood(year=2010, simplified=True, verbose=False):
    """ Download neighborhood limits of Brazilian municipalities as a geopandas geodataframe object
    
    Parameters
    ----------
    year : int, optional
        Year of the data, by default 2010
    simplified: boolean, by default True
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
    >>> from geobr import read_neighborhood

    # Read specific neighborhoods at a given year
    >>> df = read_neighborhood(year=2010)
    """

    metadata = select_metadata('neighborhood', year=year, simplified=simplified)

    gdf = download_gpkg(metadata)

    return gdf