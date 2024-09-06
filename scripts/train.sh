#!/bin/bash
CUDA_VISIBLE_DEVICES=0 python3 train.py \
    --model resnet50 \
    --data-dir ../datasets/mnist \
    --epochs 10 \
    -b 256 -vb 256 \
    --seed 42 -j 8