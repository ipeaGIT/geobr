from geobr.utils import read_geobr_hybrid


def read_neighborhood(
    year: int = 2022,
    code_muni: str = "all",
    simplified: bool = True,
    output: str = "sf",
    show_progress: bool = True,
    cache: bool = True,
    verbose: bool = False,
):
    """Download neighborhood limits of Brazilian municipalities.

    Parameters
    ----------
    year : int
        Year of the data.
    code_muni : str or int
        Municipality code, state abbrev, or ``"all"``.
    simplified, output, show_progress, cache, verbose
        Standard geobr options.
    """
    return read_geobr_hybrid(
        "neighborhoods",
        "neighborhood",
        year,
        code=code_muni,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
