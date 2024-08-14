#!/usr/bin/env python
#=========================================================================
# sv-iv-analyze [options] problems
#=========================================================================
#
#  -v --verbose        Display the prompt
#  -h --help           Display this message
#  -w --wide           Display wide view
#  -c --csv            Write CSV file
#     problemdirs      List of problems to analyze
#
# Analyze the results from testing problems with iverilog. If no
# problemdirs are given then just searches for all directories in the
# current directory that start with Prob.
#
# SPDX-FileCopyrightText: Copyright (c) 2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: MIT
# Author : Christopher Batten, NVIDIA and Nathaniel Pinckney, NVIDIA
#

import argparse
import sys
import os
import re
import glob

from collections import OrderedDict
from dataclasses import dataclass

from langchain.schema   import SystemMessage, HumanMessage

#-------------------------------------------------------------------------
# Command line processing
#-------------------------------------------------------------------------

class ArgumentParserWithCustomError(argparse.ArgumentParser):
  def error( self, msg = "" ):
    if ( msg ): print("\n ERROR: %s" % msg)
    print("")
    file = open( sys.argv[0] )
    for ( lineno, line ) in enumerate( file ):
      if ( line[0] != '#' ): sys.exit(msg != "")
      if ( (lineno == 2) or (lineno >= 4) ): print( line[1:].rstrip("\n") )

def parse_cmdline():
  p = ArgumentParserWithCustomError( add_help=False )

  p.add_argument( "-h", "--help",     action="store_true" )
  p.add_argument( "-v", "--verbose",  action="store_true" )
  p.add_argument( "-w", "--wide",     action="store_true" )
  p.add_argument( "-c", "--csv",      type=str )
  p.add_argument( "problems", type=str, nargs="*" )

  opts = p.parse_args()
  if opts.help: p.error()
  return opts

#-------------------------------------------------------------------------
# Results
#-------------------------------------------------------------------------

@dataclass
class ResultRecord:
  passfail      : str    = '?'
  num_mismatch  : int    = 0
  prompt_tokens : int    = 0
  resp_tokens   : int    = 0
  cost          : float  = 0.0

class Results:

  def __init__( self, wide ):
    self.data = OrderedDict()
    self.wide = wide

  def add_result( self, problem, sample, record ):
    sample = int(sample)
    if problem not in self.data:
      self.data[problem] = [ResultRecord()]*(sample)
    while sample > len(self.data[problem]):
      self.data[problem].append(ResultRecord())
    self.data[problem][sample-1] = record

  def print( self ):

    problem_str_width = 0
    for problem in self.data:
      if len(problem) > problem_str_width:
        problem_str_width = len(problem)

    pass_rate_sum       = 0.0
    total_queries       = 0
    total_prompt_tokens = 0
    total_resp_tokens   = 0
    total_tokens        = 0
    total_cost          = 0.0
    total_gsidx         = 0.0

    row_strs = []
    for problem,row in self.data.items():

      outcome_counts = {}
      npass = 0

      ntokens = 0
      row_str = ""
      for idx,record in enumerate(row):

        total_queries       += 1
        total_prompt_tokens += record.prompt_tokens
        total_resp_tokens   += record.resp_tokens
        total_cost          += record.cost

        ntokens += record.prompt_tokens
        ntokens += record.resp_tokens

        if record.passfail == ".":
          npass += 1

        if idx != 0 and idx % 5 == 0:
          row_str += " "

        row_str += record.passfail

        # Keep track of outcomes for calculating the Gini-Simpson index,
        # if it is a runtime error we use the number of mismatches as the
        # outcome so we can better distinguish between different kinds of
        # runtime errors

        if record.passfail == "R":
          outcome = record.num_mismatch
        else:
          outcome = record.passfail

        if outcome in outcome_counts:
          outcome_counts[outcome] += 1
        else:
          outcome_counts[outcome] = 1

      nsamples      = len(row)
      pass_rate     = int((npass/nsamples)*100)
      pass_rate_sum += pass_rate

      # Calculate the Gini-Simpson Index
      # https://en.wikipedia.org/wiki/Diversity_index#Gini%E2%80%93Simpson_index

      p_squared_sum = 0.0
      for count in outcome_counts.values():
        p_squared_sum += (count / nsamples) ** 2
      gsidx = 1 - p_squared_sum
      total_gsidx += gsidx

      problem_str   = f"{problem:{problem_str_width}}"
      pass_rate_str = f"[{npass:02}/{nsamples:02}]({pass_rate:3}%)"

      # row_strs.append(f"{problem_str} {pass_rate_str} {gsidx:3.2f} {ntokens/1000:5.2f} {row_str:24}")
      row_strs.append(f"{problem_str} {pass_rate_str} {ntokens/1000:5.2f} {row_str:24}")

    print("")
    if not self.wide:
      for row_str in row_strs:
        print(row_str)
    else:
      if len(row_strs) % 2 != 0:
        row_strs.append("")
      half = len(row_strs)//2
      for row_str0,row_str1 in zip(row_strs[:half],row_strs[half:]):
        print(row_str0,"",row_str1)

    print("")
    print(f"pass_rate             = {(pass_rate_sum/len(self.data)):>10.2f}")
    print(f"avg_gini_simpson_idx  = {(total_gsidx/len(self.data)):>10.2f}")
    print(f"total_prompt_tokens   = {total_prompt_tokens:>10}")
    print(f"total_resp_tokens     = {total_resp_tokens:>10}")
    print(f"total_tokens          = {(total_prompt_tokens+total_resp_tokens):>10}")
    print(f"avg_tokens_per_prompt = {(total_prompt_tokens/total_queries):>10.2f}")
    print(f"avg_tokens_per_resp   = {(total_resp_tokens/total_queries):>10.2f}")
    print(f"avg_tokens_per_query  = {((total_prompt_tokens+total_resp_tokens)/total_queries):>10.2f}")
    print(f"total_cost            = {total_cost:>10.2f}")
    print("")

  def write_csv( self, csv_filename ):
    with open( csv_filename, 'w' ) as file:
      for problem,row in self.data.items():

        npass = 0
        for idx,record in enumerate(row):
          if record.passfail == ".":
            npass += 1

        nsamples      = len(row)
        pass_rate     = int((npass/nsamples)*100)

        row_str = ",".join([record.passfail for record in row])

        file.write(f"{problem},{npass},{nsamples},{pass_rate/100.0},{row_str}\n")

#-------------------------------------------------------------------------
# analyze_result
#-------------------------------------------------------------------------

def analyze_result( results, problem, sample, generate_log, compile_log, verilog ):

  # record to store result information

  result_record = ResultRecord()

  # process generate log

  prompt_tokens_pattern = r"prompt_tokens\s*=\s*(\d+)"
  resp_tokens_pattern   = r"resp_tokens\s*=\s*(\d+)"
  cost_pattern          = r"cost\s*=\s*(\d+.\d+)"

  with open( generate_log, 'r' ) as file:
    for line in file:

      match = re.search(prompt_tokens_pattern,line)
      if match:
        result_record.prompt_tokens = int(match.group(1))

      match = re.search(resp_tokens_pattern,line)
      if match:
        result_record.resp_tokens = int(match.group(1))

      match = re.search(cost_pattern,line)
      if match:
        result_record.cost = float(match.group(1))

  # process compile log

  result_record.passfail = '?'
  with open( compile_log, 'r' ) as file:

    error_C     = False
    error_p     = False
    no_mismatch = False

    mismatch_pattern = r'^Mismatches: (\d+) in \d+ samples$'

    for line in file:

      if "syntax error" in line:
        result_record.passfail = 'S'
        break

      if "error" in line:
        error_C = True

      if "error: This assignment requires an explicit cast" in line:
        result_record.passfail = 'e'
        break

      if "error: Sized numeric constant must have a size greater than zero" in line:
        result_record.passfail = '0'
        break

      if "warning: always_comb process has no sensitivities" in line:
        result_record.passfail = 'n'
        break

      if "found no sensitivities so it will never trigger" in line:
        result_record.passfail = 'n'
        break

      if "is declared here as wire" in line:
        result_record.passfail = 'w'
        break

      if "Unknown module type" in line:
        result_record.passfail = 'm'
        break

      if "Unable to bind wire/reg" in line:
        error_p = True

      if "Unable to bind wire/reg/memory `clk'" in line:
        result_record.passfail = 'c'
        break

      if "TIMEOUT" in line:
        result_record.passfail = 'T'
        break

      match = re.match( mismatch_pattern, line )
      if match:
        num_mismatch = int(match.group(1))
        if num_mismatch == 0:
          no_mismatch = True
        else:
          result_record.num_mismatch = num_mismatch

    if result_record.passfail == '?' and error_p:
      result_record.passfail = 'p'

    if result_record.passfail == '?' and error_C:
      result_record.passfail = 'C'

    if result_record.passfail == '?' and no_mismatch:
      result_record.passfail = '.'

  # process verilog to identify possible runtime issues

  if result_record.passfail == '?':

    with open( verilog, 'r' ) as file:

      for line in file:

        if "posedge reset" in line:
          result_record.passfail = 'r'
          break

        if "negedge reset" in line:
          result_record.passfail = 'r'
          break

        if "posedge r)" in line:
          result_record.passfail = 'r'
          break

      if result_record.passfail == '?':
        result_record.passfail = 'R'

  results.add_result( problem, sample, result_record )

#-------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------

def main():

  opts = parse_cmdline()

  # If no problems are given search for directories starting with Prob

  problems = opts.problems
  if not problems:
    problems = glob.glob(f"Prob*")

  # Iterate through problem result directories

  results = Results( opts.wide )

  for problem in sorted(problems):

    problem = problem.rstrip("/")
    for filename in glob.glob(f"{problem}/{problem}_sample*-sv-iv-test.log"):

      # Extract the sample number

      nsample = re.search( r"sample(\d{2})", filename ).group(1)

      # Process logs and verilog for each sample

      generate_log = f"{problem}/{problem}_sample{nsample:02}-sv-generate.log"
      compile_log  = f"{problem}/{problem}_sample{nsample:02}-sv-iv-test.log"
      verilog      = f"{problem}/{problem}_sample{nsample:02}.sv"
      analyze_result( results, problem, nsample, generate_log, compile_log, verilog )

  # Print summary

  results.print()
  if opts.csv:
    results.write_csv( opts.csv )

main()

