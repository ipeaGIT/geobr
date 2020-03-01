
from geobr.utils import select_metadata, download_gpkg


def read_metro_area(year=2018, tp='simplified', verbose=False):
    """ Download shape files of official metropolitan areas in Brazil as an sf object.
    
     The function returns the shapes of municipalities grouped by their respective metro areas.
 Metropolitan areas are created by each state in Brazil. The data set includes the municipalities that belong to
 all metropolitan areas in the country according to state legislation in each year. Orignal data were generated
 by Institute of Geography. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).

    Parameters
    ----------
    year : int, optional
        Year of the data, by default 2018
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
    >>> from geobr import read_metro_area

    # Read specific state at a given year
    >>> df = read_metro_area(year=2018)
    """

    metadata = select_metadata('metropolitan_area', year=year, data_type=tp)

    gdf = download_gpkg(metadata)

    return gdf