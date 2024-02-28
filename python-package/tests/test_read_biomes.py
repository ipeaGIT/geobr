import geopandas as gpd
import pytest
from geobr import read_biomes

def test_read_biomes():

    assert isinstance(read_biomes(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_biomes(year=9999999)