import geopandas as gpd
import pytest
from geobr import read_weighting_area


def test_read_weighting_area():

    assert isinstance(read_weighting_area(), gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_weighting_area(), gpd.geodataframe.GeoDataFrame)
    assert isinstance(
        read_weighting_area(code_weighting=5201108, year=2010),
        gpd.geodataframe.GeoDataFrame,
    )
    assert isinstance(
        read_weighting_area(code_weighting="AC", year=2010),
        gpd.geodataframe.GeoDataFrame,
    )
    assert isinstance(
        read_weighting_area(code_weighting=11, year=2010), gpd.geodataframe.GeoDataFrame
    )

    with pytest.raises(Exception):
        read_weighting_area(year=9999999)

        read_weighting_area(code_weighting="AC_ABCD")
