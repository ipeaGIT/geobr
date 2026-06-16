from geobr.utils import read_geobr_v2
from geobr._output import convert_output
from geobr._duckdb_backend import duckdb_connection

# IBGE operational water areas in RS (Lagoa dos Patos / Lagoa Mirim) — code_muni placeholders
_RS_OPERATIONAL_CODES = [4300001, 4300002]


def read_municipality(
    year,
    code_muni="all",
    simplified=True,
    verbose=False,
    keep_areas_operacionais=False,
    output: str = "gpd",
    show_progress: bool = True,
    cache: bool = True,
):
    """Download shape files of Brazilian municipalities.

    Parameters
    ----------
    code_muni : str or int
        Municipality code, state code/abbrev, or ``"all"``.
    year : int
        Year of the data.
    simplified : bool
        Use simplified geometry when True.
    verbose : bool
        Print progress messages.
    keep_areas_operacionais : bool
        Keep Lagoa dos Patos / Lagoa Mirim operational polygons in RS.
    output, show_progress, cache
        Standard geobr v2 options.
    """

    relation = read_geobr_v2(
        "municipalities",
        year,
        code=code_muni,
        simplified=simplified,
        output="duckdb",
        show_progress=show_progress,
        cache=cache,
        verbose=verbose,
    )

    conn = duckdb_connection()

    if not keep_areas_operacionais and "code_muni" in relation.columns:
        exclude_codes = ", ".join([f"'{c}'" for c in _RS_OPERATIONAL_CODES])
        relation = conn.sql(
            f"SELECT * FROM relation WHERE CAST(code_muni AS BIGINT) NOT IN ({exclude_codes})"
        )

    return convert_output(relation, output, conn)
