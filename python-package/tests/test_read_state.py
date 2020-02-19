import geopandas as gpd
import pytest
from geobr import read_state

def test_read_state():

    assert isinstance(read_state(code_state="AC", year=2010), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_state(code_state="AP"), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_state(code_state="all", year=1872), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_state(code_state=11, year=2010), 
                      gpd.geodataframe.GeoDataFrame)

    assert isinstance(read_state(code_state=11), 
                      gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_state(code_state=9999999, year=9999999)
        read_state(code_state=9999999, year="xxx")
        read_state(code_state="xxx", year=9999999)
        read_state(code_state="xxx", year="xxx")
        read_state(code_state=None, year=9999999)
        read_state(year="xxx")

        read_state(code_state=11, year=9999999)
        read_state(code_state=1401, year=9999999)
        read_state(code_state=11008, year=9999999)
        read_state(code_state=11, year= "xx")
        read_state(code_state=1401, year= "xx")
        read_state(code_state=11008, year= "xx")
        read_state(code_state="all", year=9999999)
        read_state(code_state="SC", year=9999999)
        read_state(code_state="SC", year="xx")
        read_state(code_state="all", year="xx")
        read_state(code_state=9999999, year=2000)
        read_state(code_state=9999999)
        read_state(code_state="XXX", year=2000)
        read_state(code_state="XXX")
        read_state()