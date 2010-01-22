#!/usr/bin/env python
import csv, re, sys, unittest
from StringIO import StringIO
from subprocess import Popen, PIPE

ASCII_UNIT_SEPARATOR = 0x1f
FIELD_SEPARATOR = ASCII_UNIT_SEPARATOR

def main(argv):
    gitLog = GitLog(argv[1:])
    GraphGenerator(sys.stdout, gitLog).generate()

class GitLog:
    def __init__(self, args):
        self.args = args

    def getLogStream(self, format):
        command = ['git', 'log', '--pretty=format:%s' % format] + self.args
        proc = Popen(command, stdout = PIPE)
        return proc.stdout

class LogEntry:
    def __init__(self, sha1, parents, refnames):
        self.sha1 = sha1
        self.parents = parents
        self.refnames = refnames

class Edge:
    def __init__(self, start, end):
        self.start = start
        self.end = end

class GraphGenerator:
    def __init__(self, outputStream, gitLog):
        self.output = outputStream
        self.gitLog = gitLog

    def generate(self):
        self._writeHeader()
        self._writeBody()
        self._writeFooter()

    def _writeHeader(self):
        self._writeLine('digraph G {')

    def _writeLine(self, line):
        self.output.write(line + '\n')

    def _writeBody(self):
        logStream = self._getLogStream()
        for entry in self._readLog(logStream):
            nodeId = self._getNodeId(entry)
            label = self._getLabel(entry)
            edges = self._getEdges(entry)
            line = self._formatLine(nodeId, label, edges)
            self._writeLine(line)

    def _getLogStream(self):
        sep = '%x' % FIELD_SEPARATOR
        logFormat = ('%x' + sep).join(['%h', '%p', '%d'])
        return self.gitLog.getLogStream(logFormat)

    def _readLog(self, stream):
        reader = csv.reader(stream, delimiter = chr(FIELD_SEPARATOR))
        for sha1, parents, edges in reader:
            yield LogEntry(sha1, parents, edges)

    def _getNodeId(self, entry):
        return entry.sha1

    def _getLabel(self, entry):
        label = self._getLabelFromRefNames(entry.refnames)
        if not label:
            label = entry.sha1
        return label

    def _getLabelFromRefNames(self, refnames):
        refnames = self._convertRefNameStringToList(refnames)
        namesByKind = self._mapKindsToNames(refnames)
        keys = namesByKind.keys()
        for kind in ('tags', 'heads', 'remotes'):
            if kind in keys:
                return namesByKind[kind]
        return None

    def _mapKindsToNames(self, names):
        namesByKind = {}
        for name in names:
            kind = name.split('/')[1]
            realname = '/'.join(name.split('/')[2:])
            namesByKind[kind] = realname
        return namesByKind

    def _convertRefNameStringToList(self, refnames):
        refnames = refnames.strip()
        if refnames:
            refnames = self._deparenthesize(refnames)
            return refnames.split(', ')
        return []

    def _deparenthesize(self, string):
        if string[0] == '(' and string[-1] == ')':
            return string[1:-1]
        raise ValueError("String '%s' has no parens to remove" % string)

    def _getEdges(self, entry):
        parents = entry.parents.split()
        return [Edge(parent, entry.sha1) for parent in parents]

    def _formatLine(self, nodeId, label, edges):
        node = self._formatNode(nodeId, label)
        edges = self._formatEdges(edges)
        return node + edges

    def _formatNode(self, nodeId, label):
        return '"%s" [label="%s"];' % (nodeId, label)

    def _formatEdges(self, edges):
        formattedEdges = [self._formatEdge(edge) for edge in edges]
        result = ';'.join(formattedEdges)
        if result is not '':
            result += ';'
        return result

    def _formatEdge(self, edge):
        return '"%s"->"%s"' % (edge.start, edge.end)

    def _writeFooter(self):
        self._writeLine('}')

class TestGitToDot(unittest.TestCase):
    def setUp(self):
        self.output = FakeDotOutput()
        self.gitLog = FakeGitLog()
        self.generator = GraphGenerator(self.output, self.gitLog)

    def testNoCommits(self):
        self.generator.generate()
        self.assert_(self.output.isDotFormat())

    def testSeveralNodes(self, n = 100):
        for _ in range(n):
            self.gitLog.addCommit()
        self.generator.generate()
        self.assertEqual(n, self.output.getNumberOfNodes())
        self.assertEqual(0, self.output.getNumberOfEdges())

    def testOneNode(self):
        self.testSeveralNodes(n = 1)

    def testOneEdge(self):
        commit1 = self.gitLog.addCommit()
        commit2 = self.gitLog.addCommit()
        self.gitLog.addCommit(parents = [commit1, commit2])

        self.generator.generate()
        self.assertEqual(3, self.output.getNumberOfNodes())
        self.assertEqual(2, self.output.getNumberOfEdges())

    def testTag(self):
        self.gitLog.addCommit(refNames = ['refs/tags/foo'])
        self.generator.generate()
        self.assertEqual(1, self.output.getNumberOfNodes())
        self.assertEqual('foo', self.output.getLabelOfNode(0))

    def testHeadAndRemote(self):
        self.gitLog.addCommit(refNames = ['refs/remotes/origin/foo',
                                          'refs/heads/bar'])
        self.generator.generate()
        self.assertEqual(1, self.output.getNumberOfNodes())
        self.assertEqual('bar', self.output.getLabelOfNode(0))

    def tearDown(self):
        self.output.close()

class FakeDotOutput(StringIO):
    dotRegex = '^\s*digraph \w+ {(.|\n)*}\s*$'
    nodeRegex = '(?<=[{;])\s*"\d+"(?: \[[^]]+\])?(?=;)'
    edgeRegex = '(?<=[{;])\s*"\d+"->"\d+"(?: \[[^]]+\])?(?=;)'

    def isDotFormat(self):
        match = self._search(self.dotRegex)
        return match is not None

    def _search(self, pattern):
        return re.search(pattern, self.getvalue())

    def getNumberOfNodes(self):
        nodes = self._findall(self.nodeRegex)
        return len(nodes)

    def getNumberOfEdges(self):
        edges = self._findall(self.edgeRegex)
        return len(edges)

    def getLabelOfNode(self, index):
        nodes = self._findall(self.nodeRegex)
        labels = []
        for node in nodes:
            match = re.search('label="([^"]+)"', node)
            labels.append(match.group(1) or None)
        return labels[index]

    def _findall(self, pattern):
        return re.findall(pattern, self.getvalue())

class FakeGitLog:
    def __init__(self):
        self._commits = []

    def addCommit(self, parents = (), refNames = ()):
        nextId = len(self._commits)
        commit = FakeCommit(nextId, parents, refNames)
        self._commits.append(commit)
        return commit

    def getLogStream(self, format):
        lines = [str(commit) for commit in self._commits]
        return StringIO('\n'.join(lines))

class FakeCommit:
    _fieldSeparator = chr(FIELD_SEPARATOR)

    def __init__(self, commitId, parents, refNames):
        self.commitId = commitId
        self.parentIds = [p.commitId for p in parents]
        self.refNames = refNames

    def __str__(self):
        commitId = self._formatCommitId()
        parentIds = self._formatParentIds()
        refNames = self._formatRefNames()
        fields = [commitId, parentIds, refNames]
        return self._fieldSeparator.join(fields)

    def _formatCommitId(self):
        return str(self.commitId)

    def _formatParentIds(self):
        return ' '.join([str(i) for i in self.parentIds])

    def _formatRefNames(self):
        if 0 == len(self.refNames):
            return ''
        return ' (%s)' % ', '.join([str(i) for i in self.refNames])

if __name__ == '__main__':
    main(sys.argv)
