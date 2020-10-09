from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator
from NGram.NGram cimport NGram


cdef class NaiveDisambiguation(MorphologicalDisambiguator):

    cdef NGram wordUniGramModel
    cdef NGram igUniGramModel

    cpdef saveModel(self)
    cpdef loadModel(self)
