from geobr.utils import read_geobr_v2


def read_metro_area(
    year: int,
    code_state: str = "all",
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download metropolitan area polygons grouped by metro region.

    Parameters
    ----------
    year : int
        Year of the data.
    code_state : str or int
        State abbrev, two-digit code, or ``"all"``.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """
    return read_geobr_v2(
        "metroarea",
        year,
        code=code_state,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
