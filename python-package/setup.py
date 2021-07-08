# coding: utf-8

import os
from setuptools import setup


MAJOR = 0
MINOR = 1
MICRO = 9
VERSION = "%d.%d.%d" % (MAJOR, MINOR, MICRO)
ISRELEASED = True

setup_dir = os.path.abspath(os.path.dirname(__file__))


with open(os.path.join(setup_dir, "master-README.md")) as f:
    long_description = f.read()


def write_version_py(filename=os.path.join(setup_dir, "feather/version.py")):
    version = VERSION
    if not ISRELEASED:
        version += ".dev"

    a = open(filename, "w")
    file_content = "\n".join(
        [
            "",
            "# THIS FILE IS GENERATED FROM SETUP.PY",
            "version = '%(version)s'",
            "isrelease = '%(isrelease)s'",
        ]
    )

    a.write(file_content % {"version": VERSION, "isrelease": str(ISRELEASED)})
    a.close()


# write_version_py()

DESCRIPTION = "geobr: Download Official Spatial Data Sets of Brazil"

CLASSIFIERS = [
    "Intended Audience :: Science/Research",
    "Intended Audience :: Developers",
    "Intended Audience :: Education",
    "Topic :: Scientific/Engineering :: GIS",
    "Topic :: Scientific/Engineering :: Visualization",
    "Programming Language :: Python",
    "Programming Language :: Python :: 3.6",
    "Programming Language :: Python :: 3.7",
]


INSTALL_REQUIRES = ("geopandas >= 0.7.0", "Shapely==1.7.0")


setup(
    name="geobr",
    version=VERSION,
    long_description=long_description,
    long_description_content_type="text/markdown",
    description=DESCRIPTION,
    license="MIT + file LICENSE.txt",
    classifiers=CLASSIFIERS,
    url="https://github.com/ipeaGIT/geobr",
    author="João Carabetta, Rafael H. M. Pereira, Caio Nogueira Goncalves, Bernardo Furtado",
    author_email="joao.carabetta@gmail.com , rafa.pereira.br@gmail.com, caio.goncalves@ipea.gov.br, bernardo.furtado@ipea.gov.br",
    maintainer="João Carabetta",
    maintainer_email="joao.carabetta@gmail.com",
    packages=["geobr"],
    platforms="any",
    # package_data={'geobr': ['*.csv']},
    # include_package_data=True
    python_requires=">3.6",
    install_requires=INSTALL_REQUIRES,
    tests_require=["pytest", "Shapely", "geopandas"],
    include_package_data=True,
)
