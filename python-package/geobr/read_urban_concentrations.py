from geobr.utils import read_geobr_hybrid


def read_urban_concentrations(
    year: int = 2010,
    code_state: str = "all",
    simplified: bool = True,
    verbose: bool = False,
    output: str = "sf",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download urban concentration areas (IBGE).

    Parameters
    ----------
    year : int
        Year of the data (2010 in v2).
    code_state : str or int
        State abbrev, two-digit code, or ``"all"``.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """
    return read_geobr_hybrid(
        "urbanconcentrations",
        "urban_concentrations",
        year,
        code=code_state,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
