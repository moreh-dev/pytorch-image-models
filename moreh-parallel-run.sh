#!/usr/bin/env bash

# Assume 5 SDAs are all available, take a list of models, evenly distribute
# them to 5 SDAs using `run_batch.sh`
NUM_SDA=5

# Require GNU parallel
[[ ! -x $(command -v parallel) ]] \
    && echo "Require GNU parallel. To install: sudo apt install parallel" \
    && exit 1

input_file=$1
[[ ! -f $input_file ]] && echo "Cannot find input file" && exit 1

tmp_dir=$(mktemp --directory)

num_models=$(wc -l $input_file | cut -d" " -f1)
[[ $num_models -lt $NUM_SDA ]] \
    && echo Too few models: ${num_models} on ${NUM_SDA} && exit 1

num_models_per_sda=$(((num_models + NUM_SDA - 1) / NUM_SDA))

split --lines=$num_models_per_sda $input_file ${tmp_dir}/timm.

parallel -j $NUM_SDA --link \
    env MOREH_VISIBLE_DEVICE={2} ./run_batch.sh {1} \
    ::: ${tmp_dir}/timm.* \
    ::: 0 1 2 3 4

rm -rf $tmp_dir

wait $(jobs -n)
[[ ! -z $(pgrep mlflow) ]] && pkill -f mlflow
