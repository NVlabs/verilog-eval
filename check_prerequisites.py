#!/usr/bin/env python3
"""
VerilogEval Ollama Testing - Prerequisites Checker

This script checks all dependencies required for running VerilogEval tests with Ollama models.
Checks include:
- Python version
- Ollama service availability
- Ollama Python SDK
- iverilog installation and version
- Required Python packages

Usage:
    python check_prerequisites.py

SPDX-FileCopyrightText: Copyright (c) 2024
SPDX-License-Identifier: MIT
"""

import sys
import subprocess
import importlib.util
import os
from typing import Tuple, List, Optional

# Color codes for terminal output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

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

def check_python_version() -> bool:
    """Check if Python version is compatible (3.8+)"""
    print_header("Checking Python Version")

    version = sys.version_info
    version_str = f"{version.major}.{version.minor}.{version.micro}"

    print_info(f"Current Python version: {version_str}")

    if version.major == 3 and version.minor >= 8:
        print_success(f"Python {version_str} is compatible (requires Python 3.8+)")
        return True
    else:
        print_error(f"Python {version_str} is not compatible (requires Python 3.8+)")
        return False

def check_ollama_service() -> bool:
    """Check if Ollama service is running"""
    print_header("Checking Ollama Service")

    try:
        import requests
        response = requests.get("http://localhost:11434/api/tags", timeout=5)
        if response.status_code == 200:
            print_success("Ollama service is running on http://localhost:11434")

            # List available models
            data = response.json()
            if 'models' in data and len(data['models']) > 0:
                print_info(f"Found {len(data['models'])} model(s) available:")
                for model in data['models'][:5]:  # Show first 5
                    model_name = model.get('name', 'unknown')
                    model_size = model.get('size', 0) / (1024**3)  # Convert to GB
                    print_info(f"  - {model_name} ({model_size:.1f} GB)")
                if len(data['models']) > 5:
                    print_info(f"  ... and {len(data['models']) - 5} more")
            return True
        else:
            print_error(f"Ollama service returned status code: {response.status_code}")
            return False
    except ImportError:
        print_error("requests module not installed (needed for Ollama service check)")
        print_info("Install with: pip install requests")
        return False
    except Exception as e:
        print_error(f"Ollama service is not accessible: {e}")
        print_info("Please ensure Ollama is installed and running:")
        print_info("  1. Install Ollama from: https://ollama.ai")
        print_info("  2. Start Ollama service: ollama serve")
        return False

def check_python_package(package_name: str, import_name: Optional[str] = None) -> bool:
    """Check if a Python package is installed"""
    if import_name is None:
        import_name = package_name

    spec = importlib.util.find_spec(import_name)
    if spec is not None:
        try:
            module = importlib.import_module(import_name)
            version = getattr(module, '__version__', 'unknown')
            print_success(f"{package_name} is installed (version: {version})")
            return True
        except Exception as e:
            print_warning(f"{package_name} found but couldn't import: {e}")
            return False
    else:
        print_error(f"{package_name} is not installed")
        return False

def check_python_packages() -> Tuple[bool, List[str]]:
    """Check all required Python packages"""
    print_header("Checking Python Packages")

    required_packages = [
        ('ollama', 'ollama'),
        ('tqdm', 'tqdm'),
        ('requests', 'requests'),
    ]

    missing_packages = []
    all_installed = True

    for package_name, import_name in required_packages:
        if not check_python_package(package_name, import_name):
            missing_packages.append(package_name)
            all_installed = False

    if not all_installed:
        print_info("\nTo install missing packages, run:")
        print_info(f"  pip install {' '.join(missing_packages)}")

    return all_installed, missing_packages

def check_iverilog() -> bool:
    """Check if iverilog is installed and check version"""
    print_header("Checking Icarus Verilog (iverilog)")

    try:
        result = subprocess.run(
            ['iverilog', '-V'],
            capture_output=True,
            text=True,
            timeout=5
        )

        output = result.stdout + result.stderr

        # Parse version
        version_line = output.split('\n')[0] if output else ''
        print_info(f"Found: {version_line}")

        # Check if it's version 12
        if 'version 12' in output.lower() or 'v12' in output.lower():
            print_success("iverilog version 12 is installed (required)")
            return True
        elif 'version 13' in output.lower() or 'v13' in output.lower():
            print_warning("iverilog version 13 detected (development release)")
            print_info("VerilogEval officially supports iverilog v12")
            print_info("Version 13 may work but is not officially supported")
            return True
        else:
            print_warning("iverilog version could not be determined or may not be v12")
            print_info("VerilogEval requires iverilog v12")
            return True  # Don't fail, just warn

    except FileNotFoundError:
        print_error("iverilog is not installed")
        print_info("Install instructions:")
        print_info("  git clone https://github.com/steveicarus/iverilog.git")
        print_info("  cd iverilog && git checkout v12-branch")
        print_info("  sh ./autoconf.sh && ./configure && make -j4 && sudo make install")
        return False
    except subprocess.TimeoutExpired:
        print_error("iverilog command timed out")
        return False
    except Exception as e:
        print_error(f"Error checking iverilog: {e}")
        return False

def check_dataset() -> bool:
    """Check if dataset directory exists"""
    print_header("Checking VerilogEval Dataset")

    dataset_dir = "dataset_code-complete-iccad2023"

    if not os.path.exists(dataset_dir):
        print_error(f"Dataset directory not found: {dataset_dir}")
        print_info("Please ensure you're running this script from the verilog-eval-4LLM root directory")
        return False

    # Count problem files
    prompt_files = []
    try:
        import glob
        prompt_files = glob.glob(f"{dataset_dir}/*_prompt.txt")

        if len(prompt_files) > 0:
            print_success(f"Dataset directory found with {len(prompt_files)} problems")
            return True
        else:
            print_error(f"Dataset directory exists but no problem files found")
            return False
    except Exception as e:
        print_error(f"Error checking dataset: {e}")
        return False

def check_disk_space() -> bool:
    """Check available disk space"""
    print_header("Checking Disk Space")

    try:
        import shutil
        total, used, free = shutil.disk_usage("/")

        free_gb = free / (1024**3)

        print_info(f"Free disk space: {free_gb:.1f} GB")

        if free_gb < 5:
            print_warning(f"Low disk space: {free_gb:.1f} GB free")
            print_info("Recommend at least 5 GB free for storing results")
            return True  # Don't fail, just warn
        else:
            print_success(f"Sufficient disk space available: {free_gb:.1f} GB")
            return True

    except Exception as e:
        print_warning(f"Could not check disk space: {e}")
        return True  # Don't fail

def main():
    """Main function to run all checks"""
    print(f"\n{Colors.BOLD}VerilogEval Ollama Testing - Prerequisites Checker{Colors.RESET}")
    print(f"{'='*70}\n")

    checks = []

    # Run all checks
    checks.append(("Python Version", check_python_version()))
    checks.append(("Ollama Service", check_ollama_service()))
    packages_ok, missing = check_python_packages()
    checks.append(("Python Packages", packages_ok))
    checks.append(("iverilog", check_iverilog()))
    checks.append(("Dataset", check_dataset()))
    checks.append(("Disk Space", check_disk_space()))

    # Summary
    print_header("Prerequisites Check Summary")

    all_passed = True
    for check_name, result in checks:
        if result:
            print_success(f"{check_name}: PASSED")
        else:
            print_error(f"{check_name}: FAILED")
            all_passed = False

    print()

    if all_passed:
        print_success(f"{Colors.BOLD}All prerequisites are satisfied!{Colors.RESET}")
        print_info("You can now run the VerilogEval tests with Ollama models.")
        print_info("\nNext steps:")
        print_info("  1. Check model availability: python check_models.py")
        print_info("  2. Run single model test: python run_verilog_eval.py --model <model_name>")
        print_info("  3. Run all models: python run_all_models.py")
        return 0
    else:
        print_error(f"{Colors.BOLD}Some prerequisites are not satisfied.{Colors.RESET}")
        print_info("Please address the failed checks above before proceeding.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
