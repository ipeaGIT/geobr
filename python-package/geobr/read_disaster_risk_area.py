from geobr.utils import read_geobr_v2


def read_disaster_risk_area(
    year: int,
    code_muni: str = "all",
    simplified: bool = True,
    output: str = "gpd",
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
    return read_geobr_v2(
        "disasterriskareas",
        year,
        code=code_muni,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
