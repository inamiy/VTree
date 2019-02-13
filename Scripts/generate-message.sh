#!/usr/bin/env bash

CMD=`basename $0`

getopts "a:" OPTS
ARG=$OPTARG
shift $((OPTIND-1))

if [[ $# -ne 2 ]]; then
  echo "Usage: $CMD <source-dir> <code-generated-dir>" 1>&2
  exit 1
fi

DIR=`dirname $0`
SOURCE_DIR=$1
OUTPUT_DIR=$2

# Copy VTree code (temporarily) to source directory
# so that SourceKitten can find types.
mkdir -p "$SOURCE_DIR"/_VTreeGenerated
cp "$DIR"/../Sources/*.swift "$SOURCE_DIR"/_VTreeGenerated/

# Run Sourcery.
sourcery --sources "$SOURCE_DIR" --templates "$DIR"/../Templates --output "$OUTPUT_DIR" --args "$ARG"

STATUS=$?

rm -rf "$SOURCE_DIR"/_VTreeGenerated

exit $STATUS
