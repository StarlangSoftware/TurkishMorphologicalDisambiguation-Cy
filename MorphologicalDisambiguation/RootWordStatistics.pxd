from DataStructure.CounterHashMap cimport CounterHashMap
from MorphologicalAnalysis.FsmParseList cimport FsmParseList


cdef class RootWordStatistics:

    cdef dict __statistics

    cpdef bint containsKey(self, str key)
    cpdef CounterHashMap get(self, str key)
    cpdef put(self, str key, CounterHashMap wordStatistics)
    cpdef str bestRootWord(self, FsmParseList parseList, double threshold)
    cpdef saveStatistics(self, str fileName)
