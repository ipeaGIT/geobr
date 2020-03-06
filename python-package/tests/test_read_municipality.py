import geopandas as gpd
import pytest
from geobr import read_municipality

def test_read_municipality():

    assert isinstance(read_municipality(), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_municipality(code_muni='AC', year=1991), 
                      gpd.geodataframe.GeoDataFrame)
    assert isinstance(read_municipality(code_muni='AC', year=2010), 
                      gpd.geodataframe.GeoDataFrame)
    assert isinstance(read_municipality(code_muni=11, year=1991), 
                      gpd.geodataframe.GeoDataFrame)
    assert isinstance(read_municipality(code_muni=11, year=2010), 
                      gpd.geodataframe.GeoDataFrame)
    assert isinstance(read_municipality(code_muni='all', year=1991), 
                      gpd.geodataframe.GeoDataFrame)
    assert isinstance(read_municipality(code_muni='all', year=2010), 
                      gpd.geodataframe.GeoDataFrame)


    with pytest.raises(Exception):
        read_municipality(year=9999999)

        read_municipality(code_muni="RJ_ABC")