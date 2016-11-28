#!/usr/bin/env bash

# Fail on command errors and unset variables.
set -e -u -o pipefail

# Prevent commands misbehaving due to locale differences.
export LC_ALL=C

# Ensure permissions of created files to be 700.
umask 077

# Ensure temporary file to be removed however the process terminates.
clean_exit() {
  [[ -n ${Tmp_file} ]] && rm -f "${Tmp_file}"
}
readonly Tmp_base=`basename $0`
readonly Tmp_file=`mktemp ${Tmp_base}.XXXXXX.go`
trap clean_exit EXIT
trap 'trap - EXIT; clean_exit; exit -1' SIGHUP SIGINT SIGTERM



## Constants.

# Go source.
readonly Source_file="./sakura-simplemonitor.go"

# Output file name.
# If you change it, don't forget to add it to your `.gitignore`, too!
readonly Out_file="sakura-simplemonitor"

# File containing token info.
# If you change it, don't forget to add it to your `.gitignore`, too!
readonly Token_file="./token.ini"



## Get token info from file.

if [ ! -r ${Token_file} ]; then
  echo "❌️ ${Token_file} がありません。"
  exit 1
else
  readonly Token=`grep '^token=' ${Token_file} | sed -e 's/token=//'`
  readonly Secret=`grep '^secret=' ${Token_file} | sed -e 's/secret=//'`
fi



## Build.

if [ ! -r ${Source_file} ]; then
  echo "❌️ ${Source_file} がありません。"
  exit 1
else

  cat ${Source_file} \
    | sed -e "s/%%token%%/${Token}/" \
    | sed -e "s/%%secret%%/${Secret}/" \
    > ${Tmp_file}

  go build -o "${Out_file}" ${Tmp_file}

fi



exit 0
