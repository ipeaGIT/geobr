from geobr import utils


def lookup_muni(name_muni=None, code_muni=None, verbose=False):
    """Lookup municipality codes and names.

    By default, it looks for all municipalities. You can also use 'all' to in
    `name_muni` or `code_muni` to get all municipalities.

    Input a municipality NAME or CODE and get the names and codes of
    the municipality's corresponding state, meso, micro, intermediate, and
    immediate regions. You should not select both code_muni and name_muni

    Parameters
    ----------

    name_muni : str, optional
    The municipality name to be looked up

    code_muni: str, optional
    The municipality code to be looked up

    verbose : bool, optional
    by default False

    Returns
    -------
    pd.DataFram
    13 columns identifying the geographies information of that municipality

    Details Only available from 2010 Census data so far

    Raise
    -------
    Exception if code_muni or name_muni cannot be found

    Example
    -------
    >>> import geobr

    # Lookup table for municipality of Rio de Janeiro
    >>> mun = lookup_muni('Rio de Janeiro)
    or
    >>> mun = lookup_muni(3304557)

    # lookup table for all municipalities
    >>> mun_all = lookup_muni()
    """
    # Get metadata with data url addresses
    temp_meta = utils.select_metadata(geo="lookup_muni", year=2010)

    # Read DataFrame available at provided url
    lookup_table = utils.download_metadata(
        temp_meta.loc[:, "download_path"].to_list()[0]
    )
    lookup_table["name_muni_format"] = lookup_table["name_muni_format"].str.lower()

    # Search by inputs
    if (
        code_muni == "all"
        or name_muni == "all"
        or (code_muni is None and name_muni is None)
    ):
        if verbose:
            print(f"Returning results for all municipalities")
        return lookup_table.iloc[:, :-1]

    elif code_muni is not None:
        if name_muni is not None:
            if verbose:
                print("Ignoring argument name_muni")
        try:
            output = lookup_table[lookup_table["code_muni"] == int(code_muni)].iloc[
                :, :-1
            ]
            if verbose:
                print(
                    "Returning results for municipality ",
                    f'{output.loc[:, "name_muni"].to_list()[0]}',
                )
            return output

        except KeyError:
            raise Exception(
                f"The `code_muni` argument {code_muni}",
                "was not found in the database.",
            )

    elif name_muni is not None:
        # Cleaning from accents and turning into lower cases without spaces
        name_muni = utils.strip_accents(str(name_muni).lower().strip())
        output = lookup_table[lookup_table["name_muni_format"] == name_muni]

        if len(output) == 0:
            if verbose:
                print("Please insert a valid municipality name")
            raise Exception(
                f"The `name_muni` argument {name_muni} ",
                "was not found in the database.",
            )
        else:
            if verbose:
                print(
                    "Returning results for municipality"
                    f'{output.loc[:, "name_muni"].to_list()[0]}'
                )
            return output.iloc[:, :-1]

    elif code_muni == "all" and name_muni == "all":
        if verbose:
            print("Please insert either a municipality ", "name or a municipality code")
