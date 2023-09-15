import fire
import sys

from verilog_eval.evaluation import evaluate_functional_correctness


def entry_point(
    sample_file: str,
    problem_file: str,
    k: str = "1,5,10",
    n_workers: int = 32,
    timeout: float = 30.0,
    unit_test: bool = False,
    clean_up: bool = True,
):
    """
    Evaluates the functional correctness of generated samples, and writes
    results to f"{sample_file}_results.jsonl.gz"
    """
    if type(k) == tuple:
        k = list(k)
    else:
        k = list(map(int, k.split(",")))
    results = evaluate_functional_correctness(sample_file, problem_file, k, n_workers, timeout, unit_test, clean_up)
    print(results)


def main():
    fire.Fire(entry_point)


sys.exit(main())
