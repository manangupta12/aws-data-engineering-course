"""Pure-Python MapReduce simulation for teaching (runs on your laptop, no Hadoop)."""

from __future__ import print_function

from collections import defaultdict
import re

WORD = re.compile(r"[a-zA-Z]+")


def map_wordcount(lines):
    """Map: each line -> (word, 1) pairs."""
    for line in lines:
        for word in WORD.findall(line.lower()):
            yield word, 1


def shuffle(pairs):
    """Shuffle: group values by key (Hadoop does this between map and reduce)."""
    grouped = defaultdict(list)
    for key, value in pairs:
        grouped[key].append(value)
    return grouped


def reduce_sum(grouped):
    """Reduce: sum numeric values per key."""
    return {key: sum(values) for key, values in grouped.items()}


def run_wordcount(lines):
    """End-to-end word count without Hadoop."""
    mapped = list(map_wordcount(lines))
    grouped = shuffle(mapped)
    return reduce_sum(grouped)


def top_n(counts, n=10):
    """Return the n highest counts as sorted (word, count) pairs."""
    return sorted(counts.items(), key=lambda item: item[1], reverse=True)[:n]
