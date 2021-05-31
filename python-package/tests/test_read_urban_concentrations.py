import geopandas as gpd
import pytest
from geobr import read_urban_concentrations

def test_read_urban_concentrations():

    assert isinstance(read_urban_concentrations(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_urban_concentrations(year=9999999)