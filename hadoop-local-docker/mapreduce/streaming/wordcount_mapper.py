#!/usr/bin/env python
"""Map phase: emit (word, 1) for each token in a line of text."""
from __future__ import print_function

import re
import sys

WORD = re.compile(r"[a-zA-Z]+")


def main():
    for line in sys.stdin:
        for word in WORD.findall(line.lower()):
            print("{0}\t{1}".format(word, 1))


if __name__ == "__main__":
    main()
