from geobr.utils import read_geobr_v2


def read_micro_region(
    year: int,
    code_micro: str = "all",
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download spatial data of micro region.

    Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)

    Parameters
    ----------
    year : int
        Year of the data.
    code_micro : str or int
        5-digit micro region code, state abbrev, two-digit code, or ``"all"``.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """

    return read_geobr_v2(
        "microregions",
        year,
        code=code_micro,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
