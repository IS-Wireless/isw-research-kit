#! /usr/bin/env bash

function is_doc () {
  local readonly FILE=${1}
  local readonly OUTPUT="$(/usr/bin/env file ${FILE})"

  debugger "FILE" "${FILE}"
  debugger "OUTPUT" "${OUTPUT}"
  if test "x$(echo -n ${OUTPUT} | grep 'Composite Document File')" != "x"
  then
    echo "doc"
    return 0
  fi

  log stack
  return 1
}

function doc_parser () {
  local readonly INPUT=${1}
  local readonly OUTPUT=${2}

  debugger "INPUT" "${INPUT}"
  debugger "OUTPUT" "${OUTPUT}"
  if log test "x${DEBUG}" == "x1"
  then
    # can't use log here
    echo "${LOG_PREFIX}catdoc ${INPUT} > ${OUTPUT}" >&2
  fi
  catdoc ${INPUT} > ${OUTPUT}

  if test "x$?" = "x1"
  then
    log stack
    return 1
  fi
}

function doc_pagecount () {
  local readonly INPUT=${1}

  debugger "INPUT" "${INPUT}"

  local readonly INFO="$(wvSummary ${INPUT})"
  if test "x$?" = "x1"
  then
    log stack
    return 1
  fi

  echo "$INFO" | grep "Number of Pages" | awk '{print $5}'
}

function doc_requirements () {
  echo "catdoc wv"
}

