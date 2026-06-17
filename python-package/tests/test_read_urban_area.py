import geopandas as gpd
import pytest
from geobr import read_urban_area


def test_read_urban_area():

    gdf = read_urban_area(year=2019, code_muni="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_urban_area(year=9999999)
