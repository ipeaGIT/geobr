
from geobr.utils import select_metadata, download_gpkg


def read_immediate_region(code_immediate='all', 
                          year=2017, 
                          simplified=True, 
                          verbose=False
    ):
    """ Download shape files of Brazil's Immediate Geographic Areas as sf objects
    
     The Immediate Geographic Areas are part of the geographic division of 
     Brazil created in 2017 by IBGE to replace the "Micro Regions" division. 
     Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" 
     and CRS(4674)

    Parameters
    ----------
    code_immediate: 
        6-digit code of an immediate region. If the two-digit code or a 
        two-letter uppercase abbreviation of a state is passed, (e.g. 33 or 
        "RJ") the function will load all immediate regions of that state. If 
        code_immediate="all", all immediate regions of the country are loaded 
        (defaults to "all").
    year : int, optional
        Year of the data, by default 2017
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
    >>> from geobr import read_immediate_region

    # Read specific state at a given year
    >>> df = read_immediate_region(year=2017)
    """

    metadata = select_metadata('immediate_regions', year=year, simplified=simplified)

    gdf = download_gpkg(metadata)

    if code_immediate == 'all':

        if verbose:
            print('Loading data for the whole country. '
                  'This might take a few minutes.\n')

        return gdf
    
    elif code_immediate in gdf['abbrev_state'].tolist():

        return gdf.query(f'abbrev_state == "{code_immediate}"')

    elif code_immediate in gdf['code_state'].tolist():

        return gdf.query(f'code_state == "{code_immediate}"')

    elif code_immediate in gdf['code_immediate'].tolist():

        return gdf.query(f'code_immediate == "{code_immediate}"')
    
    else:

        raise Exception("Invalid Value to argument 'code_immediate'")