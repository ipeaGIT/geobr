import geopandas as gpd
import pytest
from geobr import read_statistical_grid


def test_read_statistical_grid():
    assert isinstance(read_statistical_grid(code_grid=4), gpd.geodataframe.GeoDataFrame)

    assert isinstance(
        read_statistical_grid(code_grid="AC", year=2010), gpd.geodataframe.GeoDataFrame
    )

    # Too heavy
    # assert isinstance(
    #     read_statistical_grid(code_grid="all"),
    #     gpd.geodataframe.GeoDataFrame
    # )

    with pytest.raises(Exception):
        read_statistical_grid(year=9999999)

        # Existing year but it has no code_grid specified
        read_statistical_grid(year=2010)

        read_statistical_grid(code_grid="AM_ACAP")
