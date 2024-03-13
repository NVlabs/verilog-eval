import os

import pkg_resources
from setuptools import setup, find_packages


setup(
    name="verilog-eval",
    py_modules=["verilog-eval"],
    version="1.0",
    description="",
    author="NVIDIA",
    packages=find_packages(),
    install_requires=[
        str(r)
        for r in pkg_resources.parse_requirements(
            open(os.path.join(os.path.dirname(__file__), "requirements.txt"))
        )
    ],
    entry_points={
        "console_scripts": [
            "evaluate_functional_correctness = verilog_eval.evaluate_functional_correctness:main",
        ]
    }
)
