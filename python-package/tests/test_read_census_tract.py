import geopandas as gpd
import pytest
from geobr import read_census_tract


def test_read_census_tract():

    assert isinstance(
        read_census_tract(code_tract=11, zone="rural", year=2000),
        gpd.geodataframe.GeoDataFrame,
    )
    assert isinstance(
        read_census_tract(code_tract="AC", zone="rural", year=2000),
        gpd.geodataframe.GeoDataFrame,
    )
    assert isinstance(
        read_census_tract(code_tract="AP", zone="rural"), gpd.geodataframe.GeoDataFrame
    )
    assert isinstance(
        read_census_tract(code_tract=11, zone="urban", year=2000),
        gpd.geodataframe.GeoDataFrame,
    )
    assert isinstance(
        read_census_tract(code_tract="AP", zone="urban", year=2000),
        gpd.geodataframe.GeoDataFrame,
    )
    assert isinstance(
        read_census_tract(code_tract="AP", zone="urban", year=2010),
        gpd.geodataframe.GeoDataFrame,
    )
    assert isinstance(
        read_census_tract(code_tract="all", year=2000), gpd.geodataframe.GeoDataFrame
    )

    with pytest.raises(Exception):

        read_census_tract(year=9999999)
        read_census_tract(code_tract="AP", year=2000, zone="ABCD")

        read_census_tract(code_tract=None)
        read_census_tract(code_tract="AC_ABCD")
        read_census_tract()
