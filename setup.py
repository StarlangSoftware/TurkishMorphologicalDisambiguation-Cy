from setuptools import setup

from pathlib import Path
this_directory = Path(__file__).parent
long_description = (this_directory / "README.md").read_text()
from Cython.Build import cythonize

setup(
    ext_modules=cythonize(["MorphologicalDisambiguation/*.pyx"],
                          compiler_directives={'language_level': "3"}),
    name='NlpToolkit-MorphologicalDisambiguation-Cy',
    version='1.0.6',
    packages=['MorphologicalDisambiguation'],
    package_data={'MorphologicalDisambiguation': ['*.pxd', '*.pyx', '*.c']},
    url='https://github.com/StarlangSoftware/TurkishMorphologicalDisambiguation-Cy',
    license='',
    author='olcaytaner',
    author_email='olcay.yildiz@ozyegin.edu.tr',
    description='Turkish Morphological Disambiguation Library',
    install_requires=['NlpToolkit-MorphologicalAnalysis-Cy', 'NlpToolkit-NGram-Cy'],
    long_description=long_description,
    long_description_content_type='text/markdown'
)
