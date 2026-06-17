import geopandas as gpd
import pytest
from geobr import read_metro_area


def test_read_metro_area():

    gdf = read_metro_area(year=2024, code_state="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_metro_area(year=9999999)
