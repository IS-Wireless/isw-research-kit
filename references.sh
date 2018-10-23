#! /usr/bin/env bash

. ${BASH_SOURCE%/*}/scripts/common.sh
. ${BASH_SOURCE%/*}/scripts/file-types/doc.sh
. ${BASH_SOURCE%/*}/scripts/file-types/pdf.sh
. ${BASH_SOURCE%/*}/scripts/file-types/unknown.sh

readonly PROGRAM_NAME="references.sh"
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
  while getopts ":df:h" OPT ${@}
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
    if log "${TYPE}" "${FILE}"
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
  if log test "x$?" = "x1"
  then
    log stack
    return 1
  fi
}

function regexp_3gpp_references () {
  local readonly LINE="${1}"
  debugger "LINE" "${LINE}"
  echo -n ${LINE} | \
    sed '/^.*\([0-9][0-9]\.[0-9][0-9][0-9]\):.*$/{s/^.*\([0-9][0-9]\.[0-9][0-9][0-9]\):.*$/\1/;q}; /^.*\([0-9][0-9]\.[0-9][0-9][0-9]\):.*$/!{s/^.*$//;q 1}'
}

function regexp_etsi_references () {
  local readonly LINE="${1}"
  debugger "LINE" "${LINE}"
  echo -n ${LINE} | \
    sed '/^.*1\([0-9][0-9]\) \([0-9][0-9][0-9]\):.*$/{s/^.*1\([0-9][0-9]\) \([0-9][0-9][0-9]\):.*$/\1.\2/;q}; /^.*1\([0-9][0-9]\) \([0-9][0-9][0-9]\):.*$/!{s/^.*$//;q 1}'
}

function regexp_ietf_references () {
  local readonly LINE="${1}"
  debugger "LINE" "${LINE}"
  echo -n ${LINE} | \
    sed '/^.*\(RFC [0-9][0-9][0-9][0-9]\):.*$/{s/^.*\(RFC [0-9][0-9][0-9][0-9]\):.*$/\1/;q}; /^.*\(RFC [0-9][0-9][0-9][0-9]\):.*$/!{s/^.*$//;q 1}'
}

function get_references () {
  local readonly FILE=${1}
  local readonly SPECIFICATION=${2}
  debugger "FILE" "${FILE}"
  debugger "SPECIFICATION" "${SPECIFICATION}"
  local readonly START_LINE=$(find_first_line ${FILE} "References$")
  debugger "START_LINE" "${START_LINE}"
  local readonly END_LINE=$(find_first_line ${FILE} "Definitions.*abbreviations$")
  debugger "END_LINE" "${END_LINE}"

  if log is_empty ${START_LINE}; then exit 1; fi
  if log is_empty ${END_LINE}; then exit 1; fi
  if log test ${START_LINE} -gt ${END_LINE}; then exit 1; fi

  while IFS='' read -r line
  do
    local readonly CURRENT=$(regexp_3gpp_references "${line}" || regexp_etsi_references "${line}" || regexp_ietf_references "${line}")
    debugger "CURRENT" "${CURRENT}"

    if ! is_empty "${CURRENT}"
    then
      if log test "x${CURRENT}" != "x${SPECIFICATION}"
      then
        echo -n "${CURRENT}" | sed ':a;N;$!ba;s/\n//g'
        echo -n ", "
      fi
    fi
  done <<< "$(sed -n ''"${START_LINE}"','"${END_LINE}"'p' ${FILE})"
}

function parse () {
  local readonly FILE=${1}
  debugger "FILE" "${FILE}"

  # 0. check if this is proper documentation
  #   a. find line of "Contents" keyword
  #   b. check whether text until that line contains specification number
  # 1. print this document's number
  # 2. find references section
  # 3. print all reference numbers

  local readonly SPECIFICATION=$(get_specification ${FILE})
  debugger "SPECIFICATION" "${SPECIFICATION}"
  if log is_empty ${SPECIFICATION}
  then
    cat <<- EOF
can't find proper specification number in document header
EOF
    log stack
    return 1
  fi

  local readonly REFERENCES=$(get_references ${FILE} ${SPECIFICATION} | sed 's/^\(.*\), $/\1/')
  debugger "REFERENCES" "${REFERENCES}"

  echo "${SPECIFICATION}: ${REFERENCES}"
}

function main () {
  parse_args "${@}" || panic

  local readonly FILE=${INPUT}
  debugger "FILE" "${FILE}"
  local readonly TYPE=$(file_type ${FILE})
  debugger "TYPE" "${TYPE}"
  local readonly PARSER=$(parser ${TYPE})
  debugger "PARSER" "${PARSER}"
  local readonly OUTPUT=$(mktemp -q)
  debugger "OUTPUT" "${OUTPUT}"

  log install_missing_components "${TYPE}" || panic

  log ${PARSER} ${FILE} ${OUTPUT} || panic

  log parse ${OUTPUT} || panic

  log rm -rf ${OUTPUT} || panic
}

main "${@}" 2>&1 | tee ${LOG}

