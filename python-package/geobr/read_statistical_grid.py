from geobr.utils import read_geobr_v2

def read_statistical_grid(
    year: int,
    code_muni,
    verbose=False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download IBGE statistical grid data.

    Parameters
    ----------
    year : int
        Year of the data.
    code_muni : str or int
        State abbrev, state code or municipality code
    verbose, output, show_progress, cache
        Standard geobr options.
    """

    return read_geobr_v2(
        "statsgrid", 
        year,
        code=code_muni,
        simplified=False,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
