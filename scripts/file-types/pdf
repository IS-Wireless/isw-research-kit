#! /usr/bin/env bash

function is_pdf () {
  local readonly FILE=${1}
  local readonly OUTPUT="$(/usr/bin/env file ${FILE})"

  debugger "FILE" "${FILE}"
  debugger "OUTPUT" "${OUTPUT}"
  if test "x$(echo -n ${OUTPUT} | grep 'PDF')" != "x"
  then
    echo "pdf"
    return 0
  fi

  log stack
  return 1
}

function pdf_parser () {
  local readonly INPUT=${1}
  local readonly OUTPUT=${2}

  debugger "INPUT" "${INPUT}"
  debugger "OUTPUT" "${OUTPUT}"
  log pdftotext ${INPUT} ${OUTPUT}
  if test "x$?" = "x1"
  then
    log stack
    return 1
  fi
}

function pdf_pagecount () {
  local readonly INPUT=${1}

  debugger "INPUT" "${INPUT}"

  local readonly INFO="$(pdfinfo ${INPUT})"
  if test "x$?" = "x1"
  then
    log stack
    return 1
  fi

  echo "$INFO" | grep "Pages" | awk '{print $2}'
}

function pdf_requirements () {
  echo "poppler-utils"
}

