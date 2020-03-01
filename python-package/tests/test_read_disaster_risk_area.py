import geopandas as gpd
import pytest
from geobr import read_disaster_risk_area

def test_read_disaster_risk_area():

    assert isinstance(read_disaster_risk_area(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_disaster_risk_area(year=9999999)