# Description:
#   automate client creation.


source $ONTOLOGY_HOME/lib/internal.sh

ont__require GERRITIO_USER ONTOLOGY_ROOT

function gio_client {
  if [[ $# -ne 2 ]]; then
    echo 1>&2 "> gio_client <clientname> <reponame>"
    return
  fi
  export MODCLIENT=1
  echo "GERRITIO_CLIENT($1, $2)" >> $ENVS/$ONTOLOGY_ROOT.m4
  rebuild_pick
  pick $1
  mkdir -m 775 -p $TOP
  (cd $TOP/ && pwd && set -x &&
      git clone \
          ssh://$GERRITIO_USER@review.gerrithub.io:29418/$GERRITIO_USER/$2 $2)
  local -a remotes=($(cd $TOP/$2 && git branch -r | egrep -v 'HEAD|master'))
  for remote in ${remotes[@]}; do
    (cd $TOP/$2 && set -x && git checkout --track $remote)
  done
  # Switch to master
  (cd $TOP/$2 && set -x && git checkout master)
  unset MODCLIENT
}

function pick {
  (make -C $ENVS &>/dev/null)
  eval $($ONTOLOGY_HOME/bin/ont -f $ONTOLOGY_ROOT $@)
  if [[ -z "$MODCLIENT" ]]; then
    exec bash -l
  fi
}

function rebuild_pick {
  tf=$ENVS/$ONTOLOGY_ROOT.tab
  grep ${ONTOLOGY_ROOT}_NAMESPACES $ENVS/$ONTOLOGY_ROOT.sh |
    perl -ple 's/.+"(.+)"/$1/' |
    sort \
      > $tf
  chmod 600 $tf
  _build_implied_picks
}

function _pick_completion {
  tf=$ENVS/$ONTOLOGY_ROOT.tab
  if [[ ! -f $tf ]]; then
    rebuild_pick
  fi
  local curw
  local pick_words=$(cat $tf)
  COMPREPLY=()
  curw=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($(compgen -W "$pick_words" -- $curw))
  return 0
}
complete -F _pick_completion -o bashdefault pick

function _build_implied_picks {
  names=$(cat $ENVS/$ONTOLOGY_ROOT.tab | awk '{print $NF}')
  for name in $names; do
    eval "function ${name}_ { (eval \$($ONTOLOGY_HOME/bin/onts -f $ONTOLOGY_ROOT $name); eval \$@;); }; "
  done
}
