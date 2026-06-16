import geopandas as gpd
import pytest
from geobr import read_census_tract


def test_read_census_tract():

    gdf1 = read_census_tract(code_tract=11, zone="rural", year=2000)
    assert isinstance(gdf1, gpd.geodataframe.GeoDataFrame)
    assert not gdf1.empty

    gdf2 = read_census_tract(code_tract=11, zone="urban", year=2000)
    assert isinstance(gdf2, gpd.geodataframe.GeoDataFrame)
    assert not gdf2.empty

    gdf3 = read_census_tract(code_tract="AP", year=2022)
    assert isinstance(gdf3, gpd.geodataframe.GeoDataFrame)
    assert not gdf3.empty

    with pytest.raises(Exception):

        read_census_tract(year=9999999)
        read_census_tract(code_tract="AP", year=2000, zone="ABCD")

        read_census_tract(code_tract=None)
        read_census_tract(code_tract="AC_ABCD")
        read_census_tract()
