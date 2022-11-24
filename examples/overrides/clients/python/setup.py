""" Package setup for the component ormgrop """
from setuptools import find_packages, setup

setup(
    name="ormgrop",
    version="revision-2551478512",
    url="www.snek-pit.gov",
    author="Mr.Snek",
    author_email="snek@pit.com",
    description="Pit of snek. 🐍 HISSSSS!",
    packages=find_packages(exclude=["tests"]),
    entry_points={"console_scripts": ["ormgrop=ormgrop.main:main"]},
)
