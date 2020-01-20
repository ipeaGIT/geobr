from geobr import utils

def read_biomes(year=2019):
    """Download official data of Brazilian biomes as an sf object.

    Available years: 2004, 2019

    This data set includes  polygons of all biomes present in Brazilian 
    territory and coastal area. The latest data set dates to 2019 and 
    it is available at scale 1:250.000. The 2004 data set is at the scale 
    1:5.000.000. The original data comes from IBGE. 
    More information at https://www.ibge.gov.br/apps/biomas/
    
    Parameters
    ----------
    year : int, optional
        Year of the map, by default 2019
    
    Returns
    -------
    pd.GeoDataFrame
        [description]
    
    Raises
    ------
    error
        If year is not available.
    """

    # 
    metadata = utils.get_metadata(geo='biomes')

    # check if year in metadata else raise error (probrably a utils func)

    # get urls in metadata based on year

    # download urls

    # transform result in geodataframe (utils func)

    return ' '.join(['biomes', metadata, str(year)])

