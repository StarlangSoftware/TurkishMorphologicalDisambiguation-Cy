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

    cdef NGram word_bi_gram_model
    cdef NGram ig_bi_gram_model

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
        self.word_uni_gram_model = NGram(1)
        self.word_bi_gram_model = NGram(2)
        self.ig_uni_gram_model = NGram(1)
        self.ig_bi_gram_model = NGram(2)
        for sentence in corpus.sentences:
            for j in range(sentence.wordCount()):
                word = sentence.getWord(j)
                if isinstance(word, DisambiguatedWord):
                    words1[0] = word.getParse().getWordWithPos()
                    self.word_uni_gram_model.addNGram(words1)
                    igs1[0] = Word(word.getParse().getTransitionList())
                    self.ig_uni_gram_model.addNGram(igs1)
                    if j + 1 < sentence.wordCount():
                        words2[0] = words1[0]
                        words2[1] = sentence.getWord(j + 1).getParse().getWordWithPos()
                        self.word_bi_gram_model.addNGram(words2)
                        igs2[0] = igs1[0]
                        igs2[1] = Word(sentence.getWord(j + 1).getParse().getTransitionList())
                        self.ig_bi_gram_model.addNGram(igs2)
        self.word_uni_gram_model.calculateNGramProbabilitiesSimple(LaplaceSmoothing())
        self.ig_uni_gram_model.calculateNGramProbabilitiesSimple(LaplaceSmoothing())
        self.word_bi_gram_model.calculateNGramProbabilitiesSimple(LaplaceSmoothing())
        self.ig_bi_gram_model.calculateNGramProbabilitiesSimple(LaplaceSmoothing())

    cpdef double getWordProbability(self,
                                    Word word,
                                    list correctFsmParses,
                                    int index):
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
            return self.word_bi_gram_model.getProbability(correctFsmParses[index - 1].getWordWithPos(), word)
        else:
            return self.word_uni_gram_model.getProbability(word)

    cpdef double getIgProbability(self,
                                  Word word,
                                  list correctFsmParses,
                                  int index):
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
            return self.ig_bi_gram_model.getProbability(Word(correctFsmParses[index - 1].getTransitionList()), word)
        else:
            return self.ig_uni_gram_model.getProbability(word)

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
        cdef double best_probability, word_probability, ig_probability, probability
        cdef Word best_word, word, ig
        cdef int j
        best_probability = -1
        best_word = None
        for j in range(fsmParseList.size()):
            word = fsmParseList.getFsmParse(j).getWordWithPos()
            ig = Word(fsmParseList.getFsmParse(j).getTransitionList())
            word_probability = self.word_uni_gram_model.getProbability(word)
            ig_probability = self.ig_uni_gram_model.getProbability(ig)
            probability = word_probability * ig_probability
            if probability > best_probability:
                best_word = word
                best_probability = probability
        return best_word

    cpdef FsmParse getParseWithBestIgProbability(self,
                                                 FsmParseList parseList,
                                                 list correctFsmParses,
                                                 int index):
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
        cdef FsmParse best_parse
        cdef double best_probability, probability
        cdef int j
        cdef Word ig
        best_parse = None
        best_probability = -1
        for j in range(parseList.size()):
            ig = Word(parseList.getFsmParse(j).getTransitionList())
            probability = self.getIgProbability(ig, correctFsmParses, index)
            if probability > best_probability:
                best_parse = parseList.getFsmParse(j)
                best_probability = probability
        return best_parse

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
        cdef list correct_fsm_parses
        cdef int i
        cdef Word best_word
        cdef FsmParse best_parse
        correctFsmParses = []
        for i in range(len(fsmParses)):
            best_word = self.getBestRootWord(fsmParses[i])
            fsmParses[i].reduceToParsesWithSameRootAndPos(best_word)
            best_parse = self.getParseWithBestIgProbability(fsmParses[i], correctFsmParses, i)
            if best_parse is not None:
                correctFsmParses.append(best_parse)
        return correctFsmParses

    cpdef saveModel(self):
        """
        Method to save unigrams and bigrams.
        """
        super().saveModel()
        self.word_bi_gram_model.saveAsText("words2.txt")
        self.ig_bi_gram_model.saveAsText("igs2.txt")

    cpdef loadModel(self):
        """
        Method to load unigrams and bigrams.
        """
        super().loadModel()
        self.word_bi_gram_model = NGram("words2.txt")
        self.ig_bi_gram_model = NGram("igs2.txt")
