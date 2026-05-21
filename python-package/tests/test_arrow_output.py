import pyarrow as pa
import geopandas as gpd
from shapely.geometry import Point

from geobr._output import convert_output


def test_arrow_output(tmp_path):
    gdf = gpd.GeoDataFrame({"a": [1]}, geometry=[Point(0, 0)], crs="EPSG:4674")
    path = tmp_path / "t.parquet"
    gdf.to_parquet(path)
    table = convert_output(path, output="arrow")
    assert isinstance(table, pa.Table)
    assert table.num_rows == 1
