
from geobr.utils import select_metadata, download_gpkg


def read_country(year=2010, simplify=True, verbose=False):
    """ Download shape file of Brazil as sf objects. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
    
     @param year Year of the data (defaults to 2010)
 @param simplifyWhether the function returns the 'original' dataset with high resolution or a dataset with 'simplify' borders (Default)
 @param showProgress Logical. Defaults to (TRUE) display progress bar

    Parameters
    ----------
    year : int, optional
        Year of the data, by default 2010
    simplify: boolean, by default True
        Data 'type', indicating whether the function returns the 'original' dataset 
        with high resolution or a dataset with 'simplify' borders (Default)
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
    >>> from geobr import read_country

    # Read specific state at a given year
    >>> df = read_country(year=2010)
    """

    metadata = select_metadata('country', year=year, simplify=simplify)

    gdf = download_gpkg(metadata)

    return gdf