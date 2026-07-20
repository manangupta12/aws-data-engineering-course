#!/usr/bin/env python
"""Map phase: tag review lines with positive or negative sentiment keywords."""
from __future__ import print_function

import re
import sys

WORD = re.compile(r"[a-zA-Z]+")

POSITIVE = {
    "great", "love", "excellent", "recommend", "happy", "amazing",
    "smoothly", "perfect", "good", "well", "comfortable", "sturdy",
    "lightweight", "soft", "stars", "fast",
}

NEGATIVE = {
    "poor", "disappointed", "bad", "broke", "damaged", "slow",
    "irritation", "cancelled", "delayed", "stopped", "faded",
}


def main():
    for line in sys.stdin:
        tokens = set(WORD.findall(line.lower()))
        if tokens & POSITIVE:
            print("positive\t1")
        if tokens & NEGATIVE:
            print("negative\t1")


if __name__ == "__main__":
    main()
