# Description  -*-sh-*-
#   Tools for working with git branches with the ontology assumptions.

source $ONTOLOGY_HOME/lib/internal.sh

function _ontg_update_env {
  local _commit_msg=.git/hooks/commit-msg
  if [[ ! -f $_commit_msg ]]; then
    echo 1>&2 'Loading Gerrit commit hook...'
    curl -Lo $_commit_msg \
         http://review.gerrithub.io/tools/hooks/commit-msg
    chmod +x $_commit_msg
  fi
  return 0
}

_ontg_update_env

if [[ -z "$_ORIGINAL_PS1" ]]; then
  export _ORIGINAL_PS1=$PS1
fi

ONT_ENV=$ONTOLOGY_HOME/lib/git-env.sh

# Use Topic Branches + ff-only with git + gerrit.
export GIT_PROJECT_NAME=$(basename $(pwd) | sed 's/^\.//')
export GIT_WORKING_BRANCH=${GIT_WORKING_BRANCH:-master}
export GIT_RELEASE_BRANCH=${GIT_RELEASE_BRANCH:-release}
export ONT_GIT=https://review.gerrithub.io/#/$GIT_PROJECT_NAME

export ONTG_COMMANDS=(
  $(grep 'function _ontg_' $ONT_ENV |
       grep -v ONT_ENV |
       perl -ple 's/.+ontg_(.+?)\s.*/$1/' |
       grep -v _tab_completion))

function _ontg_sync {
  if [[ $# -lt 1 ]]; then
    echo 1>&2 '! Need to provide a topic name, one of:' \
              "'"$(ont__join --d "', '" $(_ontg_sync_tab_completion))"'"
    return 1
  fi
  git checkout $GIT_WORKING_BRANCH
  git fetch origin $GIT_WORKING_BRANCH
  git merge --ff-only origin/$GIT_WORKING_BRANCH
  git checkout $1
  git rebase $GIT_WORKING_BRANCH $1
}

function _ontg_sync_tab_completion {
  git branch -v | sed s'/^..//' | awk '{print $1}'
  return 0
}

function _ontg_revert {
  git checkout $*
}

function _ontg_desc {
  if [[ $# -lt 1 ]]; then
    echo 1>&2 '> ontg desc <some cl>'
    return 1
  fi
  local _cl=$1; shift
  (git log $_cl -n 1 &&
      echo -e "\b" &&
      git --no-pager diff $_cl^ $_cl --color)
}

function _ontg_pending {
  echo -e " == BRANCHES == "
  git branch -vv
  echo -e "\n -- LOG --"
  git log --graph --all --oneline --decorate -n 12
  echo -e "\n -- STATUS --"
  git status
  return 0
}

function _ontg_change {
  local args=$(getopt -l "oops" -l root_branch -o "orf" -- "$@")
  eval set -- "$args"
  while [[ $# -ge 1 ]]; do
    case "$1" in
      --) shift; break;;
      -f|-r|--root_branch) force=true;;
      -o|--oops) oops=true;;
    esac
    shift
  done
  if [[ $# -lt 1 ]]; then
    echo 1>&2 '! Need a topic name for this change'
    return 1
  fi
  local finalizer="true"
  if [[ $oops ]]; then
    git stash
    finalizer="git stash pop"
  fi
  if [[ $force ]]; then
    git checkout $GIT_WORKING_BRANCH
  fi
  git checkout -b $1
  $finalizer
  return 0
}
function _ontg_change_tab_completion {
  echo "--oops -f"
  return 0
}

function _ontg_review {
  if [[ "$1" = "-f" ]]; then
    git pull origin $GIT_WORKING_BRANCH
    git rebase $GIT_WORKING_BRANCH
  fi
  local branch=$(git rev-parse --abbrev-ref HEAD)
  git push origin HEAD:refs/for/$GIT_WORKING_BRANCH%topic=$branch "$@"
  return 0
}

function ontg {
  local cmd=$1; shift
  if $(type _ontg_$cmd 2>/dev/null | grep -q 'is a function'); then
    _ontg_$cmd "$@"
  else
    eval git $cmd "$@"
  fi
}


function _ontg_ls {
  git status --porcelain | awk '{print $2}'
  return 0
}

function _ontg_completions {
  local commands="list ${ONTG_COMMANDS[@]}"
  local curw=${COMP_WORDS[COMP_CWORD]}
  local lastw=${COMP_WORDS[COMP_CWORD - 1]}
  if [[ $lastw = "ontg" || $lastw = "g5" ]]; then
    COMPREPLY=($(compgen -W "$commands" -- $curw))
  elif $(ont__in $lastw ${ONTG_COMMANDS[@]}); then
    fn=$(echo _ontg_${lastw}_tab_completion)
    if $(type $fn 2>/dev/null | grep -q 'is a function'); then
      COMPREPLY=($(compgen -W "$(eval $fn)" -- $curw))
    else
      COMPREPLY=($(compgen -W "$(_ontg_ls)" -- $curw))
    fi
  else
    COMPREPLY=($(compgen -W "$(_ontg_ls)" -- $curw))
  fi
  return 0
}
complete -o bashdefault -F _ontg_completions ontg g5
