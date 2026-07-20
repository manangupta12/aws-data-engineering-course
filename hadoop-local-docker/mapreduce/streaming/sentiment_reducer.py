#!/usr/bin/env python
"""Reduce phase: sum sentiment keyword hits per category."""
from __future__ import print_function

import sys


def main():
    current_key = None
    current_count = 0

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        key, count = line.split("\t", 1)
        count = int(count)

        if current_key == key:
            current_count += count
        else:
            if current_key is not None:
                print("{0}\t{1}".format(current_key, current_count))
            current_key = key
            current_count = count

    if current_key is not None:
        print("{0}\t{1}".format(current_key, current_count))


if __name__ == "__main__":
    main()
