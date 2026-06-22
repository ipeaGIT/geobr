import geopandas as gpd
import pytest
from geobr import read_quilombola_land


def test_read_quilombola_land():

    gdf = read_quilombola_land(202605, code_state="AP")
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_quilombola_land(year=2025)
