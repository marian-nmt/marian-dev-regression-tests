#!/bin/bash -x 

##################################################################### 
# AUTHOR: pedrodiascoelho
#####################################################################

# Exit on error
set -e

# Test code goes here
test -f $MRT_DATA/europarl.de-en/toy.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/toy.bpe.de || exit 1

test -s toy.bpe.fact.en || cat $MRT_DATA/europarl.de-en/toy.bpe.en | \
	sed 's/\(\s\|$\)/|s0 /g;s/@@|s0/|s1/g;s/\s*$//' > toy.bpe.fact.en
test -s toy.bpe.fact.de || cat $MRT_DATA/europarl.de-en/toy.bpe.en | \
	        sed 's/\(\s\|$\)/|s0 /g;s/@@|s0/|s1/g;s/\s*$//' > toy.bpe.fact.de

# Exit with success code
exit 0
