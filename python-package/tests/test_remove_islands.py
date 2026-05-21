import geopandas as gpd
import pytest
from shapely.geometry import Point, box

from geobr.remove_islands import remove_islands


def test_remove_islands_requires_crs():
    gdf = gpd.GeoDataFrame(geometry=[Point(0, 0)], crs="EPSG:4326")
    with pytest.raises(ValueError, match="4674"):
        remove_islands(gdf)


def test_remove_islands_runs():
    gdf = gpd.GeoDataFrame(
        {"id": [1]},
        geometry=[box(-50, -25, -40, -20)],
        crs="EPSG:4674",
    )
    out = remove_islands(gdf)
    assert isinstance(out, gpd.GeoDataFrame)
