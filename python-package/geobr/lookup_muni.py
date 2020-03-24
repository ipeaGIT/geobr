""" Lookup municipality codes and names

Input a municipality NAME or CODE and get the names and codes of the municipality's corresponding state, meso, micro,
intermediate, and immediate regions.

:param name_muni -- The municipality name to be looked up
:param code_muni -- The municipality code to be looked up

:return data.frame with 13 columns identifying the geographies information of that municipality

Details Only available from 2010 Census data so far

example

import geobr

# Lookup table for municipality of Rio de Janeiro

mun = lookup_muni('Rio de Janeiro)
or
mun = lookup_muni(3304557)

lookup table for all municipalities
mun_all = lookup_muni("all")

mun_all <- lookup_muni(code_muni = "all")
"""
import pandas as pd
import utils


def lookup_muni(name_muni='', code_muni=''):
    # Get metadata with data url addresses
    temp_meta = utils.download_metadata()
    temp_meta = temp_meta[(temp_meta.geo == 'lookup_muni') & (temp_meta.year == 2010)]

    # For the specific case in which there is just one year. For more years, change for a list result of urls
    url = temp_meta.loc[:, 'download_path'].to_list()[0]

    # Read DataFrame available at provided url
    lookup_table_2010 = pd.read_csv(url)
    lookup_table_2010.name_muni_format = lookup_table_2010.name_muni_format.str.lower()

    # Search by inputs
    if code_muni == 'all' or name_muni == 'all':
        print(f"Returning results for all municipalities")
        return lookup_table_2010.iloc[:, :-1]
    elif code_muni != '':
        if name_muni != '':
            print("Ignoring argument name_muni")
        output = lookup_table_2010[lookup_table_2010.code_muni == int(code_muni)].iloc[:, :-1]
        print(f"Returning results for municipality {output.loc[:, 'name_muni'].to_list()[0]}")
        return output
    elif name_muni != '':
        # Cleaning from accents and turning into lower cases without spaces
        name_muni = utils.strip_accents(str(name_muni).lower().strip())
        output = lookup_table_2010[lookup_table_2010.name_muni_format == name_muni]
        if len(output) == 0:
            print("Please insert a valid municipality name")
        else:
            print(f"Returning results for municipality {output.loc[:, 'name_muni'].to_list()[0]}")
            return output.iloc[:, :-1]
    elif code_muni == 'all' and name_muni == 'all':
        print("Please insert either a municipality name or a municipality code")


if __name__ == '__main__':
    out = lookup_muni(name_muni='maricá')
    out = lookup_muni(name_muni=' Rio de janeiro ')
    out = lookup_muni(code_muni=3304557)
    out = lookup_muni(code_muni='all')
