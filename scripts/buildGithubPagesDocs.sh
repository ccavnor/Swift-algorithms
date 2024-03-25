#!/bin/bash

# Called for help or missing args. The target must be one of the
# target names from the Swift Package Manager manifest.
usage() {
	echo "";
	echo "Usage: $0 [-t <Swift Package Manager target>]" 1>&2; 
	exit 1; 
}

# Get command line args
while getopts ":t:" o; do
    case "${o}" in
        t)
            t=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${t}" ]; then
    usage
fi

# Build docs via Swift-DocC plugin
pushd ../  # change to working directory (where allDocs was written to)
swift package \
    --allow-writing-to-directory ./docs \
   generate-documentation \
    --target "${t}" \
    --output-path ./docs \
    --emit-digest \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path 'Swift-algorithms'
popd
