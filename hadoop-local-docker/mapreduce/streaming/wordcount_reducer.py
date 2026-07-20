#!/usr/bin/env python
"""Reduce phase: sum counts for each word key."""
from __future__ import print_function

import sys


def main():
    current_word = None
    current_count = 0

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        word, count = line.split("\t", 1)
        count = int(count)

        if current_word == word:
            current_count += count
        else:
            if current_word is not None:
                print("{0}\t{1}".format(current_word, current_count))
            current_word = word
            current_count = count

    if current_word is not None:
        print("{0}\t{1}".format(current_word, current_count))


if __name__ == "__main__":
    main()
