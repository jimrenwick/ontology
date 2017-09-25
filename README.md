# ontology

Tools for working with git + shell + emacs

## Install

_Instructions are purposely vague until the installer is done._

```sh
> git clone https://github.com/jimrenwick/ontology.git

# Add this to your bashrc:
# ONTOLOGY
export ONTOLOGY_HOME=$HOME/ontology-src
export GERRITIO_USER=$USER
export ONTOLOGY_ROOT=some-root
export ENVS=$ONTOLOGY_HOME/onts
function reload_ont {
  source $ONTOLOGY_HOME/lib/git-env.sh
  source $ONTOLOGY_HOME/lib/onts.sh
}
reload_ont
```

- Add a file to $ENVS that has your NS() definitions in it.
- Use gio_client to build a new git client definition.
- pick <new client>



## TODO

- Still need to write an installer.

## single roots

At some point during unix's life, someone decided that child
environments inherit from parents, but the reverse isn't true. The
parent has to explicitly eval the child state to get it.

The idea behind ontology is that most of the work we do looks the same
in that there is an editor for source code, some kind of build rules,
some kind of source control, some series of deployment targets/process
and some kind of tests. The tools that implement all of those things
are likely different, but they all share the command line. By setting
some variables according to known patterns, we can get disparate
environments to behave in similar ways. Learn one way to work with
many different things.
