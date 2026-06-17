from geobr.utils import read_geobr_v2


def read_semiarid(
    year: int,
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """ Download official data of Brazilian Semiarid region (IBGE).
    
    Parameters
    ----------
    year : int
        Year of the data.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """
    return read_geobr_v2(
        "semiarid",
        year,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
