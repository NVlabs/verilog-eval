#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: Copyright (c) 2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: MIT
# Author : Nathaniel Pinckney, NVIDIA
#

import os
import pandas as pd
import sys

# Function to process a CSV file and count codes
def process_csv(directory):
    file_path = os.path.join(directory, 'summary.csv')
    if not os.path.exists(file_path):
        print(f"No summary.csv found in {directory}")
        return {}

    # Load the CSV file
    df = pd.read_csv(file_path)

    # Ignore the first 3 columns
    df = df.iloc[:, 4:]

    # Initialize a dictionary to store the counts of each code
    code_counts = {}

    # Iterate over each row in the dataframe
    for index, row in df.iterrows():
        for code in row:
            if code in code_counts:
                code_counts[code] += 1
            else:
                code_counts[code] = 1

    # Return the counts dictionary
    return code_counts

# Function to print counts for a directory
def print_counts(directory, code_counts):
    # Calculate total counts across all categories
    total_counts = sum(code_counts.values())

    # Print total counts
    print(f'Total counts across all categories in {directory}: {total_counts}')

    # Sort the code counts by code, with '.' always at the top
    sorted_codes = sorted(code_counts.keys())
    if '.' in sorted_codes:
        sorted_codes.remove('.')
    sorted_codes.insert(0, '.')

    # Print out the counts of each code with human-readable names
    for code in sorted_codes:
        count = code_counts.get(code, 0)
        reason = code_to_reason.get(code, 'Unknown Reason')
        print(f'{code} ({reason}): {count}')

# Mapping of codes to human-readable names
code_to_reason = {
    '.': 'Pass',
    'S': 'Syntax Error',
    'e': 'Explicit Cast Required',
    '0': 'Sized Numeric Constant Error',
    'n': 'No Sensitivities Warning',
    'w': 'Declared as Wire',
    'm': 'Unknown Module Type',
    'p': 'Unable to Bind Wire/Reg',
    'c': 'Unable to Bind Wire/Reg `clk`',
    'T': 'Timeout',
    '.': 'No Mismatches',
    'r': 'Async reset found',
    'C': 'Compiler error',
    'R': 'Runtime error'
}


# Main script
if __name__ == "__main__":
    directories = sys.argv[1:]
    all_counts = {}

    for directory in directories:
        print(f"\nProcessing directory: {directory}")
        counts = process_csv(directory)
        all_counts[directory] = counts
        print_counts(directory, counts)

    # Prepare data for the summary DataFrame
    summary_data = []

    # Collect all unique codes
    all_codes = set()
    for counts in all_counts.values():
        all_codes.update(counts.keys())

    # Sort codes with '.' at the top
    sorted_codes = sorted(all_codes)
    if '.' in sorted_codes:
        sorted_codes.remove('.')
    sorted_codes.insert(0, '.')

    sorted_codes = [code for code in sorted_codes if code not in ['r', 'R', 'T']] + ['r', 'R', 'T']

    # Create rows for the summary DataFrame
    for code in sorted_codes:
        reason = code_to_reason.get(code, 'Unknown Reason')
        row = {'Code': f'{code} ({reason})'}
        for directory, counts in all_counts.items():
            row[directory] = counts.get(code, 0)
        summary_data.append(row)

    # Create the summary DataFrame
    summary_df = pd.DataFrame(summary_data)

    # Print summary in CSV format
    print("\nSummary in CSV format:")
    print(summary_df.to_csv(index=False))

