from Dictionary.Word cimport Word
from MorphologicalAnalysis.FsmParse cimport FsmParse
from MorphologicalAnalysis.FsmParseList cimport FsmParseList
from NGram.LaplaceSmoothing cimport LaplaceSmoothing
from NGram.NGram cimport NGram
from Corpus.Sentence cimport Sentence

from DisambiguationCorpus.DisambiguatedWord cimport DisambiguatedWord
from DisambiguationCorpus.DisambiguationCorpus cimport DisambiguationCorpus
from MorphologicalDisambiguation.NaiveDisambiguation cimport NaiveDisambiguation


cdef class RootFirstDisambiguation(NaiveDisambiguation):

    cdef NGram wordBiGramModel
    cdef NGram igBiGramModel

    cpdef train(self, DisambiguationCorpus corpus):
        """
        The train method initially creates new NGrams; wordUniGramModel, wordBiGramModel, igUniGramModel, and
        igBiGramModel. It gets the sentences from given corpus and gets each word as a DisambiguatedWord. Then, adds the
        word together with its part of speech tags to the wordUniGramModel. It also gets the transition list of that
        word and adds it to the igUniGramModel.

        If there exists a next word in the sentence, it adds the current and next {@link DisambiguatedWord} to the
        wordBiGramModel with their part of speech tags. It also adds them to the igBiGramModel with their transition
        lists.

        At the end, it calculates the NGram probabilities of both word and ig unigram models by using LaplaceSmoothing,
        and both word and ig bigram models by using InterpolatedSmoothing.

        PARAMETERS
        ----------
        corpus : DisambiguationCorpus
            DisambiguationCorpus to train.
        """
        cdef list words1, words2
        cdef list igs1, igs2
        cdef Sentence sentence
        cdef int j
        cdef Word word
        words1 = [None]
        igs1 = [None]
        words2 = [None, None]
        igs2 = [None, None]
        self.wordUniGramModel = NGram(1)
        self.wordBiGramModel = NGram(2)
        self.igUniGramModel = NGram(1)
        self.igBiGramModel = NGram(2)
        for sentence in corpus.sentences:
            for j in range(sentence.wordCount()):
                word = sentence.getWord(j)
                if isinstance(word, DisambiguatedWord):
                    words1[0] = word.getParse().getWordWithPos()
                    self.wordUniGramModel.addNGram(words1)
                    igs1[0] = Word(word.getParse().getTransitionList())
                    self.igUniGramModel.addNGram(igs1)
                    if j + 1 < sentence.wordCount():
                        words2[0] = words1[0]
                        words2[1] = sentence.getWord(j + 1).getParse().getWordWithPos()
                        self.wordBiGramModel.addNGram(words2)
                        igs2[0] = igs1[0]
                        igs2[1] = Word(sentence.getWord(j + 1).getParse().getTransitionList())
                        self.igBiGramModel.addNGram(igs2)
        self.wordUniGramModel.calculateNGramProbabilitiesSimple(LaplaceSmoothing())
        self.igUniGramModel.calculateNGramProbabilitiesSimple(LaplaceSmoothing())
        self.wordBiGramModel.calculateNGramProbabilitiesSimple(LaplaceSmoothing())
        self.igBiGramModel.calculateNGramProbabilitiesSimple(LaplaceSmoothing())

    cpdef double getWordProbability(self, Word word, list correctFsmParses, int index):
        """
        The getWordProbability method returns the probability of a word by using word bigram or unigram model.

        PARAMETERS
        ----------
        word : Word
            Word to find the probability.
        correctFsmParses : list
            FsmParse of given word which will be used for getting part of speech tags.
        index : int
            Index of FsmParse of which part of speech tag will be used to get the probability.

        RETURNS
        -------
        float
            The probability of the given word.
        """
        if index != 0 and len(correctFsmParses) == index:
            return self.wordBiGramModel.getProbability(correctFsmParses[index - 1].getWordWithPos(), word)
        else:
            return self.wordUniGramModel.getProbability(word)

    cpdef double getIgProbability(self, Word word, list correctFsmParses, int index):
        """
        The getIgProbability method returns the probability of a word by using ig bigram or unigram model.

        PARAMETERS
        ----------
        word : Word
            Word to find the probability.
        correctFsmParses : list
            FsmParse of given word which will be used for getting transition list.
        index : int
            Index of FsmParse of which transition list will be used to get the probability.

        RETURNS
        -------
        float
            The probability of the given word.
        """
        if index != 0 and len(correctFsmParses) == index:
            return self.igBiGramModel.getProbability(Word(correctFsmParses[index - 1].getTransitionList()), word)
        else:
            return self.igUniGramModel.getProbability(word)

    cpdef Word getBestRootWord(self, FsmParseList fsmParseList):
        """
        The getBestRootWord method takes a FsmParseList as an input and loops through the list. It gets each word with
        its part of speech tags as a new Word word and its transition list as a Word ig. Then, finds their corresponding
        probabilities. At the end returns the word with the highest probability.

        PARAMETERS
        ----------
        fsmParseList : FsmParseList
            FsmParseList is used to get the part of speech tags and transition lists of words.

        RETURNS
        -------
        Word
            The word with the highest probability.
        """
        cdef double bestProbability, wordProbability, igProbability, probability
        cdef Word bestWord, word, ig
        cdef int j
        bestProbability = -1
        bestWord = None
        for j in range(fsmParseList.size()):
            word = fsmParseList.getFsmParse(j).getWordWithPos()
            ig = Word(fsmParseList.getFsmParse(j).getTransitionList())
            wordProbability = self.wordUniGramModel.getProbability(word)
            igProbability = self.igUniGramModel.getProbability(ig)
            probability = wordProbability * igProbability
            if probability > bestProbability:
                bestWord = word
                bestProbability = probability
        return bestWord

    cpdef FsmParse getParseWithBestIgProbability(self, FsmParseList parseList, list correctFsmParses, int index):
        """
        The getParseWithBestIgProbability gets each FsmParse's transition list as a Word ig. Then, finds the
        corresponding probability. At the end returns the parse with the highest ig probability.

        PARAMETERS
        ----------
        parseList : FsmParseList
            FsmParseList is used to get the FsmParse.
        correctFsmParses : list
            FsmParse is used to get the transition lists.
        index : int
            Index of FsmParse of which transition list will be used to get the probability.

        RETURNS
        -------
        FsmParse
            The parse with the highest probability.
        """
        cdef FsmParse bestParse
        cdef double bestProbability, probability
        cdef int j
        cdef Word ig
        bestParse = None
        bestProbability = -1
        for j in range(parseList.size()):
            ig = Word(parseList.getFsmParse(j).getTransitionList())
            probability = self.getIgProbability(ig, correctFsmParses, index)
            if probability > bestProbability:
                bestParse = parseList.getFsmParse(j)
                bestProbability = probability
        return bestParse

    cpdef list disambiguate(self, list fsmParses):
        """
        The disambiguate method gets an array of fsmParses. Then loops through that parses and finds the most probable
        root word and removes the other words which are identical to the most probable root word. At the end, gets the
        most probable parse among the fsmParses and adds it to the correctFsmParses list.

        PARAMETERS
        ----------
        fsmParses : list
            FsmParseList to disambiguate.

        RETURNS
        -------
        list
            CcorrectFsmParses list which holds the most probable parses.
        """
        cdef list correctFsmParses
        cdef int i
        cdef Word bestWord
        cdef FsmParse bestParse
        correctFsmParses = []
        for i in range(len(fsmParses)):
            bestWord = self.getBestRootWord(fsmParses[i])
            fsmParses[i].reduceToParsesWithSameRootAndPos(bestWord)
            bestParse = self.getParseWithBestIgProbability(fsmParses[i], correctFsmParses, i)
            if bestParse is not None:
                correctFsmParses.append(bestParse)
        return correctFsmParses

    cpdef saveModel(self):
        """
        Method to save unigrams and bigrams.
        """
        super().saveModel()
        self.wordBiGramModel.saveAsText("words2.txt")
        self.igBiGramModel.saveAsText("igs2.txt")

    cpdef loadModel(self):
        """
        Method to load unigrams and bigrams.
        """
        super().loadModel()
        self.wordBiGramModel = NGram("words2.txt")
        self.igBiGramModel = NGram("igs2.txt")
