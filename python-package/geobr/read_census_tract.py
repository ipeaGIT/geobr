
from geobr.utils import select_metadata, download_gpkg, test_options


def read_census_tract(code_tract, year=2010, zone='urban', simplified=True, verbose=False):
    """ Download shape files of census tracts of the Brazilian Population Census (Only years 2000 and 2010 are currently available).
    
    Parameters
    ----------
    code_tract: int
        The 7-digit code of a Municipality. If the two-digit code or a two-letter uppercase abbreviation of
        a state is passed, (e.g. 33 or "RJ") the function will load all census tracts of that state. If code_tract="all",
        all census tracts of the country are loaded.
    year : int, optional
        Year of the data, by default 2010
    zone: string, optional
        "urban" or "rural" census tracts come in separate files in the year 2000, by default urban
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
    >>> from geobr import read_census_tract

    # Read rural census tracts for years before 2007
    >>> df = read_census_tract(code_tract=5201108, year=2000, zone='rural')


    # Read all census tracts of a state at a given year
    >>> df = read_census_tract(code_tract=53, year=2010) # or
    >>> df = read_census_tract(code_tract="DF", year=2010)
       
    # Read all census tracts of a municipality at a given year
    >>> df = read_census_tract(code_tract=5201108, year=2010)

    # Read all census tracts of the country at a given year
    >>> df = read_census_tract(code_tract="all", year=2010)

    """

    test_options(zone, 'zone', allowed=['urban', 'rural'])
    test_options(code_tract, 'code_tract', not_allowed=[None])

    metadata = select_metadata('census_tract', year=year, simplified=simplified)

    # For year <= 2007, the code, eg. U11, comes with a trailing letter U for urban and
    # R for rural. So, this code checks if the trailing code letter is the same as
    # the argument zone. 
    if year <= 2007:
        
        metadata = metadata[metadata['code'].apply(
                    lambda x: x[0].lower() == zone[0].lower())]
                            #    [R]12      ==     [r]ural

    if code_tract == 'all':

        if verbose:
            print('Loading data for the whole country. This might take a few minutes.')

        return download_gpkg(metadata)

    else:
        
        metadata = metadata[metadata[['code', 'code_abrev']].apply(lambda x: 
                                                                str(code_tract)[:2] in str(x['code']) or    # if number e.g. 12
                                                                str(code_tract)[:2] in str(x['code_abrev']) # if UF e.g. RO
                                                                , 1)]

    gdf = download_gpkg(metadata)
    
    if len(str(code_tract)) == 2:
        return gdf
    
    elif  code_tract in gdf['code_muni'].tolist():
        return gdf.query(f'code_muni == {code_tract}')
    
    else:
        raise Exception('Invalid Value to argument code_tract.')

