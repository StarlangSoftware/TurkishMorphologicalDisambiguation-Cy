from MorphologicalDisambiguation.AutoDisambiguator import AutoDisambiguator
from DisambiguationCorpus.DisambiguationCorpus cimport DisambiguationCorpus
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator
from MorphologicalAnalysis.FsmParseList cimport FsmParseList
from MorphologicalAnalysis.FsmParse cimport FsmParse


cdef class LongestRootFirstDisambiguation(MorphologicalDisambiguator):

    cdef dict rootList

    def __init__(self, fileName=None):
        self.rootList = {}
        if fileName is None:
            self.__readFromFile("../rootlist.txt")
        else:
            self.__readFromFile(fileName)

    cpdef __readFromFile(self, str fileName):
        cdef list lines
        cdef list wordList
        cdef str line
        inputFile = open(fileName, "r", encoding="utf8")
        lines = inputFile.readlines()
        for line in lines:
            wordList = line.split()
            if len(wordList) == 2:
                self.rootList[wordList[0]] = wordList[1]
        inputFile.close()

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
        cdef str surfaceForm, bestRoot
        cdef bint rootFound
        correctFsmParses = []
        i = 0
        for fsmParseList in fsmParses:
            surfaceForm = fsmParseList.getFsmParse(0).getSurfaceForm()
            bestRoot = None
            rootFound = False
            if surfaceForm in self.rootList:
                bestRoot = self.rootList[surfaceForm]
                for j in range(fsmParseList.size()):
                    if fsmParseList.getFsmParse(j).getWord().getName() == bestRoot:
                        rootFound = True
            if bestRoot is None or not rootFound:
                bestParse = fsmParseList.getParseWithLongestRootWord()
                fsmParseList.reduceToParsesWithSameRoot(bestParse.getWord().getName())
            else:
                fsmParseList.reduceToParsesWithSameRoot(bestRoot)
            newBestParse = AutoDisambiguator.caseDisambiguator(i, fsmParses, correctFsmParses)
            if newBestParse is not None:
                bestParse = newBestParse
            else:
                bestParse = fsmParseList.getFsmParse(0)
            correctFsmParses.append(bestParse)
            i = i + 1
        return correctFsmParses

    cpdef saveModel(self):
        pass

    cpdef loadModel(self):
        pass
