import geopandas as gpd
import pytest
from geobr import read_state

def test_read_state():

    assert isinstance(read_state(), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_state(code_state=11, year=1991), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_state(code_state="AC", year=2010), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_state(code_state=11, year=2010), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_state(code_state="all"), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_state(code_state=9999999, year=9999999)
        
        # Wrong year and code
        read_state(code_state=9999999, year=9999999))
        
        # Wrong code
        expect_error( read_state(code_state=NULL, year=1991)
        read_state(code_state=9999999)
        read_state(code_state=5201108312313213123123123)
        read_state(code_state="AC_ABCD")
        
        # Wrong year
        read_state( year=9999999)
