#!/usr/bin/env bash

CODE_FULL_PATH="$GITHUB_WORKSPACE"
CONFIG_FULL_PATH="$CODE_FULL_PATH/$2"

if [ "$1" = "." ] 
then
    echo "game directory is at the root of the repo"
else
    echo "game directory is inside a sub directory of the repo"
    CODE_FULL_PATH="$GITHUB_WORKSPACE/$1"
    CONFIG_FULL_PATH="$CODE_FULL_PATH/$2"
fi
SDK_VERSION=$(yq '.renutil.version' "$CONFIG_FULL_PATH")
echo ::set-output name=version::"$SDK_VERSION"

if [ "$(ls -A ../build)" ]; then
    echo "Cached copy of sdk found. No additional downloading will be required."
else
    echo "Build directory not found, renConstruct will download the SDK."
    mkdir ../build
    mkdir ../dist
fi

FULL_DIST_PATH=$(realpath "$GITHUB_WORKSPACE/../dist")
echo ::set-output name=dir::"$FULL_DIST_PATH"

# Execute renConstruct from within the build directory
cd ../build || exit 1
renconstruct -d -i "$CODE_FULL_PATH" -o ../dist -c "$CONFIG_FULL_PATH"
