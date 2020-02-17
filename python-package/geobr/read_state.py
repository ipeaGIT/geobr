
import geopandas as gpd

from geobr.utils import get_metadata, download_gpkg

def read_state(code_state, year=2010, tp="simplified", verbose=False):
    """Download shape files of Brazilian states as geopandas objects.

     Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
    
    Parameters
    ----------
    code_state : str
        The two-digit code of a state or a two-letter uppercase abbreviation 
        (e.g. 33 or "RJ"). If code_state="all", all states will be loaded.
    year : int, optional
        Year of the data, by default 2010
    tp : str, optional
        Shapefile type, by default "simplified"
    verbose : bool, optional
        by default False
    
    Returns
    -------
    gpd.GeoDataFrame
        Metadata and shapefile of selected states
    
    Raises
    ------
    Exception
        If parameters are not found or not well defined

    Example
    -------
    >>> from geobr import read_state

    # Read specific state at a given year
    >>> uf = read_state(code_state=12, year=2017)

     # Read specific state at a given year with normal shapefiles
    >>> uf = read_state(code_state="SC", year=2000, tp='normal')

     # Read all states at a given year
    >>> ufs = read_state(code_state="all", year=2010)
    """

    metadata = get_metadata('state', year=year, data_type=tp)
    
    if code_state is None:
        raise Exception("Value to argument 'code_state' cannot be None")

    # From 1872 to 1991 and all
    if (year < 1992) or (code_state == "all"):
        
        if verbose:
            print("Loading data for the whole country\n")
    
        return download_gpkg(metadata)
    
    # From 2000 onwards 
    else:
    
        if (str(code_state)[0:2] not in metadata['code'].unique() and
            str(code_state)[0:2] not in metadata['code_abrev'].unique()):
        
            raise Exception("Error: Invalid Value to argument code_state.")
        
        else:
        
            if isinstance(code_state, int) :
                metadata = metadata.query(f'code == "{str(code_state)[0:2]}"')
        
            if isinstance(code_state, str) :                         
                metadata = metadata.query(f'code_abrev == "{code_state[0:2]}"')

            gdf = download_gpkg(metadata)
                                          
            if len(str(code_state)) == 2 :
                return gdf 
            
            elif code_state in list(gdf['code_state']):
                return gdf.query('code_state == "code_state"')
        
            else:
                raise Exception("Error: Invalid Value to argument code_state.")