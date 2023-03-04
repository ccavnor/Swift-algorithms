#!/bin/bash

# This script just calls buildGithubPagesDocs.sh for each target

allTargets=('ValueBasedStack' 'BinarySearchTree' 'ValueBasedBinarySearchTree' 'IntervalTree' 'AVLTree' 'TreeProtocol')

pushd ../
# make a common docs folder named 'allDocs'
mkdir -p allDocs/documentation
mkdir -p allDocs/data/documentation
popd

for t in ${allTargets[@]};
do
    echo "Building documentation for target $t"
    # run the doc build script
    sh ./buildGithubPagesDocs.sh -t ${t}
    pushd ../
    # rename the docs directory, else it will be overwritten by next doc
    mv docs docs-${t}
    # extract the contents of data/documentation for current docs into allDocs/data/documentation
    cp -r docs-${t}/data/documentation allDocs/data
    # do the same for contents of documentation folder
    cp -r docs-${t}/documentation allDocs
    # rm the target specific directory as its no longer needed
    rm -rf docs-${t}
    popd
done

