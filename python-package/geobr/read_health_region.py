from __future__ import annotations

import warnings

import geopandas as gpd

from geobr.utils import read_geobr_hybrid


def read_health_region(
    year: int = 2024,
    code_state: str = "all",
    geometry_level: str = "municipality",
    macro=None,
    simplified: bool = True,
    verbose: bool = False,
    output: str = "sf",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download Brazilian health region data.

    Parameters
    ----------
    year : int
        Year of the data.
    code_state : str or int
        State abbrev, two-digit code, or ``"all"``.
    geometry_level : str
        ``"municipality"`` (default), ``"micro"``, or ``"macro"``.
    macro : bool, optional
        Deprecated. Use ``geometry_level`` instead.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """
    if macro is not None:
        warnings.warn(
            "The `macro` argument is deprecated. Use `geometry_level` instead.",
            DeprecationWarning,
            stacklevel=2,
        )
        geometry_level = "macro" if macro else "municipality"

    allowed = ("municipality", "micro", "macro")
    if geometry_level not in allowed:
        raise ValueError(
            f"`geometry_level` must be one of: {list(allowed)}. Got: {geometry_level!r}"
        )

    gdf = read_geobr_hybrid(
        "healthregions",
        "health_region",
        year,
        code=code_state,
        simplified=simplified,
        output="sf",
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )

    if geometry_level == "municipality":
        if output != "sf":
            from geobr._output import convert_output
            from geobr._cache import cached_path
            from geobr.utils import select_metadata_v2, download_parquet

            row = select_metadata_v2("healthregions", year, simplified, verbose)
            path = download_parquet(row["file_name"], show_progress, cache)
            return convert_output(path, output=output, filter_code=code_state)
        return gdf

    if geometry_level == "micro":
        group_cols = [
            c
            for c in gdf.columns
            if c != "geometry"
            and c not in ("code_muni", "name_muni", "code_health_macroregion", "name_health_macroregion")
        ]
    else:
        group_cols = [
            c
            for c in gdf.columns
            if c != "geometry"
            and c not in ("code_muni", "name_muni", "code_health_region", "name_health_region")
        ]

    dissolved = gdf.dissolve(by=group_cols, as_index=False)
    dissolved = gpd.GeoDataFrame(dissolved, geometry="geometry", crs=gdf.crs)

    if output != "sf":
        import tempfile
        from pathlib import Path
        from geobr._output import convert_output

        with tempfile.NamedTemporaryFile(suffix=".parquet", delete=False) as fp:
            tmp = Path(fp.name)
        dissolved.to_parquet(tmp)
        return convert_output(tmp, output=output, filter_code="all")

    return dissolved
