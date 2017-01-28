#!/usr/bin/env bash

# https://github.com/krzysztofzablocki/Sourcery
SOURCERY_VER=0.5.3

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

# Download Sourcery if needed.
if [[ ! -x $DIR/sourcery/bin/sourcery ]]; then
    echo "Downloading sourcery-$SOURCERY_VER..."
    curl -L -O https://github.com/krzysztofzablocki/Sourcery/releases/download/$SOURCERY_VER/sourcery-$SOURCERY_VER.zip
    unzip sourcery-$SOURCERY_VER.zip -d $DIR/sourcery
    rm sourcery-$SOURCERY_VER.zip
fi

# Copy VTree code (temporarily) to source directory
# so that SourceKitten can find types.
mkdir -p "$SOURCE_DIR"/_VTreeGenerated
cp "$DIR"/../Sources/*.swift "$SOURCE_DIR"/_VTreeGenerated/

# Run Sourcery.
$DIR/sourcery/bin/sourcery "$SOURCE_DIR" "$DIR"/../Templates "$OUTPUT_DIR" --args "$ARG"

STATUS=$?

rm -rf "$SOURCE_DIR"/_VTreeGenerated

exit $STATUS
