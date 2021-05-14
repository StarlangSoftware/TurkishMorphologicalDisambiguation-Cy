from random import randrange

from DisambiguationCorpus.DisambiguationCorpus cimport DisambiguationCorpus
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator
from MorphologicalAnalysis.FsmParseList cimport FsmParseList


cdef class DummyDisambiguation(MorphologicalDisambiguator):

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
        Overridden disambiguate method takes an array of FsmParseList and loops through its items, if the current
        FsmParseList's size is greater than 0, it adds a random parse of this list to the correctFsmParses list.

        PARAMETERS
        ----------
        fsmParses : list
            FsmParseList to disambiguate.

        RETURNS
        -------
        list
            CorrectFsmParses list.
        """
        cdef list correctFsmParses
        cdef FsmParseList fsmParseList
        correctFsmParses = []
        for fsmParseList in fsmParses:
            if fsmParseList.size() > 0:
                correctFsmParses.append(fsmParseList.getFsmParse(randrange(fsmParseList.size())))
        return correctFsmParses
