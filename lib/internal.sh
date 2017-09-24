# Description: -*-sh-*-
#   Shared functions.

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

