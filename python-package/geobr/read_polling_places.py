from geobr.utils import read_geobr_v2


def read_polling_places(
    year: int,
    code_muni: str = "all",
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
    verbose: bool = False,
):
    """
    Download geolocated polling place data (TSE).

    The spatial coordinates used in geobr are a combination of the coordinates
    produced by the original data producer and the coordinates found via geocoding
    with the geocodebr package.
    Whenever the distance between the coordinates from both sources is smaller than
    800 meters, geobr uses coordinates from the data producer. When the distance
    between the two sources is greater than 800 meters and the results from
    geocodebr have a precision level finer than 800 meters, geobr uses the
    coordinates from geocodebr. When the coordinates from the original source are
    missing, geobr also uses geocodebr coordinates, regardless of precision level.
    The source of the spatial coordinates used in each observation is registered
    in the data in a specific column `coords_source`. Additional columns
    indicating the precision level of geocodebr geocoding are also included in
    the data.

    Parameters
    ----------
    year : int
        Year of the data.
    code_muni : str or int
        Municipality code, state abbrev, or ``"all"``.
    output, show_progress, cache, verbose
        Standard geobr v2 options.

    Notes
    -----
    Result includes ``coords_source`` indicating coordinate provenance.
    """
    return read_geobr_v2(
        geography="pollingplaces",
        year=year,
        code=code_muni,
        simplified=False,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )
