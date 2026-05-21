from geobr.utils import read_geobr_hybrid, select_metadata, download_gpkg
from geobr._filter import filter_by_code

# IBGE operational water areas in RS (Lagoa dos Patos / Lagoa Mirim) — code_muni placeholders
_RS_OPERATIONAL_CODES = {4300001, 4300002}


def read_municipality(
    code_muni="all",
    year=2010,
    simplified=True,
    verbose=False,
    keep_areas_operacionais=False,
    output: str = "sf",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download shape files of Brazilian municipalities.

    Parameters
    ----------
    code_muni : str or int
        Municipality code, state code/abbrev, or ``"all"``.
    year : int
        Year of the data.
    simplified : bool
        Use simplified geometry when True.
    verbose : bool
        Print progress messages.
    keep_areas_operacionais : bool
        Keep Lagoa dos Patos / Lagoa Mirim operational polygons in RS.
    output, show_progress, cache
        Standard geobr v2 options.
    """
    try:
        gdf = read_geobr_hybrid(
            "municipalities",
            "municipality",
            year,
            code=code_muni,
            simplified=simplified,
            output=output,
            show_progress=show_progress,
            cache=cache,
            verbose=verbose,
        )
    except (ValueError, ConnectionError, KeyError):
        metadata = select_metadata("municipality", year=year, simplified=simplified)
        if year < 1992:
            gdf = download_gpkg(metadata)
        elif code_muni == "all":
            if verbose:
                print(
                    "Loading data for the whole country. This might take a few minutes."
                )
            gdf = download_gpkg(metadata)
        else:
            metadata = metadata[
                metadata[["code", "code_abbrev"]].apply(
                    lambda x: str(code_muni)[:2] in str(x["code"])
                    or str(code_muni)[:2] in str(x["code_abbrev"]),
                    axis=1,
                )
            ]
            if not len(metadata):
                raise ValueError("Invalid Value to argument code_muni.")
            gdf = download_gpkg(metadata)
            if len(str(code_muni)) != 2:
                if code_muni in gdf["code_muni"].tolist():
                    gdf = gdf.query(f"code_muni == {code_muni}")
                else:
                    raise ValueError("Invalid Value to argument code_muni.")

    if not keep_areas_operacionais and "code_muni" in gdf.columns:
        gdf = gdf[~gdf["code_muni"].isin(_RS_OPERATIONAL_CODES)]

    return gdf
