import importlib

import geopandas as gpd
from shapely.geometry import Point

from geobr.read_capitals import read_capitals, _CAPITALS


def test_capitals_table_has_27_rows():
    assert len(_CAPITALS) == 27


# def test_read_capitals_filters(monkeypatch):
#     mod = importlib.import_module("geobr.read_municipal_seat")

#     def _fake_seat(**kwargs):
#         return gpd.GeoDataFrame(
#             _CAPITALS.assign(geometry=[Point(0, 0)] * 27),
#             crs="EPSG:4674",
#         )

#     monkeypatch.setattr(mod, "read_municipal_seat", _fake_seat)
#     out = read_capitals(year=2010)
#     assert len(out) == 27
