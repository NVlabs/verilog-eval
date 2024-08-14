#=========================================================================
# Toplevel configure.ac for running LLM codegen experiments
#=========================================================================
# SPDX-FileCopyrightText: Copyright (c) 2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: MIT
# Author : Christopher Batten, NVIDIA and Nathaniel Pinckney, NVIDIA

#-------------------------------------------------------------------------
# Project metadata
#-------------------------------------------------------------------------

m4_define( proj_name,         [LLM Code Generation Experiments])
m4_define( proj_maintainer,   [Christopher Batten])
m4_define( proj_abbreviation, [verilog-eval-v2])

#-------------------------------------------------------------------------
# Project version information
#-------------------------------------------------------------------------
# Version information is meant to be managed through a version control
# system's tags and revision numbers. In a working copy the version will
# not be defined here (you should just use the version control system's
# mechanisms). When we make a distribution then we can set the version
# here as formed by the scripts/vcs-version.sh script so that the
# distribution knows what version it came from. If you are not using
# version control then it is fine to set this directly.

m4_define( proj_version, [?])

#-------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------

AC_INIT(proj_name,proj_version,proj_maintainer,proj_abbreviation)
AC_CONFIG_SRCDIR([scripts/sv-generate])

#-------------------------------------------------------------------------
# Basic checks
#-------------------------------------------------------------------------

AC_CHECK_PROGS([IVERILOG],[iverilog],[no])
AS_IF([test "${IVERILOG}" = "no"],
[
  AC_MSG_ERROR([Must have iverilog installed!])
])

#-------------------------------------------------------------------------
# --with-model
#-------------------------------------------------------------------------

AC_ARG_WITH(model,
  AS_HELP_STRING([--with-model],[Large language model to use]),
  [model="${with_model}"],
  [model="gpt4-turbo"])

AC_SUBST([model])
AC_MSG_NOTICE([using model: ${model}])

#-------------------------------------------------------------------------
# --with-examples
#-------------------------------------------------------------------------

AC_ARG_WITH(examples,
  AS_HELP_STRING([--with-examples],[Include in-context learning examples with settable number of shots]),
  [examples="${with_examples}"],
  [examples="0"])

AC_SUBST([examples])
AC_MSG_NOTICE([using in-context learning examples with shots: ${examples}])

#-------------------------------------------------------------------------
# --with-rules
#-------------------------------------------------------------------------

AC_ARG_WITH(rules,
  AS_HELP_STRING([--with-rules],[Include in-context learning rules]),
  [rules="yes"],
  [rules="no"])

AC_SUBST([rules])
AC_MSG_NOTICE([using in-context learning rules: ${rules}])

#-------------------------------------------------------------------------
# --with-task
#-------------------------------------------------------------------------

AC_ARG_WITH(task,
  AS_HELP_STRING([--with-task],[Task to execute]),
  [task="${with_task}"],
  [task="spec-to-rtl"])

AC_SUBST([task])
AC_MSG_NOTICE([using task: ${task}])

#-------------------------------------------------------------------------
# --with-samples
#-------------------------------------------------------------------------

AC_ARG_WITH(samples,
  AS_HELP_STRING([--with-samples],[Number of samples for each problem]),
  [samples="${with_samples}"],
  [samples="20"])

AC_SUBST([samples])
AC_MSG_NOTICE([using samples: ${samples}])

#-------------------------------------------------------------------------
# --with-temperature
#-------------------------------------------------------------------------

AC_ARG_WITH(temperature,
  AS_HELP_STRING([--with-temperature],[Temperature of model]),
  [temperature="${with_temperature}"],
  [temperature=0.85])

AC_SUBST([temperature])
AC_MSG_NOTICE([using temperature: ${temperature}])

#-------------------------------------------------------------------------
# --with-top-p 
#-------------------------------------------------------------------------

AC_ARG_WITH(top-p,
  AS_HELP_STRING([--with-top-p],[Top-p of model]),
  [top_p="${with_top_p}"],
  [top_p=0.95])

AC_SUBST([top_p])
AC_MSG_NOTICE([using top-p: ${top_p}])


#-------------------------------------------------------------------------
# dataset
#-------------------------------------------------------------------------

AC_ARG_WITH(dataset,
  AS_HELP_STRING([--with-dataset],[Directory with dataset files]),
  [dataset_dir="${with_dataset}"],
  [dataset_dir="${srcdir}/dataset_${task}"])

AC_SUBST([dataset_dir])
AC_MSG_NOTICE([using dataset: ${dataset_dir}])

#-------------------------------------------------------------------------
# problems
#-------------------------------------------------------------------------

AC_ARG_WITH(problems,
  AS_HELP_STRING([--with-problems],[File with list of problems]),
  [problems_file="${with_problems}"],
  [problems_file="${dataset_dir}/problems.txt"])

AC_SUBST([problems_file])
AC_MSG_NOTICE([using problems: ${problems_file}])

#-------------------------------------------------------------------------
# create prompt.mk file
#-------------------------------------------------------------------------

AC_MSG_NOTICE([creating problems.mk])

cat > problems.mk \
<<'END'
#=========================================================================
# problems.mk
#=========================================================================
# Generated by the configure script from dataset/problems.txt

problems = \
END

sed -e '/^\s*$/d' -e 's/^\(.*\)$/  \1 \\/' \
    ${problems_file} >> problems.mk

echo "" >> problems.mk

#-------------------------------------------------------------------------
# create samples.mk file
#-------------------------------------------------------------------------

AC_MSG_NOTICE([creating samples.mk])

cat > samples.mk \
<<'END'
#=========================================================================
# samples.mk
#=========================================================================
# Generated by the configure script from dataset/problems.txt

END

sed -e '/^\s*$/d' -e "s/^\(.*\)$/\1_num_samples =  ${samples}/" \
    ${problems_file} | column -t >> samples.mk

echo "" >> samples.mk

#-------------------------------------------------------------------------
# pregen
#-------------------------------------------------------------------------

AC_ARG_WITH(pregen-dir,
  AS_HELP_STRING([--with-pregen-dir],[Directory for storing pregen files]),
  [pregen_dir="${with_pregen_dir}"],
  [pregen_dir="DEFAULT"])

AS_IF([ test "${pregen_dir}" != "DEFAULT" ],
[
  AC_MSG_NOTICE([using pregen dir: ${pregen_dir}])
],[
  if [[ -d "../../verilog-eval-v2-pregen" ]]; then
    pregen_dir="../../verilog-eval-v2-pregen"
    AC_MSG_NOTICE([using pregen dir: ${pregen_dir}])
  else
    AC_MSG_NOTICE([no pregen dir specified])
  fi
])

AC_SUBST([pregen_dir])

AC_ARG_WITH(pregen,
  AS_HELP_STRING([--with-pregen],[Use pregen files]),
  [pregen_en="yes"],
  [pregen_en="no"])

AS_IF([ test "${pregen_en}" = "yes" ],
[
  AC_MSG_NOTICE([using pregen: ${with_pregen}])
  cp -r ${with_pregen}/* .
])

#-------------------------------------------------------------------------
# Output
#-------------------------------------------------------------------------

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
