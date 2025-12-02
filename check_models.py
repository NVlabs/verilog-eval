#!/usr/bin/env python3
"""
VerilogEval Ollama Testing - Model Availability Checker

This script checks the availability and basic functionality of Ollama models
for VerilogEval testing.

Checks include:
- Model availability in Ollama
- Basic code generation capability
- Memory usage estimation
- Response time measurement

Usage:
    python check_models.py

SPDX-FileCopyrightText: Copyright (c) 2024
SPDX-License-Identifier: MIT
"""

import sys
import time
import json
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, asdict

try:
    import ollama
except ImportError:
    print("ERROR: ollama package not installed")
    print("Install with: pip install ollama")
    sys.exit(1)

# Color codes for terminal output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

@dataclass
class ModelTestResult:
    """Results from testing a single model"""
    model_name: str
    available: bool
    error_message: Optional[str] = None
    response_time: Optional[float] = None
    generated_code: Optional[str] = None
    memory_size_gb: Optional[float] = None
    test_passed: bool = False

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

def print_warning(text: str):
    """Print warning message"""
    print(f"{Colors.YELLOW}⚠ {text}{Colors.RESET}")

def print_info(text: str):
    """Print info message"""
    print(f"  {text}")

# Models to test with their expected sizes
MODELS_TO_TEST = [
    ("gemma3:12b", 8.1),
    ("gpt-oss:20b", 13.0),
    ("deepseek-r1:14b", 9.0),
    ("phi4:14b", 9.1),
    ("mistral:7b", 4.4),
    ("llama3.2:3b", 2.0),
    ("qwen3:8b", 5.2),
]

# Simple test prompt for Verilog generation
TEST_PROMPT = """Generate a simple 2-to-1 multiplexer in Verilog.

module mux2to1 (
    input wire a,
    input wire b,
    input wire sel,
    output wire out
);
"""

def check_model_exists(model_name: str) -> Tuple[bool, Optional[float]]:
    """Check if a model exists in Ollama"""
    try:
        response = ollama.list()

        for model in response.get('models', []):
            if model['name'] == model_name or model['name'].startswith(model_name + ':'):
                # Get size in GB
                size_gb = model.get('size', 0) / (1024**3)
                return True, size_gb

        return False, None

    except Exception as e:
        print_error(f"Error checking model list: {e}")
        return False, None

def test_model_generation(model_name: str) -> ModelTestResult:
    """Test a model's ability to generate Verilog code"""
    result = ModelTestResult(model_name=model_name, available=False)

    print(f"\n{Colors.BOLD}Testing: {model_name}{Colors.RESET}")
    print("-" * 70)

    # Check if model exists
    print_info("Checking model availability...")
    exists, size_gb = check_model_exists(model_name)

    if not exists:
        print_error(f"Model '{model_name}' not found in Ollama")
        print_info("Pull the model with: ollama pull " + model_name)
        result.error_message = "Model not found"
        return result

    result.available = True
    result.memory_size_gb = size_gb
    print_success(f"Model found (Size: {size_gb:.1f} GB)")

    # Test generation
    print_info("Testing code generation...")

    try:
        start_time = time.time()

        response = ollama.generate(
            model=model_name,
            prompt=TEST_PROMPT,
            options={
                'temperature': 0.0,
                'top_p': 0.01,
                'num_predict': 256,  # Shorter for quick test
            }
        )

        end_time = time.time()
        response_time = end_time - start_time

        generated_text = response.get('response', '')

        result.response_time = response_time
        result.generated_code = generated_text

        # Basic validation: check if response contains Verilog-like code
        has_assign = 'assign' in generated_text.lower()
        has_endmodule = 'endmodule' in generated_text.lower()

        if has_assign or has_endmodule:
            result.test_passed = True
            print_success(f"Generation successful ({response_time:.2f}s)")
            print_info("Generated code snippet:")
            # Show first 3 lines
            lines = generated_text.strip().split('\n')[:3]
            for line in lines:
                print_info(f"  {line}")
            if len(generated_text.strip().split('\n')) > 3:
                print_info("  ...")
        else:
            result.test_passed = False
            print_warning(f"Generation completed but output may not be valid Verilog")
            print_info(f"Response time: {response_time:.2f}s")

    except Exception as e:
        print_error(f"Generation failed: {e}")
        result.error_message = str(e)
        result.test_passed = False

    return result

def save_results(results: List[ModelTestResult], filename: str = "model_check_results.json"):
    """Save test results to JSON file"""
    try:
        data = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'models': [asdict(r) for r in results]
        }

        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)

        print_info(f"Results saved to: {filename}")
    except Exception as e:
        print_warning(f"Could not save results: {e}")

def print_summary(results: List[ModelTestResult]):
    """Print summary of all model tests"""
    print_header("Model Availability Summary")

    print(f"{'Model':<20} {'Status':<12} {'Size (GB)':<12} {'Time (s)':<12} {'Test'}")
    print("-" * 70)

    for result in results:
        status = f"{Colors.GREEN}Available{Colors.RESET}" if result.available else f"{Colors.RED}Not Found{Colors.RESET}"

        size_str = f"{result.memory_size_gb:.1f}" if result.memory_size_gb else "N/A"

        time_str = f"{result.response_time:.2f}" if result.response_time else "N/A"

        if result.test_passed:
            test_str = f"{Colors.GREEN}PASS{Colors.RESET}"
        elif result.available and not result.test_passed:
            test_str = f"{Colors.RED}FAIL{Colors.RESET}"
        else:
            test_str = f"{Colors.YELLOW}SKIP{Colors.RESET}"

        print(f"{result.model_name:<20} {status:<20} {size_str:<12} {time_str:<12} {test_str}")

    print()

    # Count statistics
    total = len(results)
    available = sum(1 for r in results if r.available)
    passed = sum(1 for r in results if r.test_passed)

    print_info(f"Total models: {total}")
    print_info(f"Available: {available}/{total}")
    print_info(f"Passed generation test: {passed}/{total}")

    if passed > 0:
        print()
        print_success(f"{passed} model(s) ready for VerilogEval testing!")

        print_info("\nRecommended models to test (in order of size):")
        passed_models = sorted(
            [r for r in results if r.test_passed],
            key=lambda r: r.memory_size_gb or 0
        )

        for result in passed_models:
            print_info(f"  - {result.model_name} ({result.memory_size_gb:.1f} GB, ~{result.response_time:.1f}s per query)")

    # Models that need to be pulled
    not_found = [r for r in results if not r.available]
    if not_found:
        print()
        print_warning(f"{len(not_found)} model(s) need to be pulled:")
        for result in not_found:
            print_info(f"  ollama pull {result.model_name}")

def main():
    """Main function"""
    print(f"\n{Colors.BOLD}VerilogEval Ollama Testing - Model Availability Checker{Colors.RESET}")
    print(f"{'='*70}\n")

    print_info(f"Testing {len(MODELS_TO_TEST)} models...")
    print_info("This will load each model and test basic code generation.")
    print_info("Note: First-time model loading may take longer.\n")

    results = []

    for model_name, expected_size in MODELS_TO_TEST:
        try:
            result = test_model_generation(model_name)
            results.append(result)

            # Stop the model to free memory for next test
            try:
                # Note: ollama.stop() might not be available in all versions
                # We'll just let Ollama manage memory automatically
                pass
            except:
                pass

        except KeyboardInterrupt:
            print_warning("\nTest interrupted by user")
            break
        except Exception as e:
            print_error(f"Unexpected error testing {model_name}: {e}")
            result = ModelTestResult(
                model_name=model_name,
                available=False,
                error_message=str(e)
            )
            results.append(result)

    # Print summary
    print_summary(results)

    # Save results
    save_results(results)

    # Exit code
    passed_count = sum(1 for r in results if r.test_passed)
    if passed_count > 0:
        return 0
    else:
        return 1

if __name__ == "__main__":
    sys.exit(main())
