
from geobr.utils import select_metadata, download_gpkg


def read_biomes(year=2019, simplified=True, verbose=False):
    """ Download official data of Brazilian biomes as an sf object.
    
     This data set includes  polygons of all biomes present in Brazilian territory and coastal area.
 The latest data set dates to 2019 and it is available at scale 1:250.000. The 2004 data set is at
 the scale 1:5.000.000. The original data comes from IBGE. More information at https://www.ibge.gov.br/apps/biomas/

    Parameters
    ----------
    year : int, optional
        Year of the data, by default 2019
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
    >>> from geobr import read_biomes

    # Read specific state at a given year
    >>> df = read_biomes(year=2019)
    """

    metadata = select_metadata('biomes', year=year, simplified=simplified)

    gdf = download_gpkg(metadata)

    return gdf