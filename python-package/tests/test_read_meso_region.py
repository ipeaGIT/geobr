import geopandas as gpd
import pytest
from geobr import read_meso_region


def test_read_meso_region():

    gdf = read_meso_region(year=2022, code_meso="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_meso_region(year=9999999)
        read_meso_region(year=2022, code_meso=5201108312313213)
