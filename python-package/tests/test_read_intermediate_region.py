import geopandas as gpd
import pytest
from geobr import read_intermediate_region


def test_read_intermediate_region():

    assert isinstance(read_intermediate_region(), gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_intermediate_region(year=9999999)
        read_intermediate_region(12323423535)

    assert len(read_intermediate_region("SP")) > 0

    assert len(read_intermediate_region(1101)) > 0
