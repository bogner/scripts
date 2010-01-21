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
        sep = '%x' % FIELD_SEPARATOR
        logFormat = ('%x' + sep).join(['%h', '%p', '%d'])
        stream = self.gitLog.getLogStream(logFormat)
        reader = csv.reader(stream, delimiter = chr(FIELD_SEPARATOR))
        for sha1, parents, refnames in reader:
            edges = ['"%s"->"%s"' % (parent, sha1)
                     for parent in parents.split()]

            label = None
            refnames = refnames.strip()
            if refnames:
                if refnames[0] == '(':
                    refnames = refnames[1:]
                if refnames[-1] == ')':
                    refnames = refnames[:-1]

                names = refnames.split(', ')
                if len(names) == 1:
                    label = '/'.join(names[0].split('/')[2:])
                elif len(names) > 1:
                    namesByKind = {}
                    for name in names:
                        kind = name.split('/')[1]
                        realname = '/'.join(name.split('/')[2:])
                        namesByKind[kind] = realname
                    keys = namesByKind.keys()
                    for kind in ('tags', 'heads', 'remotes'):
                        if kind in keys:
                            label = namesByKind[kind]
                            break
            if not label:
                label = sha1
            line = '"%s" [label="%s"];%s;' % (sha1, label, ';'.join(edges))
            self._writeLine(line)

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

    def testOneCommit(self):
        self.gitLog.addCommit()
        self.generator.generate()
        self.assert_(self.output.isDotFormat())
        self.assertEqual(1, self.output.getNumberOfNodes())

    def tearDown(self):
        self.output.close()

class FakeDotOutput(StringIO):
    def isDotFormat(self):
        match = self._search('^\s*digraph \w+ {(.|\n)*}\s*$')
        return match is not None

    def _search(self, pattern):
        return re.search(pattern, self.getvalue())

    def getNumberOfNodes(self):
        nodes = self._findall('"\d+"( \[[^]]+\])?;')
        return len(nodes)

    def _findall(self, pattern):
        return re.findall(pattern, self.getvalue())

class FakeGitLog:
    def __init__(self):
        self._commits = []

    def addCommit(self):
        self._commits.append(FakeCommit())

    def getLogStream(self, format):
        lines = [str(commit) for commit in self._commits]
        return StringIO('\n'.join(lines))

class FakeCommit:
    def __str__(self):
        return chr(FIELD_SEPARATOR).join(['0', '', ''])

if __name__ == '__main__':
    main(sys.argv)
