from geobr.utils import read_geobr_v2


def read_schools(
    year: int,
    code_muni: str = "all",
    simplified: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
    verbose: bool = False,
):
    """Download geolocated school data (INEP).

    Parameters
    ----------
    year : int
        Year of the data.
    code_muni : str or int
        Municipality code, state abbrev, or ``"all"``.
    simplified, output, show_progress, cache, verbose
        Standard geobr options.
    """
    return read_geobr_v2(
        "schools",
        year,
        code=code_muni,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
