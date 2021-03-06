#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf corpus_s2s corpus_s2s*.log
mkdir -p corpus_s2s

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 1111 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4 --type s2s"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


# Step 1: Train a model in one go, up to the update no. 70, and save training logs
$MRT_MARIAN/marian \
    -m corpus_s2s/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_s2s.log

test -e corpus_s2s/model_full.npz
test -e corpus_s2s.log

cat corpus_s2s.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_s2s.expected


# Step 2: Train a new model from scratch, but only to the update no. 40, and save the model
$MRT_MARIAN/marian \
    -m corpus_s2s/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 40 $extra_opts \
    --log corpus_s2s_1.log

test -e corpus_s2s/model.npz
test -e corpus_s2s_1.log

cat corpus_s2s_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_s2s_1.out
cp corpus_s2s/model.npz.yml corpus_s2s/model.npz.1.yml


# Step 3: Restart the training from step 2 and continue up to the update no. 70, and save training logs
$MRT_MARIAN/marian \
    -m corpus_s2s/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_s2s_2.log

test -e corpus_s2s/model.npz
test -e corpus_s2s_2.log


# Step 4: Combine training logs from steps 2 and 3 and compare them with logs from step 1
cat corpus_s2s_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_s2s_2.out
cat corpus_s2s_1.out corpus_s2s_2.out > corpus_s2s.out

$MRT_TOOLS/diff-nums.py corpus_s2s.out corpus_s2s.expected -p 0.1 -o corpus_s2s.diff


# Exit with success code
exit 0
