from geobr.utils import read_geobr_v2


def read_weighting_area(
    year: int,
    code_weighting: str = "all",
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download Census Weighting Areas (area de ponderacao) data of the Brazilian Population Census.

    Parameters
    ----------
    year : int
        Year of the data.
    code_weighting : str or int
        Municipality code, state abbrev, or ``"all"``.
    simplified, output, show_progress, cache, verbose
        Standard geobr options.
    """

    return read_geobr_v2(
        "weightingareas",
        year,
        code=code_weighting,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )

