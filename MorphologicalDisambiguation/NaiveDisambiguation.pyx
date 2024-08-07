cdef class NaiveDisambiguation(MorphologicalDisambiguator):

    cpdef saveModel(self):
        """
        The saveModel method writes the specified objects i.e wordUniGramModel and igUniGramModel to the
        words1.txt and igs1.txt.
        """
        self.word_uni_gram_model.saveAsText("words1.txt")
        self.ig_uni_gram_model.saveAsText("igs1.txt")

    cpdef loadModel(self):
        """
        The loadModel method reads objects at the words1.txt and igs1.txt to the wordUniGramModel and igUniGramModel.
        """
        self.word_uni_gram_model = NGram("words1.txt")
        self.ig_uni_gram_model = NGram("igs1.txt")
