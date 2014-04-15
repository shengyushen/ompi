#!/bin/sh

#####
#
# Configuration options
#
#####

# Dir for ignore SVN checkouts
ignore_top=/u/mpiteam/openmpi/ignore-files

# helper scripts dir
script_dir=/u/mpiteam/scripts

# Branches on which to build .gitignore and .hgignore
if [ $# -eq 0 ] ; then
    # We don't care about older than v1.6
    #dirs="trunk branches/v1.8 branches/v1.6"
    dirs="trunk"
else
    dirs=$@
fi

export PATH=$HOME/local/bin:$PATH
export LD_LIBRARY_PATH=$HOME/local/lib:$LD_LIBRARY_PATH

#####
#
# Actually do stuff
#
#####

doit() {
    cmd="$*"
    out=`eval $*`
    if test $? -ne 0; then
        echo command failed: $cmd
        echo directory: `pwd`
        exit 1
    fi
}

# Loop making ignore files
for dir in $dirs; do
    cd $ignore_top/$dir

    doit svn up
    doit svnversion .
    if test "`echo $out | egrep '[MSP:]'`"  != ""; then
        echo Not clean SVN checkout in `pwd` -- ignored
        exit 1
    fi
    doit svn st
    if test -n "$out"; then
        echo Not clean SVN checkout in `pwd` -- ignored
        exit 1
    fi

    doit ./contrib/git/build-gitignore.pl --output .gitignore_global
    doit ./contrib/hg/build-hgignore.pl --output .hgignore_global

    doit svn commit -m .gitignore_global .hgignore_global -m '"Update git/hg ignore files"'
done
