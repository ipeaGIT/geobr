from geobr.utils import select_metadata, download_gpkg


def read_health_facilities(verbose=False):
    """ Download geolocated data of health facilities as an sf object.
    
     Data comes from the National Registry of Healthcare facilities (Cadastro Nacional de Estabelecimentos de Saude - CNES),
 originally collected by the Brazilian Ministry of Health. The date of the last data update is
 registered in the database in the columns 'date_update' and 'year_update'. These data uses Geodetic reference
 system "SIRGAS2000" and CRS(4674). The coordinates of each facility was obtained by CNES
 and validated by means of space operations. These operations verify if the point is in the
 municipality, considering a radius of 5,000 meters. When the coordinate is not correct,
 further searches are done in other systems of the Ministry of Health and in web services
 like Google Maps . Finally, if the coordinates have been correctly obtained in this process,
 the coordinates of the municipal head office are used. The final source used is registered
 in the database in a specific column 'data_source'. Periodically the coordinates are revised
 with the objective of improving the quality of the data. More information
 available at http://dados.gov.br/dataset/cnes

    Parameters
    ----------
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
    >>> from geobr import read_health_facilities

    # Read specific state at a given year
    >>> df = read_health_facilities()
    """

    metadata = select_metadata("health_facilities", year=2015, simplified=False)

    gdf = download_gpkg(metadata)

    return gdf
