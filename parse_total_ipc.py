#!/usr/bin/env python3

import sys
import re
import os

def extract_benchmark_name(filename):
    # Extract the substring up to the first underscore
    idx = filename.find('.')
    if idx == -1:
        benchmark_name = filename
    else:
        benchmark_name = filename[:idx]
        # If the underscore is immediately preceded by a hyphen, omit the hyphen
        if benchmark_name.endswith('-'):
            benchmark_name = benchmark_name[:-1]
    return benchmark_name


def extract_benchmark_and_config(filepath):
    filename = os.path.basename(filepath)
    # Define the regular expression pattern
    pattern = r"(.+?)_(BASELINE|VELRR_ONLY|VELRU_L1|VELRR_VELRU_L1)\.dat"
    
    # Match the pattern against the filename
    match = re.match(pattern, filename)
    if match:
        benchmark_name = match.group(1)  # Extracts BENCHMARK-NAME
        config_name = match.group(2)     # Extracts CONFIG
        return benchmark_name, config_name
    else:
        return None, None  # Return None if the pattern doesn't match


def process_file(filename):
    pattern = re.compile(r'gpu_tot_ipc\s*=\s*([^\s#]+)', re.IGNORECASE)
    last_value = None
    try:
        with open(filename, 'r') as file:
            for line_number, line in enumerate(file, 1):
                match = pattern.search(line)
                if match:
                    last_value_str = match.group(1)
                    # Attempt to convert to float or int
                    try:
                        if '.' in last_value_str:
                            last_value = float(last_value_str)
                        else:
                            last_value = int(last_value_str)
                    except ValueError:
                        # If conversion fails, keep it as a string
                        last_value = last_value_str
    except FileNotFoundError:
        print(f"Error: The file '{filename}' does not exist.")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None


    #benchmark_name = extract_benchmark_name(filename)
    benchmark_name, config_name = extract_benchmark_and_config(filename);

    # Print the results as a space-delimited CSV row
    print(f"{benchmark_name},\t {config_name},\t {last_value}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: script.py filename1 [filename2 ...]")
        sys.exit(1)

    
    print("Workload\t Configuration\t\t Instructions Executed\t Total Cycles\t, IPC")
    for filename in sys.argv[1:]:
        process_file(filename)

