cdef class NaiveDisambiguation(MorphologicalDisambiguator):

    cpdef saveModel(self):
        """
        The saveModel method writes the specified objects i.e wordUniGramModel and igUniGramModel to the
        words1.txt and igs1.txt.
        """
        self.wordUniGramModel.saveAsText("words1.txt")
        self.igUniGramModel.saveAsText("igs1.txt")

    cpdef loadModel(self):
        """
        The loadModel method reads objects at the words1.txt and igs1.txt to the wordUniGramModel and igUniGramModel.
        """
        self.wordUniGramModel = NGram("words1.txt")
        self.igUniGramModel = NGram("igs1.txt")
