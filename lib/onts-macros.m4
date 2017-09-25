m4_divert(-1)m4_dnl   #-*-sh-*-
m4_changequote(<++, ++>)


m4_define(NS, <++m4_pushdef(NS_VAR, $1<++++>_NAMESPACES)++>)


m4_define(MAIN, <++
# MAIN
$1_main=$2
$1_PROMPT_COMMAND='echo -ne "\033]0;m4_translit($1,a-z,A-Z): ($ONTOLOGY) $PWD\007"'
NS_VAR="$NS_VAR $1"
m4_shift(m4_shift($*))
# END MAIN
++>)



m4_define(GERRITIO_CLIENT, <++
# GIO_CLIENT
MAIN($1, $HOME/src-$1/$2)
$1_TOP=$HOME/src-$1/
$1_hooks=$TOP/hooks
$1_org=$TOP/$1.org
$1_HISTFILE=$TOP/bash_history
$1_HISTFILESIZE=1500
$1_HISTIGNORE="ignoreboth:exit:fg:ls.*"
m4_shift(m4_shift(m4_shift(m4_shift($*))))
# END GIO_CLIENT
++>)



m4_divert<++++>m4_dnl
