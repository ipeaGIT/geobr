import geopandas as gpd
import pytest
from geobr import read_meso_region


def test_read_meso_region():

    assert isinstance(read_meso_region(), gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_meso_region(code_meso=1401), gpd.geodataframe.GeoDataFrame)
    assert isinstance(
        read_meso_region(code_meso="AC", year=2010), gpd.geodataframe.GeoDataFrame
    )
    assert isinstance(
        read_meso_region(code_meso=11, year=2010), gpd.geodataframe.GeoDataFrame
    )
    assert isinstance(
        read_meso_region(code_meso="all", year=2010), gpd.geodataframe.GeoDataFrame
    )

    with pytest.raises(Exception):
        read_meso_region(year=9999999)

        read_meso_region(code_meso=5201108312313213)

        read_meso_region(code_meso=9999999, year=9999999)
