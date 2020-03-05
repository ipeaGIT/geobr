
from geobr.utils import select_metadata, download_gpkg


def read_conservation_units(date=201909, simplify=True, verbose=False):
    """ Download official data of Brazilian conservation untis as an sf object.
    
     This data set covers the whole of Brazil and it includes the polygons of all conservation untis present in Brazilian
 territory. The last update of the data was 09-2019. The original
 data comes from MMA and can be found at http://mapas.mma.gov.br/i3geo/datadownload.htm .

    Parameters
    ----------
    date : int, optional
        A date number in YYYYMM format, by default 201909
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
    >>> from geobr import read_conservation_units

    # Read specific state at a given year
    >>> df = read_conservation_units(date=201909)
    """

    metadata = select_metadata('conservation_units', year=date, simplify=simplify)

    gdf = download_gpkg(metadata)

    return gdf