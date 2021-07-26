#!/usr/bin/env bash
set -e

delete_and_create_labels() {
    ./delete-labels.sh -o maple-labs -r $contract_name
    ./create-labels.sh -o maple-labs -r $contract_name
}

PATHS=~/code/maple-core/contracts/libraries/*

for path in $PATHS
do
    contract_name=${path:55}

    if [ "$contract_name" = "README.md" ] 
    then 
        continue
    fi

    delete_and_create_labels    

done

PATHS=~/code/maple-core/contracts/core/*

for path in $PATHS
do
    contract_name=${path:50}

    if [ "$contract_name" = "README.md" ] 
    then 
        continue
    fi

    delete_and_create_labels

done
