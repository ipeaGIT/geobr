from geobr.utils import read_geobr_v2


def read_conservation_units(
    date: int,
    code_state: str = "all",
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download conservation unit polygons (MMA).

    Parameters
    ----------
    date : int
        Date in YYYYMM format.
    code_state : str or int
        State abbrev, two-digit code, or ``"all"``.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """
    return read_geobr_v2(
        "conservationunits",
        date,
        code=code_state,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
