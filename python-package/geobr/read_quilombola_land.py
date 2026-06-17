"""Download spatial data of quilombola lands (INCRA)."""

from geobr.utils import read_geobr_v2


def read_quilombola_land(
    date: int,
    code_state: str = "all",
    simplified: bool = True,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
    verbose: bool = False,
):
    """Download officially recognized quilombola territories.

    Parameters
    ----------
    date : int
        Snapshot date in YYYYMM format (required).
    code_state : str or int
        State abbrev (e.g. ``"BA"``), two-digit code, or ``"all"``.
    simplified, output, show_progress, cache, verbose
        Standard geobr v2 options.
    """
    return read_geobr_v2(
        geography="quilombolalands",
        year=date,
        code=code_state,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
