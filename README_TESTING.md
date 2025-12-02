# VerilogEval Ollama Testing Guide

This guide explains how to use the testing scripts to evaluate local Ollama models on the VerilogEval benchmark.

## Overview

These scripts enable you to:
- Test local Ollama models on VerilogEval code completion tasks
- Evaluate models with zero-shot, low-temperature settings (temp=0.0, top_p=0.01)
- Preserve all outputs (raw responses, extracted code, logs) for analysis
- Generate comprehensive evaluation reports

## System Requirements

### Hardware
- **GPU Memory**: 16GB+ recommended (depends on model size)
- **RAM**: 16GB minimum
- **Disk Space**: 5GB+ for results storage
- **Note**: Only one model can run at a time due to memory constraints

### Software
- **Python**: 3.8+ (3.11 recommended)
- **Ollama**: Latest version from [ollama.ai](https://ollama.ai)
- **iverilog**: v12 (for Verilog compilation and testing)
- **Python Packages**: ollama, tqdm, requests

## Installation

### 1. Install Ollama

Follow instructions at [ollama.ai](https://ollama.ai) to install Ollama for your platform.

Start Ollama service:
```bash
ollama serve
```

### 2. Pull Ollama Models

Pull the models you want to test:

```bash
# Smaller models (recommended for testing first)
ollama pull llama3.2:3b      # 2.0 GB
ollama pull mistral:7b       # 4.4 GB
ollama pull qwen3:8b         # 5.2 GB

# Medium models
ollama pull gemma3:12b       # 8.1 GB
ollama pull deepseek-r1:14b  # 9.0 GB
ollama pull phi4:14b         # 9.1 GB

# Large model
ollama pull gpt-oss:20b      # 13 GB
```

**Note**: With 16GB VRAM, you should be able to run models up to ~13GB. Test smaller models first.

### 3. Install iverilog v12

VerilogEval requires iverilog version 12:

```bash
git clone https://github.com/steveicarus/iverilog.git
cd iverilog
git checkout v12-branch
sh ./autoconf.sh
./configure
make -j4
sudo make install
```

Verify installation:
```bash
iverilog -V
# Should show: Icarus Verilog version 12.x
```

### 4. Install Python Dependencies

```bash
cd verilog-eval-4LLM
pip install -r requirements.txt
```

Or install manually:
```bash
pip install ollama tqdm requests
```

## Usage

### Step 0: Check Prerequisites

Before running tests, verify all dependencies are installed:

```bash
python check_prerequisites.py
```

This checks:
- Python version
- Ollama service availability
- Python packages
- iverilog installation
- Dataset availability
- Disk space

**Fix any issues before proceeding.**

### Step 1: Check Model Availability

Test which models are available and working:

```bash
python check_models.py
```

This script:
- Checks if each model is pulled in Ollama
- Tests basic Verilog code generation
- Measures response time
- Reports which models are ready for testing

Output saved to: `model_check_results.json`

### Step 2: Test a Single Model

Test one model on all 156 problems:

```bash
python run_verilog_eval.py --model gemma3:12b
```

**Quick validation** (test first 10 problems):
```bash
python run_verilog_eval.py --model mistral:7b --limit 10
```

**Resume interrupted test**:
```bash
python run_verilog_eval.py --model qwen3:8b --resume
```

**Start from specific problem**:
```bash
python run_verilog_eval.py --model phi4:14b --start 50 --limit 50
```

**Custom output directory**:
```bash
python run_verilog_eval.py --model llama3.2:3b --output-dir my_results/llama3_test
```

### Step 3: Test All Models (Batch Mode)

Test all models sequentially:

```bash
python run_all_models.py
```

**Quick validation** (10 problems per model):
```bash
python run_all_models.py --limit 10
```

**Test specific models**:
```bash
python run_all_models.py --models mistral:7b qwen3:8b gemma3:12b
```

**Skip memory cleanup** (if having issues):
```bash
python run_all_models.py --skip-cleanup
```

## Output Structure

### Single Model Test Output

```
results/
└── gemma3_12b_0shot_temp0.0/
    ├── Prob001_zero/
    │   ├── Prob001_zero_sample01.sv                   # Complete Verilog code (with interface)
    │   ├── Prob001_zero_sample01_raw_response.txt     # Model's original output
    │   ├── Prob001_zero_sample01_extracted_code.txt   # Extracted code only
    │   ├── Prob001_zero_sample01-sv-generate.log      # Generation log (prompt + params)
    │   ├── Prob001_zero_sample01-sv-iv-test.log       # iverilog test log
    │   └── Prob001_zero_sample01                      # Compiled binary (if successful)
    ├── Prob002_m2014_q4i/
    │   └── ... (same structure)
    ├── ...
    ├── summary.txt          # Human-readable summary
    ├── summary.csv          # CSV format summary
    ├── results.json         # Detailed JSON results
    └── progress.json        # Progress tracking for resume
```

### File Contents

**`*_raw_response.txt`**: Complete, unmodified output from the model. This is exactly what the LLM generated.

**`*_extracted_code.txt`**: Code extracted from the response, with markdown/formatting removed, but without the module interface.

**`*.sv`**: Complete, ready-to-compile Verilog code (interface + extracted code).

**`*-sv-generate.log`**: Contains:
- Generation parameters (model, temperature, top_p)
- System message
- Full prompt sent to model
- Model response
- Any extraction errors

**`*-sv-iv-test.log`**: Contains:
- iverilog compilation output
- Test execution output
- Pass/fail status

### Summary Reports

**`summary.txt`**: Text format report with:
- Overall pass rate
- Compilation success rate
- Per-problem results
- Timing statistics

**`summary.csv`**: CSV format compatible with VerilogEval analysis tools

**`results.json`**: Detailed JSON with all test results

### Batch Test Output

```
results/
├── gemma3_12b_0shot_temp0.0/
├── mistral_7b_0shot_temp0.0/
├── qwen3_8b_0shot_temp0.0/
├── ...
├── all_models_comparison.txt    # Comparative text report
└── all_models_comparison.csv    # Comparative CSV report
```

## Analyzing Results

### View Summary

```bash
cat results/gemma3_12b_0shot_temp0.0/summary.txt
```

### Compare Models

```bash
cat results/all_models_comparison.txt
```

### Analyze Specific Problem

```bash
# View generated code
cat results/gemma3_12b_0shot_temp0.0/Prob001_zero/Prob001_zero_sample01.sv

# View raw model output
cat results/gemma3_12b_0shot_temp0.0/Prob001_zero/Prob001_zero_sample01_raw_response.txt

# View generation log (includes prompt)
cat results/gemma3_12b_0shot_temp0.0/Prob001_zero/Prob001_zero_sample01-sv-generate.log

# View test results
cat results/gemma3_12b_0shot_temp0.0/Prob001_zero/Prob001_zero_sample01-sv-iv-test.log
```

### Use VerilogEval Analysis Tools

You can also use the original VerilogEval analysis script:

```bash
python count_failures.py results/gemma3_12b_0shot_temp0.0 results/mistral_7b_0shot_temp0.0
```

## Test Parameters

All tests use the following fixed parameters:
- **Task**: code-complete-iccad2023
- **Shots**: 0 (zero-shot, no in-context examples)
- **Temperature**: 0.0 (deterministic)
- **Top-p**: 0.01 (very low randomness)
- **Samples**: 1 (single generation per problem)
- **Max tokens**: 1024

These parameters ensure reproducible, low-temperature evaluation.

## Troubleshooting

### Ollama service not running

```
ERROR: Ollama service is not accessible
```

**Solution**: Start Ollama service:
```bash
ollama serve
```

### Model not found

```
ERROR: Model 'gemma3:12b' not found in Ollama
```

**Solution**: Pull the model:
```bash
ollama pull gemma3:12b
```

### Out of Memory (OOM)

If a model fails to load due to insufficient VRAM:

**Solutions**:
1. Test smaller models first (llama3.2:3b, mistral:7b)
2. Close other GPU-using applications
3. Use models with smaller parameter counts
4. Consider using quantized versions (e.g., `mistral:7b-q4` if available)

### iverilog not found

```
ERROR: iverilog is not installed
```

**Solution**: Install iverilog v12 (see Installation section above)

### Permission denied errors

If you get permission errors when running scripts:

```bash
chmod +x check_prerequisites.py check_models.py run_verilog_eval.py run_all_models.py
```

### Test interrupted

If a test is interrupted, you can resume:

```bash
python run_verilog_eval.py --model gemma3:12b --resume
```

The script tracks completed problems in `progress.json` and skips them on resume.

### Slow generation

Some models may be slower than others. Typical times:
- Small models (3B-7B): 1-3 seconds per problem
- Medium models (8B-14B): 2-5 seconds per problem
- Large models (20B+): 5-10 seconds per problem

For all 156 problems:
- Small models: ~5-10 minutes
- Medium models: ~10-20 minutes
- Large models: ~20-30 minutes

## Tips for Best Results

1. **Start small**: Test with `--limit 10` first to verify everything works
2. **Test incrementally**: Run one model completely before testing all
3. **Monitor memory**: Use `nvidia-smi` or `ollama ps` to check GPU memory usage
4. **Save results**: Keep all output directories for later analysis
5. **Document findings**: Note any model-specific issues in your analysis

## Example Workflow

Complete workflow for evaluating multiple models:

```bash
# 1. Check prerequisites
python check_prerequisites.py

# 2. Check which models are available
python check_models.py

# 3. Quick test on one model (first 10 problems)
python run_verilog_eval.py --model mistral:7b --limit 10

# 4. If successful, run full test on that model
python run_verilog_eval.py --model mistral:7b

# 5. Test other individual models
python run_verilog_eval.py --model qwen3:8b
python run_verilog_eval.py --model gemma3:12b

# 6. Or run all models in batch
python run_all_models.py

# 7. Compare results
cat results/all_models_comparison.txt
```

## Citation

If you use these scripts in your research, please cite the VerilogEval papers:

```bibtex
@misc{pinckney2024revisitingverilogevalnewerllms,
  title={Revisiting VerilogEval: Newer LLMs, In-Context Learning, and Specification-to-RTL Tasks},
  author={Nathaniel Pinckney and Christopher Batten and Mingjie Liu and Haoxing Ren and Brucek Khailany},
  year={2024},
  eprint={2408.11053},
  archivePrefix={arXiv},
}

@inproceedings{liu2023verilogeval,
  title={{VerilogEval:} Evaluating Large Language Models for Verilog Code Generation},
  author={Liu, Mingjie and Pinckney, Nathaniel and Khailany, Brucek and Ren, Haoxing},
  booktitle={2023 IEEE/ACM International Conference on Computer-Aided Design (ICCAD)},
  year={2023}
}
```

## Support

For issues or questions:
1. Check this README
2. Review the VerilogEval main README.md
3. Check Ollama documentation at [ollama.ai](https://ollama.ai)
4. Open an issue on the GitHub repository

## License

These testing scripts are provided under the MIT License, consistent with the VerilogEval repository.
