
from geobr.utils import select_metadata, download_gpkg


def read_amazon(year=2012, simplify=True, verbose=False):
    """ Download official data of Brazil's Legal Amazon as an sf object.
    
     This data set covers the whole of Brazil's Legal Amazon as defined in the federal law n. 12.651/2012). The original
 data comes from the Brazilian Ministry of Environment (MMA) and can be found at http://mapas.mma.gov.br/i3geo/datadownload.htm .

    Parameters
    ----------
    year : int, optional
        Year of the data, by default 2012
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
    >>> from geobr import read_amazon

    # Read specific state at a given year
    >>> df = read_amazon(year=2012)
    """

    metadata = select_metadata('amazonia_legal', year=year, simplify=simplify)

    gdf = download_gpkg(metadata)

    return gdf