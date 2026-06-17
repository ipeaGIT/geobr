import geopandas as gpd
import pytest
from geobr import read_statistical_grid


def test_read_statistical_grid():

    gdf = read_statistical_grid(year=2022, code_muni="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_statistical_grid(year=9999999)
