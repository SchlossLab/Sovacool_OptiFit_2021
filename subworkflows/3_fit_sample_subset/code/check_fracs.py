#!/usr/local/bin/python3
import sys
def main():
    ref_frac = float(sys.argv[1])
    sample_frac = float(sys.argv[2])
    total = ref_frac + sample_frac
    if ref_frac + sample_frac != 1:
        raise ValueError(f'Fractions do not sum to 1. Sum: {total}')
main()