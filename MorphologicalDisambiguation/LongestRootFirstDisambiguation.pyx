from MorphologicalDisambiguation.AutoDisambiguator import AutoDisambiguator
from MorphologicalDisambiguation.DisambiguationCorpus cimport DisambiguationCorpus
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator
from MorphologicalAnalysis.FsmParseList cimport FsmParseList
from MorphologicalAnalysis.FsmParse cimport FsmParse


cdef class LongestRootFirstDisambiguation(MorphologicalDisambiguator):

    cpdef train(self, DisambiguationCorpus corpus):
        """
        Train method implements method in MorphologicalDisambiguator.

        PARAMETERS
        ----------
        corpus : DisambiguationCorpus
            DisambiguationCorpus to train.
        """
        pass

    cpdef list disambiguate(self, list fsmParses):
        """
        The disambiguate method gets an array of fsmParses. Then loops through that parses and finds the longest root
        word. At the end, gets the parse with longest word among the fsmParses and adds it to the correctFsmParses
        list.

        PARAMETERS
        ----------
        fsmParses : list
            FsmParseList to disambiguate.

        RETURNS
        -------
        list
            CorrectFsmParses list.
        """
        cdef int i
        cdef list correctFsmParses
        cdef FsmParseList fsmParseList
        cdef FsmParse bestParse, newBestParse
        correctFsmParses = []
        i = 0
        for fsmParseList in fsmParses:
            bestParse = fsmParseList.getParseWithLongestRootWord()
            fsmParseList.reduceToParsesWithSameRootAndPos(bestParse.getWordWithPos())
            newBestParse = AutoDisambiguator.caseDisambiguator(i, fsmParses, correctFsmParses)
            if newBestParse is not None:
                bestParse = newBestParse
            correctFsmParses.append(bestParse)
            i = i + 1
        return correctFsmParses

    cpdef saveModel(self):
        pass

    cpdef loadModel(self):
        pass
