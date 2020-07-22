from geobr.utils import select_metadata, download_gpkg


def read_semiarid(year=2017, simplified=True, verbose=False):
    """ Download official data of Brazilian Semiarid as an sf object.
    
     This data set covers the whole of Brazilian Semiarid as defined in the resolution in  23/11/2017). The original
 data comes from the Brazilian Institute of Geography and Statistics (IBGE) and can be found at https://www.ibge.gov.br/geociencias/cartas-e-mapas/mapas-regionais/15974-semiarido-brasileiro.html?=&t=downloads

    Parameters
    ----------
    year : int, optional
        Year of the data, by default 2017
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
    >>> from geobr import read_semiarid

    # Read specific state at a given year
    >>> df = read_semiarid(year=2017)
    """

    metadata = select_metadata("semiarid", year=year, simplified=simplified)

    gdf = download_gpkg(metadata)

    return gdf
