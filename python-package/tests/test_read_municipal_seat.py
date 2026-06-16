import geopandas as gpd
import pytest
from geobr import read_municipal_seat


def test_read_municipal_seat():

    gdf = read_municipal_seat(year=2022, code_muni="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_municipal_seat(year=9999999)
