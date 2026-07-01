import geopandas as gpd
import pandas as pd
import pytest
from shapely.geometry import Point, box

from geobr.remove_islands import remove_islands


def test_remove_islands_requires_crs():
    gdf = gpd.GeoDataFrame(geometry=[Point(0, 0)], crs="EPSG:4326")
    with pytest.raises(ValueError, match="4674"):
        remove_islands(gdf)


def test_remove_islands_requires_gpd():
    df = pd.DataFrame({"geometry": [0]})
    with pytest.raises(TypeError, match="must be a geopandas"):
        remove_islands(df)


def test_remove_islands_runs():
    gdf = gpd.GeoDataFrame(
        {"id": [1]},
        geometry=[box(-50, -25, -40, -20)],
        crs="EPSG:4674",
    )
    out = remove_islands(gdf)
    diff = gdf.geometry.geom_equals(out.geometry)
    assert isinstance(out, gpd.GeoDataFrame)
    assert not diff.any() 
