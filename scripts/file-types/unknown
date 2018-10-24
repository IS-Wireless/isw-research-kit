#! /usr/bin/env bash

function is_unknown () {
  local readonly FILE=${1} # unused
  debugger "FILE" "${FILE}"
  echo "unknown"
  true # always is some file type : )
}

function unknown_parser () {
  local readonly INPUT=${1}
  local readonly OUTPUT=${2}

  debugger "INPUT" "${INPUT}"
  debugger "OUTPUT" "${OUTPUT}"
  cat <<- EOF
${INPUT}: unknown file type
EOF
  log stack
  return 1
}

function unknown_pagecount () {
  local readonly INPUT=${1}

  debugger "INPUT" "${INPUT}"
  echo "0"
}

function unknown_requirements () {
  echo "-f"
}

