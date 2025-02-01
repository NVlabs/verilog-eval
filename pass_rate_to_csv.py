#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: Copyright (c) 2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: MIT
# Author : Nathaniel Pinckney, NVIDIA
#

import csv
import re
import subprocess

# Execute the find command and capture the output
command = "find . -name 'summary.txt' | xargs grep pass_rate | sort"
result = subprocess.run(command, shell=True, capture_output=True, text=True)

# Get the output from the command
data = result.stdout

# Parse the output data
pattern = re.compile(r'\./build_([^_\s]+)_(\S+)_shots(\d+)_n(\d+)/summary\.txt:pass_rate\s+=\s+(\d+\.\d+)')
matches = pattern.findall(data)

# Organize data into a dictionary
results = {}
for match in matches:
    task, model, shots, samples, pass_rate = match
    # task_model = f"{task}_{model}"
    task_model = f"{model}"
    if task_model not in results:
        results[task_model] = {}
    results[task_model][f"{task}_shots{shots}_n{samples}"] = pass_rate

# Get all possible column names
columns = set()
for task_model, data in results.items():
    columns.update(data.keys())
columns = sorted(columns)

# Write to CSV
with open('pass_rates.csv', 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    header = ['Model'] + columns
    csvwriter.writerow(header)
    for task_model, data in results.items():
        row = [task_model] + [data.get(col, '') for col in columns]
        csvwriter.writerow(row)

print("CSV file 'pass_rates.csv' created successfully.")
