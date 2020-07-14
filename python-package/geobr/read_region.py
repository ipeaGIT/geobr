from geobr.utils import select_metadata, download_gpkg


def read_region(year=2010, simplified=True, verbose=False):
    """ Download shape file of Brazil Regions as sf objects.
    
     Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)

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
    >>> from geobr import read_region

    # Read specific state at a given year
    >>> df = read_region(year=2010)
    """

    metadata = select_metadata("regions", year=year, simplified=simplified)

    gdf = download_gpkg(metadata)

    return gdf
