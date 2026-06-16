import geopandas as gpd
import pytest
from geobr import read_disaster_risk_area


def test_read_disaster_risk_area():

    gdf = read_disaster_risk_area(2010)
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_disaster_risk_area(year=9999999)
