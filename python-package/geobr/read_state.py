
import geopandas as gpd

from geobr.utils import download_metadata, apply_mode, apply_year, download_gpkg

def read_state(code_state, year=None, mode="simplified", verbose=False):

    # Get metadata with data addresses
    metadata = download_metadata()

    # Select geo
    metadata = metadata.query(f'geo == "uf"')

    # Select mode
    metadata = apply_mode(metadata, mode)
    
    # Verify year input
    metadata = apply_year(metadata, year, year_default=2010)
    
    # TODO: Do we need this here? Maybe a function?
    if code_state is None:
        raise Exception("Value to argument 'code_state' cannot be None")

    # From 1872 to 1991  
    if (year < 1992) or (code_state == "all"):
            
        # Printing statements are not a good practice in Python modules. 
        # We can have a verbose mode, if that is the case.
        if verbose:
            print("Loading data for the whole country\n")

        # list paths of files to downloas
    
        return download_gpkg(metadata)
    
    # From 2000 onwards 
    else:
    
        if (str(code_state)[0:2] not in temp_meta['code']unique()) and
           (str(code_state)[0:2] not in temp_meta['code_abrev']unique()):
        
            raise Exception("Error: Invalid Value to argument code_state.")
        
        else:
            
            # TODO: The data types are quite confusing. Clarification needed.
            # list paths of files to download
            if isinstance(code_state, int) :
            
                metadata = metadata.query(f'code == "{str(code_state)[0:2]}"']
        
            if isinstance(code_state, str) :
                                          
                metadata = metadata.query(f'code_abrev == "{code_state[0:2]}"']

            gdf = download_gpkg(metadata)
                                          
                                          
            # TODO: The R code has a column 'code_state' for temps, that does not exist
            # in gdf
            if len(str(code_state)) == 2 :
            
                return gdf 
        
            else:
            
                raise Exception("Error: Invalid Value to argument code_state.")