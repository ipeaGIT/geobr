import geopandas as gpd
import pytest
from geobr import read_weighting_area


def test_read_weighting_area():

    gdf = read_weighting_area(year=2010, code_weighting="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_weighting_area(year=9999999)
        read_weighting_area(year=2010, code_weighting="AC_ABCD")
