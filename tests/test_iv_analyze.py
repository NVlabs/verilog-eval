"""Regression tests at the analyzer's command-line entry point."""
import csv
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "sv-iv-analyze"
OK = "Mismatches: 0 in 20 samples"
BAD = "Mismatches: 1 in 20 samples"
SOURCE = "module TopModule(output one); assign one = 1'b1; endmodule\n"


class AnalyzerTests(unittest.TestCase):
    def check_grade(self, records, expected, source=SOURCE, strict=False):
        with tempfile.TemporaryDirectory() as work:
            directory = Path(work, "Prob001")
            directory.mkdir()
            sample = directory / "Prob001_sample01"
            Path(str(sample) + "-sv-generate.log").write_text("")
            Path(str(sample) + "-sv-iv-test.log").write_text("\n".join(records) + "\n")
            sample.with_suffix(".sv").write_text(source)
            args = [sys.executable, SCRIPT, "--csv=results.csv"]
            if strict:
                args.append("--strict-source")
            subprocess.run(args, cwd=work,
                           check=True, capture_output=True)
            with Path(work, "results.csv").open() as f:
                self.assertEqual(next(csv.reader(f))[-1], expected)

    def test_summary_records(self):
        for records, expected in [
            ([OK], "."), ([BAD], "R"), ([], "R"),
            (["Mismatches: 0 in 0 samples"], "R"),
            ([OK, BAD], "R"), ([BAD, OK], "R"), ([OK, OK], "R"),
            (["Mismatches: incomplete", OK], "R"),
            ([OK, "Mismatches: incomplete"], "R"), ([OK, "TIMEOUT"], "T"),
        ]:
            with self.subTest(records=records):
                self.check_grade(records, expected)

    def test_inert_source_text(self):
        declarations = [
            "// $display is for bench diagnostics only\n",
            "/* $finish belongs in the bench */",
            'localparam NOTE = "use $display in the bench";',
            "wire status$monitor;",
            r"wire \$monitor ;",
        ]
        for declaration in declarations:
            with self.subTest(declaration=declaration):
                self.check_grade([OK], ".", SOURCE.replace("endmodule", declaration + "\nendmodule"), strict=True)

    def test_direct_diagnostic_has_a_distinct_policy_result(self):
        source = SOURCE.replace("endmodule", 'initial $display("diagnostic"); endmodule')
        self.check_grade([OK], ".", source)
        self.check_grade([OK], "D", source, strict=True)


if __name__ == "__main__":
    unittest.main()
