"""Convert downloaded geobr parquet data to requested output format."""

from __future__ import annotations

from typing import Literal, Optional

import duckdb
import geopandas as gpd

OutputType = Literal["gpd", "duckdb", "arrow"]

ALLOWED_OUTPUTS = ("gpd", "duckdb", "arrow")


def convert_output(
    relation: duckdb.DuckDBPyRelation,
    output: OutputType = "gpd",
    connection: object = None,
) -> object:
    """Load parquet and return in the requested format.

    Parameters
    ----------
    relation: a duckdb relation
    output : ``"gpd"`` (default), ``"duckdb"``, or ``"arrow"``
    filter_code : passed to ``filter_by_code`` when output is ``"gpd"``
    """
    if output not in ALLOWED_OUTPUTS:
        raise ValueError(
            f"`output` must be one of: {list(ALLOWED_OUTPUTS)}. Got: {output!r}"
        )

    if output == "duckdb":
        return relation

    query = """
            SELECT 
                * EXCLUDE(geometry),
                ST_AsWKB(geometry) AS geometry
            FROM relation
        """
    
    non_geo_relation = connection.sql(query)

    if output == "gpd":
        crs = "EPSG:4674"
        if "geometry" in relation.columns:
            crs =  relation.select("ST_CRS(geometry)").limit(1).fetchone()[0]
        df = non_geo_relation.df()
        df["geometry"] = df["geometry"].apply(bytes)
        gdf = gpd.GeoDataFrame(df, geometry=gpd.GeoSeries.from_wkb(df['geometry']), crs=crs)
        from geobr.utils import enforce_types
        return enforce_types(gdf)

    if output == "arrow":
        return non_geo_relation.to_arrow_table()

    raise ValueError(f"Unknown output: {output}")
