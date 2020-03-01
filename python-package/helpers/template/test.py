import geopandas as gpd
import pytest
from geobr import {{ name }}

def test_{{ name }}():

    assert isinstance({{ name }}(), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        {{ name }}(year=9999999)