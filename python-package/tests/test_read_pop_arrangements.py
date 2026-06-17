import geopandas as gpd
import pytest
from geobr import read_pop_arrangements


def test_read_pop_arrangements():

    gdf = read_pop_arrangements(year=2010, code_state="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_pop_arrangements(year=9999999)
