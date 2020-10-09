cdef class RootWordStatistics:

    def __init__(self, fileName=None):
        """
        Constructor of RootWordStatistics class that generates a new map for statistics.
        """
        cdef int i, count, j
        cdef str line, rootWord
        cdef list items
        cdef CounterHashMap wordMap
        self.__statistics = {}
        if fileName is not None:
            inputFile = open(fileName, encoding="utf8")
            size = int(inputFile.readline().strip())
            for i in range(size):
                line = inputFile.readline().strip()
                items = line.split()
                rootWord = items[0]
                count = int(items[1])
                wordMap = CounterHashMap()
                for j in range(count):
                    line = inputFile.readline().strip()
                    items = line.split()
                    wordMap.putNTimes(items[0], int(items[1]))
                self.__statistics[rootWord] = wordMap
            inputFile.close()

    cpdef bint containsKey(self, str key):
        """
        Method to check whether statistics contains the given String.

        PARAMETERS
        ----------
        key : str
            String to look for.

        RETURNS
        -------
        bool
            Returns True if this map contains a mapping for the specified key.
        """
        return key in self.__statistics

    cpdef CounterHashMap get(self, str key):
        """
        Method to get the value of the given String.

        PARAMETERS
        ----------
        key : str
            String to look for.

        RETURNS
        -------
        CounterHashMap
            Returns the value to which the specified key is mapped, or None if this map contains no mapping for the key.
        """
        return self.__statistics[key]

    cpdef put(self, str key, CounterHashMap wordStatistics):
        """
        Method to associates a String along with a CounterHashMap in the statistics.

        PARAMETERS
        ----------
        key : str
            Key with which the specified value is to be associated.
        wordStatistics : CounterHashMap
            Value to be associated with the specified key.
        """
        self.__statistics[key] = wordStatistics

    cpdef str bestRootWord(self, FsmParseList parseList, double threshold):
        """
        The bestRootWord method gets the root word of given FsmParseList and if statistics has a value for that word,
        it returns the max value associated with that word.

        PARAMETERS
        ----------
        parseList : FsmParseList
            FsmParseList to check.
        threshold : float
            A double value for limit.

        RETURNS
        -------
        str
            The max value for the root word.
        """
        cdef str rootWords
        cdef CounterHashMap rootWordStatistics
        rootWords = parseList.rootWords()
        if rootWords in self.__statistics:
            rootWordStatistics = self.__statistics[rootWords]
            return rootWordStatistics.max(threshold)
        return None

    cpdef saveStatistics(self, str fileName):
        """
        Method to save statistics into file specified with the input file name.

        PARAMETERS
        ----------
        fileName : str
            File to save the statistics.
        """
        cdef str rootWord
        cdef CounterHashMap wordMap
        outputFile = open(fileName, mode="w", encoding="utf8")
        outputFile.write(len(self.__statistics).__str__() + "\n")
        for rootWord in self.__statistics:
            wordMap = self.__statistics[rootWord]
            outputFile.write(rootWord + " " + len(wordMap).__str__() + "\n")
            outputFile.write(wordMap.__str__())
        outputFile.close()
