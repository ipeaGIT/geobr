import importlib

import geopandas as gpd
from shapely.geometry import Point
from pathlib import Path


from geobr.read_capitals import read_capitals, _CAPITALS


def test_capitals_table_has_27_rows():
    assert len(_CAPITALS) == 27


def test_read_capitals_filters(monkeypatch, tmp_path):
    # mod = importlib.import_module("geobr.read_municipal_seat")

    def _fake_seat(f, u, **kwargs):
        capitals =  gpd.GeoDataFrame(
            _CAPITALS.assign(geometry=[Point(0, 0)] * 27),
            crs="EPSG:4674",
        )
        path = tmp_path / "capitals.parquet"
        capitals.to_parquet(path)

        return path

    mod = importlib.import_module("geobr.utils")

    monkeypatch.setattr(mod, "download_parquet", _fake_seat)

    # def _fake_seat(**kwargs):
    #     return gpd.GeoDataFrame(
    #         _CAPITALS.assign(geometry=[Point(0, 0)] * 27),
    #         crs="EPSG:4674",
    #     )

    # monkeypatch.setattr(mod, "read_municipal_seat", _fake_seat)

    gdf = read_capitals(year=2010)
    assert len(gdf) == 27
