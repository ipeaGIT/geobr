
from geobr.utils import select_metadata, download_gpkg


def read_schools(year=2020, simplified=True, verbose=False):
    r""" Download geolocated data of schools
    
     @description
 Data comes from the School Census collected by INEP, the National Institute
 for Educational Studies and Research Anisio Teixeira. The date of the last
 data update is registered in the database in the column 'date_update'. These
 data uses Geodetic reference system "SIRGAS2000" and CRS(4674). The coordinates
 of each school if collected by INEP. Periodically the coordinates are revised
 with the objective of improving the quality of the data. More information
 available at \url{https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/inep-data/catalogo-de-escolas/}

    Parameters
    ----------
    year : int, optional
        Year of the data, by default 2020
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
    >>> from geobr import read_schools

    # Read specific state at a given year
    >>> df = read_schools(year=2020)
    """

    metadata = select_metadata('schools', year=year, simplified=simplified)

    gdf = download_gpkg(metadata)

    return gdf