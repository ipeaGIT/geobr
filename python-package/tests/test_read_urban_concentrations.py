import geopandas as gpd
import pytest
from geobr import read_urban_concentrations


def test_read_urban_concentrations():

    gdf = read_urban_concentrations(year=2010, code_state="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_urban_concentrations(year=9999999)
    