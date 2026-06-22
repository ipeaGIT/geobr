"""Remove distant Brazilian islands from spatial objects."""

from __future__ import annotations

from pathlib import Path

import geopandas as gpd


def _offcoast_path() -> Path:
    return Path(__file__).parent / "data" / "br_offcoast.parquet"


def remove_islands(x: gpd.GeoDataFrame) -> gpd.GeoDataFrame:
    """Remove islands more than ~20 km from the mainland coast.

    Parameters
    ----------
    x : geopandas.GeoDataFrame
        Input with CRS EPSG:4674 (SIRGAS 2000).

    Returns
    -------
    geopandas.GeoDataFrame
        Same attributes with distant islands removed from geometry.
    """
    if not isinstance(x, gpd.GeoDataFrame):
        raise TypeError("`x` must be a geopandas.GeoDataFrame.")

    if x.crs is None or x.crs.to_epsg() != 4674:
        raise ValueError("`x` must have CRS EPSG:4674 / SIRGAS 2000.")

    offcoast = gpd.read_parquet(_offcoast_path())
    if offcoast.crs is None or offcoast.crs.to_epsg() != 4674:
        offcoast = offcoast.set_crs(4674)
    
    x = x.copy()
    x["geometry"] = x.geometry.make_valid()
    result = gpd.overlay(x, offcoast, how="difference")
    return result
