"""Download geolocated polling place data (TSE)."""

from geobr.utils import read_geobr_v2


def read_polling_places(
    year: int,
    code_muni: str = "all",
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
    verbose: bool = False,
):
    """Download polling places with geocodebr-enhanced coordinates when applicable.

    Parameters
    ----------
    year : int
        Year of the data (required).
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
