from geobr.utils import read_geobr_v2

def read_amazon(
    year: int,
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download official Brazil's Legal Amazon data (Brazilian Ministry of Environment - MMA).

    Parameters
    ----------
    year : int
        Year of the data.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """

    return read_geobr_v2(
        "amazonialegal",
        year,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
