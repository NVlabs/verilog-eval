#!/usr/bin/env python3
"""
VerilogEval Ollama Testing - Batch Test All Models

This script runs VerilogEval tests on all specified Ollama models sequentially.

Features:
- Tests multiple models in sequence
- Cleans up memory between models
- Tracks timing for each model
- Generates comparative summary report

Usage:
    python run_all_models.py
    python run_all_models.py --limit 10  # Test only first 10 problems per model

SPDX-FileCopyrightText: Copyright (c) 2024
SPDX-License-Identifier: MIT
"""

import sys
import os
import argparse
import subprocess
import time
import json
from typing import List, Dict, Optional
from dataclasses import dataclass
from pathlib import Path

# Color codes for terminal output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

# Models to test (in order from smallest to largest)
MODELS = [
    "llama3.2:3b",
    "mistral:7b",
    "qwen3:8b",
    "gemma3:12b",
    "deepseek-r1:14b",
    "phi4:14b",
    "gpt-oss:20b",
]

@dataclass
class ModelTestSummary:
    """Summary of test results for one model"""
    model_name: str
    total_problems: int
    passed: int
    compiled: int
    generated: int
    pass_rate: float
    compile_rate: float
    total_time: float
    avg_time_per_problem: float
    output_dir: str
    error: Optional[str] = None

def print_header(text: str):
    """Print a formatted header"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*70}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*70}{Colors.RESET}\n")

def print_success(text: str):
    """Print success message"""
    print(f"{Colors.GREEN}✓ {text}{Colors.RESET}")

def print_error(text: str):
    """Print error message"""
    print(f"{Colors.RED}✗ {text}{Colors.RESET}")

def print_info(text: str):
    """Print info message"""
    print(f"  {text}")

def cleanup_memory():
    """Try to free up memory between model runs"""
    print_info("Cleaning up memory...")

    # Try to stop all Ollama models (may not work in all Ollama versions)
    try:
        # Method 1: Use ollama ps to get running models, then stop them
        result = subprocess.run(
            ['ollama', 'ps'],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0:
            # Parse output to find model names
            lines = result.stdout.strip().split('\n')
            if len(lines) > 1:  # Skip header
                for line in lines[1:]:
                    parts = line.split()
                    if parts:
                        model_name = parts[0]
                        try:
                            subprocess.run(
                                ['ollama', 'stop', model_name],
                                capture_output=True,
                                timeout=10
                            )
                            print_info(f"Stopped model: {model_name}")
                        except:
                            pass

    except Exception as e:
        print_info(f"Note: Could not cleanup models: {e}")

    # Wait a bit for memory to be freed
    time.sleep(2)

def run_model_test(model: str, limit: Optional[int] = None, start: int = 0) -> Optional[ModelTestSummary]:
    """
    Run VerilogEval test for a single model

    Returns:
        ModelTestSummary or None if failed
    """
    print_header(f"Testing Model: {model}")

    model_name_safe = model.replace(':', '_').replace('/', '_')
    output_dir = f"results/{model_name_safe}_0shot_temp0.0"

    # Build command
    cmd = [
        'python',
        'run_verilog_eval.py',
        '--model', model,
        '--output-dir', output_dir
    ]

    if limit is not None:
        cmd.extend(['--limit', str(limit)])

    if start > 0:
        cmd.extend(['--start', str(start)])

    print_info(f"Command: {' '.join(cmd)}")
    print()

    # Run test
    start_time = time.time()

    try:
        result = subprocess.run(
            cmd,
            timeout=None  # No timeout, let it run
        )

        end_time = time.time()
        total_time = end_time - start_time

        if result.returncode != 0:
            print_error(f"Test failed with return code: {result.returncode}")
            return ModelTestSummary(
                model_name=model,
                total_problems=0,
                passed=0,
                compiled=0,
                generated=0,
                pass_rate=0.0,
                compile_rate=0.0,
                total_time=total_time,
                avg_time_per_problem=0.0,
                output_dir=output_dir,
                error=f"Return code: {result.returncode}"
            )

    except subprocess.TimeoutExpired:
        print_error("Test timed out")
        return None
    except KeyboardInterrupt:
        print_error("Test interrupted by user")
        raise
    except Exception as e:
        print_error(f"Test failed: {e}")
        return ModelTestSummary(
            model_name=model,
            total_problems=0,
            passed=0,
            compiled=0,
            generated=0,
            pass_rate=0.0,
            compile_rate=0.0,
            total_time=0.0,
            avg_time_per_problem=0.0,
            output_dir=output_dir,
            error=str(e)
        )

    # Read results
    results_file = f"{output_dir}/results.json"

    try:
        with open(results_file, 'r') as f:
            data = json.load(f)

        total = data.get('total_problems', 0)
        results = data.get('results', [])

        passed = sum(1 for r in results if r.get('test_success', False))
        compiled = sum(1 for r in results if r.get('compilation_success', False))
        generated = sum(1 for r in results if r.get('success', False))

        pass_rate = (passed / total * 100) if total > 0 else 0.0
        compile_rate = (compiled / total * 100) if total > 0 else 0.0
        avg_time = total_time / total if total > 0 else 0.0

        summary = ModelTestSummary(
            model_name=model,
            total_problems=total,
            passed=passed,
            compiled=compiled,
            generated=generated,
            pass_rate=pass_rate,
            compile_rate=compile_rate,
            total_time=total_time,
            avg_time_per_problem=avg_time,
            output_dir=output_dir
        )

        print_success(f"Test completed: {passed}/{total} passed ({pass_rate:.1f}%)")
        print_info(f"Total time: {total_time/60:.1f} minutes")

        return summary

    except Exception as e:
        print_error(f"Could not read results: {e}")
        return ModelTestSummary(
            model_name=model,
            total_problems=0,
            passed=0,
            compiled=0,
            generated=0,
            pass_rate=0.0,
            compile_rate=0.0,
            total_time=total_time,
            avg_time_per_problem=0.0,
            output_dir=output_dir,
            error=f"Could not read results: {e}"
        )

def generate_comparison_report(summaries: List[ModelTestSummary], output_file: str):
    """Generate a comparison report for all models"""
    lines = [
        "=" * 80,
        "VerilogEval Ollama Models - Comparison Report",
        "=" * 80,
        "",
        f"{'Model':<20} {'Pass@1':<10} {'Compiled':<10} {'Avg Time':<12} {'Total Time':<12}",
        "-" * 80,
    ]

    for summary in summaries:
        if summary.error:
            lines.append(f"{summary.model_name:<20} ERROR: {summary.error}")
        else:
            pass_str = f"{summary.pass_rate:.1f}%"
            compile_str = f"{summary.compile_rate:.1f}%"
            avg_time_str = f"{summary.avg_time_per_problem:.1f}s"
            total_time_str = f"{summary.total_time/60:.1f}m"

            lines.append(
                f"{summary.model_name:<20} {pass_str:<10} {compile_str:<10} "
                f"{avg_time_str:<12} {total_time_str:<12}"
            )

    lines.extend([
        "",
        "=" * 80,
        "Detailed Statistics",
        "=" * 80,
        "",
    ])

    for summary in summaries:
        lines.append(f"\n{summary.model_name}:")
        lines.append(f"  Total problems: {summary.total_problems}")
        lines.append(f"  Successfully generated: {summary.generated}")
        lines.append(f"  Compiled: {summary.compiled} ({summary.compile_rate:.1f}%)")
        lines.append(f"  Passed tests: {summary.passed} ({summary.pass_rate:.1f}%)")
        lines.append(f"  Total time: {summary.total_time/60:.1f} minutes")
        lines.append(f"  Avg time/problem: {summary.avg_time_per_problem:.1f}s")
        lines.append(f"  Output directory: {summary.output_dir}")

        if summary.error:
            lines.append(f"  Error: {summary.error}")

    report_text = "\n".join(lines)

    # Write to file
    with open(output_file, 'w') as f:
        f.write(report_text)

    # Also print to console
    print("\n" + report_text)

def generate_csv_comparison(summaries: List[ModelTestSummary], output_file: str):
    """Generate CSV comparison report"""
    lines = [
        "model,total_problems,generated,compiled,passed,pass_rate,compile_rate,total_time_min,avg_time_sec,error"
    ]

    for summary in summaries:
        error_str = summary.error if summary.error else ""
        lines.append(
            f"{summary.model_name},{summary.total_problems},{summary.generated},"
            f"{summary.compiled},{summary.passed},{summary.pass_rate:.2f},"
            f"{summary.compile_rate:.2f},{summary.total_time/60:.2f},"
            f"{summary.avg_time_per_problem:.2f},{error_str}"
        )

    with open(output_file, 'w') as f:
        f.write("\n".join(lines))

def main():
    parser = argparse.ArgumentParser(
        description="Run VerilogEval tests on all Ollama models"
    )
    parser.add_argument(
        '--limit',
        type=int,
        default=None,
        help='Limit number of problems to test per model (for quick validation)'
    )
    parser.add_argument(
        '--start',
        type=int,
        default=0,
        help='Start from problem N (0-indexed)'
    )
    parser.add_argument(
        '--models',
        type=str,
        nargs='+',
        default=None,
        help='Specific models to test (default: all models)'
    )
    parser.add_argument(
        '--skip-cleanup',
        action='store_true',
        help='Skip memory cleanup between models'
    )

    args = parser.parse_args()

    # Determine which models to test
    models_to_test = args.models if args.models else MODELS

    print(f"\n{Colors.BOLD}VerilogEval Ollama Testing - Batch Mode{Colors.RESET}")
    print(f"{'='*70}\n")
    print(f"Models to test: {', '.join(models_to_test)}")

    if args.limit:
        print(f"Limit: {args.limit} problems per model")

    print()

    # Run tests for all models
    summaries = []
    overall_start_time = time.time()

    for i, model in enumerate(models_to_test):
        try:
            # Cleanup memory before starting (except for first model)
            if i > 0 and not args.skip_cleanup:
                cleanup_memory()

            # Run test
            summary = run_model_test(model, limit=args.limit, start=args.start)

            if summary:
                summaries.append(summary)

        except KeyboardInterrupt:
            print_error("\nBatch testing interrupted by user")
            break
        except Exception as e:
            print_error(f"Unexpected error with model {model}: {e}")
            continue

    overall_end_time = time.time()
    overall_time = overall_end_time - overall_start_time

    # Generate comparison reports
    if summaries:
        print_header("Generating Comparison Reports")

        os.makedirs("results", exist_ok=True)

        report_file = "results/all_models_comparison.txt"
        csv_file = "results/all_models_comparison.csv"

        generate_comparison_report(summaries, report_file)
        generate_csv_comparison(summaries, csv_file)

        print()
        print_success(f"Comparison reports saved:")
        print_info(f"  Text report: {report_file}")
        print_info(f"  CSV report: {csv_file}")
        print()
        print_info(f"Overall time: {overall_time/3600:.1f} hours")

    else:
        print_error("No models completed successfully")

if __name__ == "__main__":
    main()
