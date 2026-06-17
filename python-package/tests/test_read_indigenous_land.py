import geopandas as gpd
import pytest
from geobr import read_indigenous_land


def test_read_indigenous_land():

    gdf = read_indigenous_land(year=2025, code_state="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_indigenous_land(year=9999999)
