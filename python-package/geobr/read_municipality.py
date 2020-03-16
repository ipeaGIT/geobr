
from geobr.utils import select_metadata, download_gpkg


def read_municipality(code_muni='all', year=2010, simplified=True, verbose=False):
    """ Download shape files of Brazilian municipalities as sf objects.
    
     Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)

    Parameters
    ----------
    code_muni:
        The 7-digit code of a municipality. If the two-digit code or a two-letter uppercase abbreviation of
        a state is passed, (e.g. 33 or "RJ") the function will load all municipalities of that state. 
        If code_muni="all", all municipalities of the country will be loaded.
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
    >>> from geobr import read_municipality

    # Read specific meso region at a given year
    >>> df = read_municipality(code_muni=1200179, year=2018)

    # Read all meso regions of a state at a given year
    >>> df = read_municipality(code_muni=12, year=2017)
    >>> df = read_municipality(code_muni="AM", year=2000)

    # Read all meso regions of the country at a given year
    >>> df = read_municipality(code_muni="all", year=2010)
    """

    metadata = select_metadata('municipality', year=year, simplified=simplified)

    if year < 1992:

        return download_gpkg(metadata)

    if code_muni == 'all':

        if verbose:
            print('Loading data for the whole country. This might take a few minutes.')

        return download_gpkg(metadata)

    metadata = metadata[metadata[['code', 'code_abrev']].apply(lambda x: 
                                                    str(code_muni)[:2] in str(x['code']) or    # if number e.g. 12
                                                    str(code_muni)[:2] in str(x['code_abrev']) # if UF e.g. RO
                                                    , 1)]

    if not len(metadata):
        raise Exception('Invalid Value to argument code_muni.')
    
    gdf = download_gpkg(metadata)

    if len(str(code_muni)) == 2:
        return gdf

    elif  code_muni in gdf['code_muni'].tolist():
        return gdf.query(f'code_muni == {code_muni}')
    
    else:
        raise Exception('Invalid Value to argument code_muni.')
    return gdf