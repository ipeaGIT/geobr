import geopandas as gpd
import pytest
from shapely.geometry import Point

from geobr._filter import filter_by_code


def test_filter_all(sample_gdf):
    out = filter_by_code(sample_gdf, "all")
    assert len(out) == 4


def test_filter_state_abbrev(sample_gdf):
    out = filter_by_code(sample_gdf, "RJ")
    assert len(out) == 1
    assert out.iloc[0]["abbrev_state"] == "RJ"


def test_filter_code_state(sample_gdf):
    out = filter_by_code(sample_gdf, 33)
    assert len(out) == 1
    assert out.iloc[0]["abbrev_state"] == "RJ"

def test_filter_code_macro(sample_gdf):
    out = filter_by_code(sample_gdf, 3304)
    assert len(out) == 1
    assert out.iloc[0]["abbrev_state"] == "RJ"


def test_filter_code_muni(sample_gdf):
    out = filter_by_code(sample_gdf, 3304557)
    out2 = filter_by_code(sample_gdf, "3304557")
    assert len(out) == 1
    assert len(out2) == 1


def test_filter_invalid():
    gdf = gpd.GeoDataFrame({"x": [1]}, geometry=[Point(0, 0)], crs="EPSG:4674")
    with pytest.raises(ValueError):
        filter_by_code(gdf, "INVALID")
