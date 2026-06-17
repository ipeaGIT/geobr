from geobr.utils import read_geobr_v2


def read_country(
    year: int,
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download Brazil's national borders data.

    Parameters
    ----------
    year : int
        Year of the data.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """
    
    return read_geobr_v2(
        "country",
        year,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
