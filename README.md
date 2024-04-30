# VerilogEval: Evaluating Large Language Models for Verilog Code Generation 

This is an evaluation harness for the VerilogEval problem solving dataset
described in the paper "[VerilogEval: Evaluating Large
Language Models for Verilog Code Generation](https://arxiv.org/abs/2309.07544)".

This evaluation dataset consists of 156 problems from the Verilog 
instructional website [HDLBits](https://hdlbits.01xz.net/wiki/Problem_sets).
We provide two sets of problem descriptions: machine generated and manually
converted to text-only format.

## Installation

We closely follow guidance from [HumanEval](https://github.com/openai/human-eval/tree/master).

Make sure to use Python 3.7 or later:
```bash
$ conda create -n codex python=3.7
$ conda activate codex
```

Install [ICARUS Verilog](https://github.com/steveicarus/iverilog):
```bash
$ git clone https://github.com/steveicarus/iverilog.git && cd iverilog \
        && git checkout 01441687235135d1c12eeef920f75d97995da333 \
        && sh ./autoconf.sh && ./configure && make -j4\
        && make install
```

It is recommended to use the provided [Dockerfile](https://github.com/NVlabs/verilog-eval/blob/main/Dockerfile) 
which already pre-installed ICARUS Verilog Simulator. Using the docker container
you would still need to complete the following step.

Check out and install this repository:
```bash
$ git clone https://github.com/NVlabs/verilog-eval
$ pip install -e verilog-eval
```

## Usage

**This program would make system calls to `iverilog` and `vvp` to simulate 
untrusted model-generated code. Users are strongly
encouraged not to do so outside of a robust security sandbox. The [execution
call](https://github.com/NVlabs/verilog-eval/blob/main/verilog_eval/execution.py#L79-L112)
in `execution.py` is deliberately commented out to ensure users read this
disclaimer before running code in a potentially unsafe manner. See the comment in
`execution.py` for more information and instructions.**

After following the above instructions to enable execution, generate samples
and save them in the following JSON Lines (jsonl) format, where each sample is
formatted into a single line like so:
```json
{"task_id": "Corresponding VerilogEval task ID", "completion": "Completion only without the prompt"}
```
We provide examples under `data/example` to illustrate the format and help with debugging.

To evaluate the samples, run
```bash
$ evaluate_functional_correctness samples.jsonl --problem_file data/VerilogEval_Human.jsonl
```
```
Reading samples...
3120it [00:00, 16077.44it/s]
Running test suites...
100%|...| 3120/3120 [00:32<00:00, 97.47it/s]
Killing all hanging simulation process.
Writing results to samples.jsonl_results.jsonl...
100%|...| 3120/3120 [00:00<00:00, 30608.13it/s]
{'pass@1': ..., 'pass@5': ..., 'pass@10': ...}
```

The user must specify `--problem_file` input argument. We provide two sets of problem
evaluations `data/VerilogEval_Machine.jsonl` and `data/VerilogEval_Human.jsonl`. 
We also provide problem description files used to sample Verilog code completions 
in `descriptions` directory.

This script provides more fine-grained information in a new file ending in
`<input_path>_results.jsonl`. Each row now contains whether the completion
`passed` along with the execution `result` which is one of "passed", "timed
out", or "failed".

As a quick sanity-check, the example samples should yield 0.5 pass@1. The results can be
verified against the provided output 
in `data/example/ExampleSolution.jsonl_reference.jsonl`.
```bash
$ evaluate_functional_correctness data/example/ExampleSolution.jsonl --problem_file=data/example/ExampleEval.jsonl
```
```
Reading samples...
6it [00:00, 221.60it/s]
Running example suites...
100%|...| 6/6 [00:00<00:00, 142.09it/s]
Killing all hanging simulation process.
Writing results to data/example/ExampleSolution.jsonl_results.jsonl...
100%|...| 6/6 [00:00<00:00, 19941.22it/s]
{'pass@1': 0.5}
```

Because there is no unbiased way of estimating pass@k when there are fewer
samples than k, the script does not evaluate pass@k for these cases. To
evaluate with other k values, pass `--k=<comma-separated-values-here>`. For
other options, see
```bash
$ evaluate_functional_correctness --help
```
However, we recommend that you use the default values for the rest.

## Issues
Problem descriptions in `descriptions/VerilogDescription_Machine.jsonl` are machine 
generated and we can not guarantee the absence of ambiguity and errors. We do not plan
to maintain description correctness.

Functional correctness are evaluated through comparing simulation outputs using 
[ICARUS Verilog](https://github.com/steveicarus/iverilog). The evaluation of Verilog syntax is limited by the simulator, which might not include all features of Verilog HDL 
IEEE-1364 standard.


## Citation

Please cite using the following bibtex entry:

```
@inproceedings{liu2023verilogeval,
  title={{VerilogEval:} Evaluating Large Language Models for Verilog Code Generation},
  author={Liu, Mingjie and Pinckney, Nathaniel and Khailany, Brucek and Ren, Haoxing},
  booktitle={2023 IEEE/ACM International Conference on Computer-Aided Design (ICCAD)}, 
  year={2023}
}
```
