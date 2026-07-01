from geobr.utils import read_geobr_v2


def read_census_tract(
    year: int,
    code_tract: str = "all",
    zone="urban",
    simplified: bool = True,
    verbose: bool = False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download spatial data of census tracts (setores censitários) of the Brazilian Population Census.

    Parameters
    ----------
    year : int
        Year of the data.
    code_tract : str or int
        7-digit municipality code, state abbrev, two-digit code, or ``"all"``.
    zone: string, optional
        "urban" or "rural" census tracts come in separate files in the year 2000, by default urban
    simplified, verbose, output, show_progress, cache
        Standard geobr options.
    """

    allowed = ("urban", "rural")
    if zone not in allowed:
        raise ValueError(
            f"`zone` must be one of: {list(allowed)}. Got: {zone!r}"
        )

    zone_name = None

    if year <= 2007:
        zone_name = zone

    return read_geobr_v2(
        "censustracts",
        year,
        code=code_tract,
        simplified=simplified,
        output=output,
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
        zone=zone_name
    )