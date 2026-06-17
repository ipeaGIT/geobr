import geopandas as gpd
import pytest
from geobr import read_neighborhood


def test_read_neighborhood():

    gdf = read_neighborhood(year=2022, code_muni="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_neighborhood(year=9999999)
