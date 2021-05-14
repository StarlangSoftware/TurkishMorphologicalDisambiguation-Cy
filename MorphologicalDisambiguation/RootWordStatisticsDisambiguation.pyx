from MorphologicalDisambiguation.AutoDisambiguator import AutoDisambiguator
from DisambiguationCorpus.DisambiguationCorpus cimport DisambiguationCorpus
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator
from MorphologicalAnalysis.FsmParseList cimport FsmParseList
from MorphologicalAnalysis.FsmParse cimport FsmParse
from MorphologicalDisambiguation.RootWordStatistics cimport RootWordStatistics

cdef class RootWordStatisticsDisambiguation(MorphologicalDisambiguator):

    cpdef RootWordStatistics rootWordStatistics

    cpdef train(self, DisambiguationCorpus corpus):
        """
        Train method implements method in MorphologicalDisambiguator.

        PARAMETERS
        ----------
        corpus : DisambiguationCorpus
            DisambiguationCorpus to train.
        """
        self.rootWordStatistics = RootWordStatistics("../penntreebank_statistics.txt")

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
        cdef str bestRoot, rootWords
        correctFsmParses = []
        i = 0
        for fsmParseList in fsmParses:
            rootWords = fsmParseList.rootWords()
            if "$" in rootWords:
                bestRoot = self.rootWordStatistics.bestRootWord(fsmParseList, 0.0)
                if bestRoot is None:
                    bestRoot = fsmParseList.getParseWithLongestRootWord().getWord().getName()
            else:
                bestRoot = rootWords
            if bestRoot is not None:
                fsmParseList.reduceToParsesWithSameRoot(bestRoot)
                newBestParse = AutoDisambiguator.caseDisambiguator(i, fsmParses, correctFsmParses)
                if newBestParse is not None:
                    bestParse = newBestParse
                else:
                    bestParse = fsmParseList.getFsmParse(0)
            else:
                bestParse = fsmParseList.getFsmParse(0)
            correctFsmParses.append(bestParse)
            i = i + 1
        return correctFsmParses

    cpdef saveModel(self):
        pass

    cpdef loadModel(self):
        pass
