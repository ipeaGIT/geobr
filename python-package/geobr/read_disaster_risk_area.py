from geobr.utils import read_geobr_hybrid


def read_disaster_risk_area(
    year: int = 2010,
    code_muni: str = "all",
    simplified: bool = True,
    output: str = "sf",
    show_progress: bool = True,
    cache: bool = True,
    verbose: bool = False,
):
    """Download official disaster risk area data (IBGE / CEMADEN).

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
        "disasterriskareas",
        "disaster_risk_area",
        year,
        code=code_muni,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
