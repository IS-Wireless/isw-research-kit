#! /usr/bin/env bash

function is_empty () {
  local readonly STRING=${1}
  test "x${STRING}" = "x"
}

function tmp () {
  if is_empty "${TMPDIR}"
  then
    TMPDIR=$(dirname $(mktemp -u))
  fi

  echo "$TMPDIR"
}

# requires:
# LOG - file name to which messages will be logged
function panic () {
  cat <<- EOF
+------------------------------+
| =========== UH-OH ========== |
| unrecoverable error occurred |
+------------------------------+
Please check the logs at:
${LOG}
for a clue what went wrong.
If problem persists contact:
m.jemielity@is-wireless.com
EOF
  exit 1
}

# requires:
# DEBUG - 0 is disabled, 1 is enabled
# LOG_PREFIX - custom string prefixed to each log line
function log () {
  if is_empty "${LOG_PREFIX}"
  then
    local readonly INTERNAL_LOG_PREFIX="[$(date)] ${FUNCNAME[1]}: "
  else
    local readonly INTERNAL_LOG_PREFIX="${LOG_PREFIX}"
  fi
  if test "x${DEBUG}" == "x1"
  then
    echo "${INTERNAL_LOG_PREFIX}${*}" >&2
  fi
  ${*}
}

# requires:
# DEBUG - 0 is disabled, 1 is enabled
# LOG_PREFIX - custom string prefixed to each log line
function debugger () {
  local readonly NAME="${1}"
  local readonly VARIABLE="${2}"
  if log is_empty "${LOG_PREFIX}"
  then
    local readonly INTERNAL_LOG_PREFIX="[$(date)] ${FUNCNAME[1]}: "
  else
    local readonly INTERNAL_LOG_PREFIX="${LOG_PREFIX}"
  fi
  if test "x${DEBUG}" == "x1"
  then
    echo "${INTERNAL_LOG_PREFIX}${NAME} = ${VARIABLE}" >&2
  fi
}


# requires:
# DEBUG - 0 is disabled, 1 is enabled
function stack () {
  if log is_empty "${LOG_PREFIX}"
  then
    local readonly INTERNAL_LOG_PREFIX="[$(date)] ${FUNCNAME[1]}: "
  else
    local readonly INTERNAL_LOG_PREFIX="${LOG_PREFIX}"
  fi
  if test "x${DEBUG}" == "x1"
  then
    echo "${INTERNAL_LOG_PREFIX}callstack:" >&2
    printf '%s\n' "${FUNCNAME[@]}" >&2
  fi
}

function is_root () {
  local readonly USER=${1} # currently unused
  debugger "USER" "${USER}"
  debugger "EUID" "${EUID}"
  log test "x$EUID" = "x0"
}

function notice_sudoer () {
  local readonly USER=${1}
  debugger "USER" "${USER}"
  if ! log is_root "${USER}"
  then
    cat <<- EOF
+------------------------------------------------------+
| sudo password needed to change system configuration  |
+------------------------------------------------------+
EOF
    exit 1
  fi
}

function easy_install () {
  local readonly APTGET_FLAGS="-f -y --force-yes -q"
  local readonly PACKAGES="${1}"

  debugger "PACKAGES" "${PACKAGES}"
  if ! $(dpkg -s ${PACKAGES} 1>/dev/null 2>/dev/null)
  then
    log notice_sudoer $(whoami)
    if test "x$?" = "x1"
    then
      log stack
      return 1
    fi
    DEBIAN_FRONTEND=noninteractive sudo apt-get ${APTGET_FLAGS} install ${PACKAGES} || exit 1
  fi
}

function find_first_line () {
  local readonly FILE=${1}
  local readonly KEYWORD=${2}
  debugger "FILE" "${FILE}"
  debugger "KEYWORD" "${KEYWORD}"
  local readonly LINE=$(grep -m 1 -n "${KEYWORD}" ${FILE} | sed 's|\:.*||')
  debugger "LINE" "${LINE}"

  echo ${LINE}
}

function regexp_3gpp_specification () {
  local readonly LINE="${1}"
  debugger "LINE" "${LINE}"
  echo -n ${LINE} | \
    sed '/^.*\([0-9][0-9]\.[0-9][0-9][0-9]\).*$/{s/^.*\([0-9][0-9]\.[0-9][0-9][0-9]\).*$/\1/;q}; /^.*\([0-9][0-9]\.[0-9][0-9][0-9]\).*$/!{s/^.*$//;q 1}'
}

function regexp_etsi_specification () {
  local readonly LINE="${1}"
  debugger "LINE" "${LINE}"
  echo -n ${LINE} | \
    sed '/^.*1\([0-9][0-9]\) \([0-9][0-9][0-9]\).*$/{s/^.*1\([0-9][0-9]\) \([0-9][0-9][0-9]\).*$/\1.\2/;q}; /^.*1\([0-9][0-9]\) \([0-9][0-9][0-9]\).*$/!{s/^.*$//;q 1}'
}

function regexp_ietf_specification () {
  local readonly LINE="${1}"
  debugger "LINE" "${LINE}"
  echo -n ${LINE} | \
    sed '/^.*\(RFC [0-9][0-9][0-9][0-9]\).*$/{s/^.*\(RFC [0-9][0-9][0-9][0-9]\).*$/\1/;q}; /^.*\(RFC [0-9][0-9][0-9][0-9]\).*$/!{s/^.*$//;q 1}'
}

function get_specification () {
  local readonly FILE=${1}
  local readonly LINE=$(find_first_line ${FILE} "Contents$")
  debugger "FILE" "${FILE}"
  debugger "LINE" "${LINE}"

  if log is_empty ${LINE}
  then
    log stack
    return 1
  fi

  local SPECIFICATION=""
  while IFS='' read -r line
  do
    local readonly CURRENT=$( \
      regexp_3gpp_specification "${line}" | sed ':a;N;$!ba;s/\n//g' || \
      regexp_etsi_specification "${line}" | sed ':a;N;$!ba;s/\n//g' || \
      regexp_ietf_specification "${line}" | sed ':a;N;$!ba;s/\n//g' \
    )
    debugger "CURRENT" "${CURRENT}"
    if ! log is_empty "${CURRENT}"
    then
      if ! log is_empty "${SPECIFICATION}"
      then
        if log test "x${SPECIFICATION}" != "x${CURRENT}"
        then
          log stack
          return 1
        fi
      fi
      SPECIFICATION=${CURRENT}
    fi
    debugger "SPECIFICATION" "${SPECIFICATION}"
  done <<< "$(head -n ${LINE} ${FILE})"

  echo ${SPECIFICATION}
}

