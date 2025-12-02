#!/bin/bash
#
# VerilogEval Ollama Testing - Example Workflow
#
# This script demonstrates a complete testing workflow.
# Modify as needed for your specific use case.

set -e  # Exit on error

echo "========================================================================"
echo "VerilogEval Ollama Testing - Example Workflow"
echo "========================================================================"
echo ""

# Step 1: Check prerequisites
echo "Step 1: Checking prerequisites..."
python check_prerequisites.py

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Prerequisites check failed!"
    echo "Please fix the issues above before continuing."
    exit 1
fi

echo ""
echo "Prerequisites check passed!"
echo ""

# Step 2: Check model availability
echo "Step 2: Checking model availability..."
python check_models.py

echo ""

# Step 3: Quick test with one model (first 10 problems)
echo "Step 3: Running quick test with mistral:7b (10 problems)..."
python run_verilog_eval.py --model mistral:7b --limit 10

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Quick test failed!"
    echo "Please check the errors above."
    exit 1
fi

echo ""
echo "Quick test completed successfully!"
echo ""

# Step 4: Ask user if they want to continue with full tests
echo "========================================================================"
echo "Quick test completed successfully!"
echo "========================================================================"
echo ""
echo "Next steps:"
echo "  1. Test a single model (all 156 problems):"
echo "     python run_verilog_eval.py --model mistral:7b"
echo ""
echo "  2. Test all models:"
echo "     python run_all_models.py"
echo ""
echo "  3. View results:"
echo "     cat results/mistral_7b_0shot_temp0.0/summary.txt"
echo ""
