#!/usr/bin/env python3
"""
VerilogEval Ollama Testing - Main Test Script

This script runs VerilogEval code-complete-iccad2023 tests on Ollama models.

Features:
- Zero-shot testing with low temperature (temp=0.0, top_p=0.01)
- Saves all outputs (raw responses, extracted code, logs)
- Integrated iverilog compilation and testing
- Progress tracking and resume capability
- Generates evaluation reports

Usage:
    python run_verilog_eval.py --model gemma3:12b
    python run_verilog_eval.py --model mistral:7b --limit 10
    python run_verilog_eval.py --model qwen3:8b --start 50 --limit 100

SPDX-FileCopyrightText: Copyright (c) 2024
SPDX-License-Identifier: MIT
"""

import sys
import os
import argparse
import json
import time
import glob
import subprocess
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, asdict
from pathlib import Path

try:
    import ollama
except ImportError:
    print("ERROR: ollama package not installed")
    print("Install with: pip install ollama")
    sys.exit(1)

try:
    from tqdm import tqdm
except ImportError:
    print("ERROR: tqdm package not installed")
    print("Install with: pip install tqdm")
    sys.exit(1)

# ============================================================================
# Configuration
# ============================================================================

DATASET_DIR = "dataset_code-complete-iccad2023"

# System message for code-complete task (from sv-generate)
SYSTEM_MSG = """You only complete chats with syntax correct Verilog code. End the Verilog module code completion with 'endmodule'. Do not include module, input and output definitions."""

# Prompt prefix (from sv-generate)
PROMPT_PREFIX = """// Implement the Verilog module based on the following description. Assume that signals are positive clock/clk triggered unless otherwise stated.
"""

# Generation parameters
TEMPERATURE = 0.0
TOP_P = 0.01
MAX_TOKENS = 1024

# ============================================================================
# Data Classes
# ============================================================================

@dataclass
class ProblemResult:
    """Results from testing a single problem"""
    problem_name: str
    success: bool
    generation_time: float
    compilation_success: bool
    test_success: bool
    error_message: Optional[str] = None

# ============================================================================
# Utility Functions
# ============================================================================

def get_problem_list() -> List[str]:
    """Get list of all problems from dataset directory"""
    prompt_files = sorted(glob.glob(f"{DATASET_DIR}/*_prompt.txt"))

    problems = []
    for file in prompt_files:
        basename = os.path.basename(file)
        # Remove _prompt.txt suffix
        problem_name = basename[:-11]
        problems.append(problem_name)

    return problems

def read_file(filepath: str) -> str:
    """Read file content"""
    try:
        with open(filepath, 'r') as f:
            return f.read()
    except Exception as e:
        print(f"ERROR reading {filepath}: {e}")
        return ""

def write_file(filepath: str, content: str):
    """Write content to file"""
    try:
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w') as f:
            f.write(content)
    except Exception as e:
        print(f"ERROR writing {filepath}: {e}")

def build_prompt(problem_name: str) -> Tuple[str, str, str]:
    """
    Build the complete prompt for a problem

    Returns:
        (full_prompt, problem_description, module_interface)
    """
    prompt_file = f"{DATASET_DIR}/{problem_name}_prompt.txt"
    ifc_file = f"{DATASET_DIR}/{problem_name}_ifc.txt"

    prompt_content = read_file(prompt_file)
    ifc_content = read_file(ifc_file)

    # Convert problem description to comments (following sv-generate logic)
    prefixed_lines = []
    prefix = True

    for line in prompt_content.splitlines():
        if "module TopModule" in line:
            prefixed_lines.append("")
            prefix = False

        if prefix:
            prefixed_lines.append("// " + line)
        else:
            prefixed_lines.append(line)

    prefixed_prompt = "\n".join(prefixed_lines)

    # Build full prompt
    full_prompt = PROMPT_PREFIX + prefixed_prompt

    return full_prompt, prompt_content, ifc_content

def extract_verilog_code(response: str, module_interface: str) -> Tuple[str, str]:
    """
    Extract Verilog code from model response

    Returns:
        (complete_code_with_interface, extracted_code_only)
    """
    lines = response.splitlines()

    # First pass: check for backticks and module definition
    backticks_count = 0
    module_already_exists = False
    endmodule_before_startmodule = False

    for line in lines:
        if line.startswith("```"):
            backticks_count += 1
        elif line.startswith("endmodule"):
            if not module_already_exists:
                endmodule_before_startmodule = True
        elif line.startswith("module TopModule"):
            module_already_exists = True

    if endmodule_before_startmodule:
        module_already_exists = False

    # Extract code
    extracted_lines = []
    found_first_backticks = False
    found_second_backticks = False
    found_module = False
    found_endmodule = False

    for line in lines:
        echo_line = True

        if line.strip().startswith("module TopModule"):
            found_module = True

        if backticks_count >= 2:
            if (not found_first_backticks) or found_second_backticks:
                echo_line = False
        else:
            if found_endmodule:
                echo_line = False
            if module_already_exists and not found_module:
                echo_line = False

        if line.startswith("```"):
            if not found_first_backticks:
                found_first_backticks = True
            else:
                found_second_backticks = True
            echo_line = False
        elif line.strip().startswith("endmodule"):
            found_endmodule = True

        if echo_line:
            extracted_lines.append(line)

    extracted_code = "\n".join(extracted_lines)

    # Build complete code with interface if needed
    if not module_already_exists:
        complete_code = "\n" + module_interface + "\n" + extracted_code + "\n"
    else:
        complete_code = "\n" + extracted_code + "\n"

    # Add warnings if needed
    warnings = []
    if backticks_count == 1 or backticks_count > 2:
        warnings.append("// VERILOG-EVAL: abnormal backticks count")
    if found_module:
        warnings.append("// VERILOG-EVAL: errant inclusion of module definition")
    if not found_endmodule:
        warnings.append("// VERILOG-EVAL: endmodule not found")

    if warnings:
        complete_code += "\n" + "\n".join(warnings) + "\n"

    return complete_code, extracted_code

def generate_code(model: str, prompt: str, problem_name: str) -> Tuple[Optional[str], float, Optional[str]]:
    """
    Generate Verilog code using Ollama

    Returns:
        (response_text, generation_time, error_message)
    """
    try:
        start_time = time.time()

        response = ollama.generate(
            model=model,
            prompt=prompt,
            system=SYSTEM_MSG,
            options={
                'temperature': TEMPERATURE,
                'top_p': TOP_P,
                'num_predict': MAX_TOKENS,
            }
        )

        end_time = time.time()
        generation_time = end_time - start_time

        response_text = response.get('response', '')

        return response_text, generation_time, None

    except Exception as e:
        return None, 0.0, str(e)

def compile_and_test(problem_name: str, code_file: str, output_dir: str) -> Tuple[bool, bool, str]:
    """
    Compile and test Verilog code with iverilog

    Returns:
        (compilation_success, test_success, log_content)
    """
    test_file = f"{DATASET_DIR}/{problem_name}_test.sv"
    ref_file = f"{DATASET_DIR}/{problem_name}_ref.sv"
    sample_name = os.path.basename(code_file).replace('.sv', '')
    bin_file = f"{output_dir}/{sample_name}"
    log_file = f"{output_dir}/{sample_name}-sv-iv-test.log"

    log_lines = []

    # Compile
    try:
        compile_cmd = [
            'iverilog',
            '-Wall',
            '-Winfloop',
            '-Wno-timescale',
            '-g2012',
            '-s', 'tb',
            '-o', bin_file,
            code_file,
            test_file,
            ref_file
        ]

        result = subprocess.run(
            compile_cmd,
            capture_output=True,
            text=True,
            timeout=30
        )

        log_lines.append("=== Compilation ===")
        log_lines.append(f"Command: {' '.join(compile_cmd)}")
        log_lines.append(f"Return code: {result.returncode}")
        log_lines.append("\n--- stdout ---")
        log_lines.append(result.stdout)
        log_lines.append("\n--- stderr ---")
        log_lines.append(result.stderr)

        compilation_success = (result.returncode == 0)

    except subprocess.TimeoutExpired:
        log_lines.append("=== Compilation ===")
        log_lines.append("ERROR: Compilation timeout")
        compilation_success = False
    except Exception as e:
        log_lines.append("=== Compilation ===")
        log_lines.append(f"ERROR: {e}")
        compilation_success = False

    test_success = False

    # Run test if compilation succeeded
    if compilation_success and os.path.exists(bin_file):
        try:
            test_cmd = [bin_file]

            result = subprocess.run(
                test_cmd,
                capture_output=True,
                text=True,
                timeout=30
            )

            log_lines.append("\n=== Test Execution ===")
            log_lines.append(f"Command: {' '.join(test_cmd)}")
            log_lines.append(f"Return code: {result.returncode}")
            log_lines.append("\n--- stdout ---")
            log_lines.append(result.stdout)
            log_lines.append("\n--- stderr ---")
            log_lines.append(result.stderr)

            # Check for success (no mismatches)
            output = result.stdout + result.stderr
            test_success = (result.returncode == 0 and "Mismatches: 0" in output)

        except subprocess.TimeoutExpired:
            log_lines.append("\n=== Test Execution ===")
            log_lines.append("TIMEOUT")
            test_success = False
        except Exception as e:
            log_lines.append("\n=== Test Execution ===")
            log_lines.append(f"ERROR: {e}")
            test_success = False

    log_content = "\n".join(log_lines)

    # Write log file
    write_file(log_file, log_content)

    return compilation_success, test_success, log_content

def process_problem(
    model: str,
    problem_name: str,
    output_base_dir: str,
    sample_num: int = 1
) -> ProblemResult:
    """
    Process a single problem: generate, extract, test

    Returns:
        ProblemResult
    """
    problem_dir = f"{output_base_dir}/{problem_name}"
    os.makedirs(problem_dir, exist_ok=True)

    sample_name = f"{problem_name}_sample{sample_num:02d}"

    # File paths
    raw_response_file = f"{problem_dir}/{sample_name}_raw_response.txt"
    extracted_code_file = f"{problem_dir}/{sample_name}_extracted_code.txt"
    complete_code_file = f"{problem_dir}/{sample_name}.sv"
    generate_log_file = f"{problem_dir}/{sample_name}-sv-generate.log"

    # Build prompt
    full_prompt, problem_desc, module_ifc = build_prompt(problem_name)

    # Generate code
    response_text, gen_time, error_msg = generate_code(model, full_prompt, problem_name)

    # Save generation log
    log_lines = [
        "=== Generation Parameters ===",
        f"Problem: {problem_name}",
        f"Model: {model}",
        f"Temperature: {TEMPERATURE}",
        f"Top-p: {TOP_P}",
        f"Max tokens: {MAX_TOKENS}",
        f"Generation time: {gen_time:.2f}s",
        "",
        "=== System Message ===",
        SYSTEM_MSG,
        "",
        "=== Prompt ===",
        full_prompt,
        "",
    ]

    if error_msg:
        log_lines.append("=== Error ===")
        log_lines.append(error_msg)
        write_file(generate_log_file, "\n".join(log_lines))

        return ProblemResult(
            problem_name=problem_name,
            success=False,
            generation_time=gen_time,
            compilation_success=False,
            test_success=False,
            error_message=error_msg
        )

    log_lines.append("=== Response ===")
    log_lines.append(response_text)

    write_file(generate_log_file, "\n".join(log_lines))

    # Save raw response
    write_file(raw_response_file, response_text)

    # Extract code
    complete_code, extracted_code = extract_verilog_code(response_text, module_ifc)

    # Save extracted code
    write_file(extracted_code_file, extracted_code)
    write_file(complete_code_file, complete_code)

    # Compile and test
    comp_success, test_success, test_log = compile_and_test(
        problem_name,
        complete_code_file,
        problem_dir
    )

    return ProblemResult(
        problem_name=problem_name,
        success=True,
        generation_time=gen_time,
        compilation_success=comp_success,
        test_success=test_success,
        error_message=None
    )

def load_progress(progress_file: str) -> set:
    """Load completed problems from progress file"""
    if os.path.exists(progress_file):
        try:
            with open(progress_file, 'r') as f:
                data = json.load(f)
                return set(data.get('completed', []))
        except:
            pass
    return set()

def save_progress(progress_file: str, completed: set):
    """Save progress to file"""
    try:
        with open(progress_file, 'w') as f:
            json.dump({'completed': sorted(list(completed))}, f, indent=2)
    except Exception as e:
        print(f"Warning: Could not save progress: {e}")

def generate_summary(results: List[ProblemResult], output_file: str):
    """Generate summary report"""
    total = len(results)
    generated = sum(1 for r in results if r.success)
    compiled = sum(1 for r in results if r.compilation_success)
    passed = sum(1 for r in results if r.test_success)

    pass_rate = (passed / total * 100) if total > 0 else 0
    compile_rate = (compiled / total * 100) if total > 0 else 0

    avg_time = sum(r.generation_time for r in results) / total if total > 0 else 0

    summary_lines = [
        "=" * 70,
        "VerilogEval Test Summary",
        "=" * 70,
        "",
        f"Total problems: {total}",
        f"Successfully generated: {generated} ({generated/total*100:.1f}%)",
        f"Compilation success: {compiled} ({compile_rate:.1f}%)",
        f"Test passed: {passed} ({pass_rate:.1f}%)",
        "",
        f"Pass@1 Rate: {pass_rate:.2f}%",
        f"Average generation time: {avg_time:.2f}s",
        "",
        "=" * 70,
        "Detailed Results",
        "=" * 70,
        "",
    ]

    # Add per-problem results
    for result in results:
        status = "PASS" if result.test_success else "FAIL"
        comp_status = "OK" if result.compilation_success else "FAIL"
        gen_status = "OK" if result.success else "ERROR"

        line = f"{result.problem_name:<30} Gen:{gen_status:<6} Comp:{comp_status:<6} Test:{status:<6} ({result.generation_time:.1f}s)"

        if result.error_message:
            line += f" Error: {result.error_message[:50]}"

        summary_lines.append(line)

    summary_text = "\n".join(summary_lines)

    # Write to file
    write_file(output_file, summary_text)

    # Also print to console
    print("\n" + summary_text)

def generate_csv_summary(results: List[ProblemResult], output_file: str):
    """Generate CSV summary compatible with VerilogEval format"""
    lines = ["problem,num_samples,pass,compile_status,test_status"]

    for result in results:
        pass_val = "." if result.test_success else "F"
        compile_val = "." if result.compilation_success else "C"
        test_val = "." if result.test_success else "R"

        lines.append(f"{result.problem_name},1,{pass_val},{compile_val},{test_val}")

    write_file(output_file, "\n".join(lines))

# ============================================================================
# Main Function
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Run VerilogEval tests on Ollama models"
    )
    parser.add_argument(
        '--model',
        type=str,
        required=True,
        help='Ollama model name (e.g., gemma3:12b)'
    )
    parser.add_argument(
        '--limit',
        type=int,
        default=None,
        help='Limit number of problems to test (for quick validation)'
    )
    parser.add_argument(
        '--start',
        type=int,
        default=0,
        help='Start from problem N (0-indexed)'
    )
    parser.add_argument(
        '--output-dir',
        type=str,
        default=None,
        help='Output directory (default: results/<model>_0shot_temp0.0)'
    )
    parser.add_argument(
        '--resume',
        action='store_true',
        help='Resume from previous run (skip completed problems)'
    )

    args = parser.parse_args()

    # Setup output directory
    if args.output_dir:
        output_dir = args.output_dir
    else:
        model_name_safe = args.model.replace(':', '_').replace('/', '_')
        output_dir = f"results/{model_name_safe}_0shot_temp0.0"

    os.makedirs(output_dir, exist_ok=True)

    print(f"\n{'='*70}")
    print(f"VerilogEval Ollama Testing")
    print(f"{'='*70}\n")
    print(f"Model: {args.model}")
    print(f"Output directory: {output_dir}")
    print(f"Temperature: {TEMPERATURE}, Top-p: {TOP_P}")
    print()

    # Get problem list
    all_problems = get_problem_list()
    print(f"Total problems in dataset: {len(all_problems)}")

    # Apply start/limit
    problems = all_problems[args.start:]
    if args.limit:
        problems = problems[:args.limit]

    print(f"Testing {len(problems)} problems (start: {args.start})")
    print()

    # Load progress if resuming
    progress_file = f"{output_dir}/progress.json"
    completed = load_progress(progress_file) if args.resume else set()

    if args.resume and completed:
        print(f"Resuming: {len(completed)} problems already completed")
        problems = [p for p in problems if p not in completed]
        print(f"Remaining: {len(problems)} problems")
        print()

    # Process all problems
    results = []

    for problem in tqdm(problems, desc="Testing problems", unit="problem"):
        result = process_problem(args.model, problem, output_dir)
        results.append(result)

        # Update progress
        completed.add(problem)
        save_progress(progress_file, completed)

    # Generate summaries
    summary_file = f"{output_dir}/summary.txt"
    csv_file = f"{output_dir}/summary.csv"

    generate_summary(results, summary_file)
    generate_csv_summary(results, csv_file)

    # Save detailed results
    results_json_file = f"{output_dir}/results.json"
    with open(results_json_file, 'w') as f:
        json.dump({
            'model': args.model,
            'temperature': TEMPERATURE,
            'top_p': TOP_P,
            'total_problems': len(results),
            'results': [asdict(r) for r in results]
        }, f, indent=2)

    print(f"\nResults saved to: {output_dir}")
    print(f"  - Summary: {summary_file}")
    print(f"  - CSV: {csv_file}")
    print(f"  - Detailed: {results_json_file}")

if __name__ == "__main__":
    main()
