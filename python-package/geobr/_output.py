"""Convert downloaded geobr parquet data to requested output format."""

from __future__ import annotations

from pathlib import Path
from typing import Literal, Optional, Union

import geopandas as gpd
import pyarrow.parquet as pq

OutputType = Literal["sf", "duckdb", "arrow"]

ALLOWED_OUTPUTS = ("sf", "duckdb", "arrow")


def convert_output(
    parquet_path: Union[str, Path],
    output: OutputType = "sf",
    filter_code: str = "all",
    connection: object = None,
    view_name: Optional[str] = None,
) -> object:
    """Load parquet and return in the requested format.

    Parameters
    ----------
    parquet_path : path to local parquet file
    output : ``"sf"`` (default), ``"duckdb"``, or ``"arrow"``
    filter_code : passed to ``filter_by_code`` when output is ``"sf"``
    """
    if output not in ALLOWED_OUTPUTS:
        raise ValueError(
            f"`output` must be one of: {list(ALLOWED_OUTPUTS)}. Got: {output!r}"
        )

    path = Path(parquet_path)

    if output == "sf":
        gdf = gpd.read_parquet(path)
        if filter_code != "all":
            from geobr._filter import filter_by_code

            gdf = filter_by_code(gdf, filter_code)
        from geobr.utils import enforce_types

        return enforce_types(gdf)

    if output == "arrow":
        return pq.read_table(path)

    if output == "duckdb":
        from geobr._duckdb_backend import read_parquet_relation

        return read_parquet_relation(
            path,
            filter_code=filter_code,
            connection=connection,
            view_name=view_name,
        )

    raise ValueError(f"Unknown output: {output}")
