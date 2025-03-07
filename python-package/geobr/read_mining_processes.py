import geopandas as gpd
import tempfile
import os
import requests
from zipfile import ZipFile
from io import BytesIO

def read_mining_processes(simplified=True):
    """Download official mining process data from ANM (National Mining Agency).
    
    This function downloads and processes mining permit data from Brazil's National Mining Agency (ANM).
    The data includes all mining processes such as research permits, mining concessions, etc.
    Original source: SIGMINE/ANM
    
    Parameters
    ----------
    simplified : boolean, by default True
        If True, returns a simplified version of the dataset with fewer columns
        
    Returns
    -------
    gpd.GeoDataFrame
        Geodataframe with mining process data
        
    Example
    -------
    >>> from geobr import read_mining_processes
    
    # Read mining processes data
    >>> mining = read_mining_processes()
    """
    
    url = "https://app.anm.gov.br/dadosabertos/SIGMINE/PROCESSOS_MINERARIOS/BRASIL.zip"
    
    try:
        # Download the zip file with SSL verification disabled (use with caution)
        response = requests.get(url, verify=False)
        if response.status_code != 200:
            raise Exception("Failed to download data from ANM")
        
        # Suppress SSL verification warnings
        import warnings
        warnings.filterwarnings('ignore', message='Unverified HTTPS request')
            
        # Create a temporary directory
        with tempfile.TemporaryDirectory() as temp_dir:
            # Extract zip content
            with ZipFile(BytesIO(response.content)) as zip_ref:
                zip_ref.extractall(temp_dir)
                
            # Find the shapefile
            shp_files = [f for f in os.listdir(temp_dir) if f.endswith('.shp')]
            if not shp_files:
                raise Exception("No shapefile found in the downloaded data")
                
            # Read the shapefile
            gdf = gpd.read_file(os.path.join(temp_dir, shp_files[0]))
            
            if simplified:
                # Keep only the most relevant columns
                columns_to_keep = [
                    'geometry',
                    'PROCESSO',
                    'FASE',
                    'NOME',
                    'SUBS',
                    'USO',
                    'UF',
                    'AREA_HA'
                ]
                gdf = gdf[columns_to_keep]
    
    except Exception as e:
        raise Exception(f"Error downloading mining processes data: {str(e)}")
        
    return gdf
