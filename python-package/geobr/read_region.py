from geobr.utils import read_geobr_v2


def read_region(
    year: int,
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """ Download spatial data of Brazil Regions.
    
     Parameters
    ----------
    year : int
        Year of the data.
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """

    return read_geobr_v2(
        "regions",
        year,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
