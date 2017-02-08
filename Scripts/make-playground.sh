#!/usr/bin/env bash

VTREE_ROOT="./"

for page in ./VTreePlayground.playground/Pages/*
do
    if [[ -d "$page"/Sources ]]; then
        $VTREE_ROOT/Scripts/generate-message.sh "$page"/Sources "$page"/Sources
    fi
done
