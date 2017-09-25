# Description: -*-sh-*-
#   Shared functions.

function ont__warn { test $debug && echo "$*" 1>&2; }

function ont__error { echo " -- $* == " 1>&2; ont__stack_trace; exit 1; }

function ont__stack_trace {
  for (( i=1; i<${#FUNCNAME[@]}; i++ )); do
    echo " ${FUNCNAME[$i]}(${BASH_SOURCE[$i]}:${BASH_LINENO[$i-1]})"
  done
}

function ont__require {
  local -a _missing=()
  for x in $@; do
    local n="\$$(echo "$x")"
    local v="$(eval echo "$n")"
    if [[ -z "$v" ]]; then
      _missing+=($n)
    fi
  done
  if [[ -n "${_missing[@]}" ]]; then
    echo "${_missing[@]} are required, yet undefined!" 1>&2
    return 2
  fi
}

function ont__in {
  local term=$1; shift
  for t in $@; do
    if [[ $term = $t ]]; then
      return 0
    fi
  done
  return 1
}

function ont__join {
  local d=,
  args=$(getopt -l "delim:" -o "d:" -- "$@")
  eval set -- "$args"
  while [[ $# -ge 1 ]]; do
    case "$1" in
      --) shift; break;;
      -d|--delim) d="$2"; shift;;
    esac
    shift
  done
  local out=''
  for i in $@; do
    out="$out$d$i"
  done
  echo "$out" | sed 's/^'"$d"'//'
  return 0
}

