from distutils.core import setup
from Cython.Build import cythonize

setup(
    ext_modules=cythonize(["MorphologicalDisambiguation/*.pyx"],
                          compiler_directives={'language_level': "3"}),
    name='NlpToolkit-MorphologicalDisambiguation-Cy',
    version='1.0.1',
    packages=['MorphologicalDisambiguation'],
    package_data={'MorphologicalDisambiguation': ['*.pxd', '*.pyx', '*.c']},
    url='https://github.com/olcaytaner/TurkishMorphologicalDisambiguation-Cy',
    license='',
    author='olcay',
    author_email='olcaytaner@isikun.edu.tr',
    description='Turkish Morphological Disambiguation Library',
    install_requires=['NlpToolkit-MorphologicalAnalysis-Cy', 'NlpToolkit-NGram-Cy']
)
