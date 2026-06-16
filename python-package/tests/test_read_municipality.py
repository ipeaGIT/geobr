import geopandas as gpd
import pytest
from geobr import read_municipality


def test_read_municipality():

    gdf = read_municipality(year=2025, code_muni="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_municipality(year=9999999)
        read_municipality(year=2025, code_muni="RJ_ABC")
