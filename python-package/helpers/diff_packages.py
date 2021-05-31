from pathlib import Path

get_files = lambda path: set([p.name.split(".")[0] for p in Path(path).glob("*")])

print(
    [
        p
        for p in get_files("../r-package/R").difference(get_files("geobr/"))
        if p not in ["geobr"]
    ]
)
