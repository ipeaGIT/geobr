import geopandas as gpd
import pytest
from geobr import read_biomes

def test_read_biomes():

    gdf = read_biomes(2025)
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_biomes(year=9999999)