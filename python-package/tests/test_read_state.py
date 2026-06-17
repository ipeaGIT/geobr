import geopandas as gpd
import pytest
from geobr import read_state


def test_read_state():

    gdf = read_state(year=2025, code_state="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_state(year=9999999)

    