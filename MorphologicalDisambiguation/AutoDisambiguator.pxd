from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from MorphologicalAnalysis.FsmParse cimport FsmParse
from MorphologicalDisambiguation.RootWordStatistics cimport RootWordStatistics


cdef class AutoDisambiguator:

    cdef FsmMorphologicalAnalyzer morphologicalAnalyzer
    cdef RootWordStatistics rootWordStatistics
