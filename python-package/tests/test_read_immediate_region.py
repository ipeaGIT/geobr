import geopandas as gpd
import pytest
from geobr import read_immediate_region


def test_read_immediate_region():

    gdf = read_immediate_region(year=2025, code_immediate="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    gdf2 = read_immediate_region(year=2025, code_immediate=3304)
    assert isinstance(gdf2, gpd.GeoDataFrame)
    assert not gdf2.empty

    with pytest.raises(Exception):
        read_immediate_region(year=9999999)
        read_immediate_region(year=2025, code_immediate=5201108312313213)
