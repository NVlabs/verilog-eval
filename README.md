# VerilogEval Overview

This is an evaluation harness for the VerilogEval problem solving dataset originally described in the paper "[VerilogEval: Evaluating Large Language Models for Verilog Code Generation](https://arxiv.org/abs/2309.07544)," published in 2023. In August 2024, this repository was revised to cover specification-to-RTL tasks in addition to the original code completion task, add in-context learning examples to prompts, and categorize common iverilog failures.

**If you would like to benchmark against the original VerilogEval 1.0 harness, please checkout Git branch "release/1.0.0" which has been kept to preserve this original benchmark. Otherwise, the main branch can be used for the improved harness.**

### VerilogEvalV2 with Reframed Prompts and New Scripts

This repo contains the original VerilogEval dataset with reframed prompts
and new scripts. The original VerilogEval prompts explicitly included the
Verilog module interface, while in this version we specify the module
interface more abstractly. The new scripts manage the dataset as plain
text files (instead of a large JSONL file), include generation and
analysis scripts, and include a Makefile to drive the workflow. The
generation script includes support for easily changing the LLM model,
including/excluding in-context learning rules and in-context learning
examples. The analysis script includes support for categorizing common
iverilog errors and outputing the results in both plain text and CSV
files.

MachineEval is not supported in VerilogEvalV2, only the Human Eval problem statements. Pass@10 is no longer being reported either, instead Pass@1 with number of samples n=1 (temperature=0, top_p=0.01) and n=20 (temperature=0.85, top_p=0.95) for low and high and temperature results, respectively.

### Setup Linux Environment

In order to use PyHDL-Eval you will need to install iverilog, verilator,
and python3 along with several Python packages. These are the versions
which were used for this project:

 - iverilog (v12)
 - python3 (v3.11.0)

You will also need the following Python packages:

```
 % pip install langchain langchain-openai langchain-nvidia-ai-endpoints
```

### Usage 

The evalution harness is run using make and various evaluation parameters can be set as below:

```
mkdir -p build/
../configure  --with-task=$task --with-model=$model --with-examples=$shots --with-samples=$samples --with-temperature=$temperature --with-top-p=$top_p
make
```

Available tasks are `code-complete-iccad2023` and `spec-to-rtl` with each referencing their corresponding `dataset_$task` directory containig the problems. Problem themselves are identical between the two datasets and only the task format changes.

Valid models are listed at the top of `scripts/sv-generate`. The number of in-context learning examples can be between 0-4, and given with `--with-examples`. Samples to collect per problem are given by `--with-samples`. Finally, model temperature and top_p can be set to --with-temperature and --with-top-p, respectively.

These parameters can be easily swept with a shell script, to create separate build directories for each evaluation harness configuration target. 

## Citation

The arXiv paper is forthcoming and we will provide a citation for VerilogEvalv2 shortly.

For VerilogEval v1 please use:

```
@inproceedings{liu2023verilogeval,
  title={{VerilogEval:} Evaluating Large Language Models for Verilog Code Generation},
  author={Liu, Mingjie and Pinckney, Nathaniel and Khailany, Brucek and Ren, Haoxing},
  booktitle={2023 IEEE/ACM International Conference on Computer-Aided Design (ICCAD)}, 
  year={2023}
}
```
