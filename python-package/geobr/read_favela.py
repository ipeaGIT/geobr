"""Download spatial data of favelas and urban communities."""

from geobr.utils import read_geobr_v2


def read_favela(
    year: int,
    code_muni: str = "all",
    simplified: bool = True,
    output: str = "sf",
    show_progress: bool = True,
    cache: bool = True,
    verbose: bool = False,
):
    """Download favelas and urban communities (IBGE).

    Parameters
    ----------
    year : int
        Year of the data (required).
    code_muni : str or int
        Municipality code, state abbrev (e.g. ``"RJ"``), or ``"all"``.
    simplified, output, show_progress, cache, verbose
        Standard geobr v2 options.
    """
    return read_geobr_v2(
        geography="favelas",
        year=year,
        code=code_muni,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
