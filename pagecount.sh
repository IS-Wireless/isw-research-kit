#! /usr/bin/env bash

. ${BASH_SOURCE%/*}/scripts/common.sh
. ${BASH_SOURCE%/*}/scripts/file-types/doc.sh
. ${BASH_SOURCE%/*}/scripts/file-types/pdf.sh
. ${BASH_SOURCE%/*}/scripts/file-types/unknown.sh

readonly PROGRAM_NAME="pagecount.sh"
readonly LOG=$(tmp)/${PROGRAM_NAME}.log

function usage () {
  cat <<- EOF
Usage: ${PROGRAM_NAME} [-d] [-h] <-f FILE>
  -d - enable debug output
  -h - show this help
  -f </path/to/file> - specification to parse
EOF
}

INPUT=""
DEBUG=0
function parse_args () {
  while getopts ":df:h" OPT
  do
    case $OPT in
      d)
        DEBUG=1
        ;;
      f)
        INPUT="${OPTARG}"
        ;;
      h)
        usage
        exit 0
        ;;
      \?|:)
        usage
        exit 1
        ;;
    esac
  done
  debugger "INPUT" "${INPUT}"

  if log is_empty ${INPUT}
  then
    usage
    exit 1
  fi
}

function file_type () {
  local readonly FILE=${1}
  debugger "FILE" "${FILE}"
  local readonly TYPES="is_pdf is_doc is_unknown"

  for TYPE in ${TYPES}
  do
    if "${TYPE}" "${FILE}"
    then
      debugger "TYPE" "${TYPE}"
      break
    fi
  done
}

function parser () {
  local readonly TYPE=${1}
  debugger "TYPE" "${TYPE}"

  echo "${TYPE}_parser"
}

function install_missing_components () {
  local readonly TYPE=${1}
  debugger "TYPE" "${TYPE}"

  log easy_install "\
    $(${TYPE}_requirements) \
  "
  if test "x$?" = "x1"
  then
    log stack
    return 1
  fi
}

function parse () {
  local readonly TYPE=${1}
  debugger "TYPE" "${TYPE}"
  local readonly FILE=${2}
  debugger "FILE" "${FILE}"

  # 0. check if this is proper documentation
  #   a. find line of "Contents" keyword
  #   b. check whether text until that line contains specification number
  # 1. print this document's number
  # 2. find references section
  # 3. print all reference numbers

  local readonly PAGES="$(${TYPE}_pagecount ${FILE})"
  debugger "PAGES" "${PAGES}"

  echo "${PAGES}"
}

function main () {
  parse_args ${*} || panic

  local readonly FILE=${INPUT}
  debugger "FILE" "${FILE}"
  local readonly TYPE=$(file_type ${FILE})
  debugger "TYPE" "${TYPE}"

  log install_missing_components "${TYPE}" || panic

  log parse ${TYPE} ${FILE} || panic
}

main ${*} 2>&1 | tee ${LOG}

