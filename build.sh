#!/usr/bin/env bash

CODE_FULL_PATH="$GITHUB_WORKSPACE"
echo "::debug::\$CODE_FULL_PATH: $CODE_FULL_PATH"
CONFIG_FULL_PATH="$CODE_FULL_PATH/$2"
echo "::debug::\$CONFIG_FULL_PATH: $CONFIG_FULL_PATH"
ANDROID_JSON_FULL_PATH="$CODE_FULL_PATH/$3"
echo "::debug::\$ANDROID_JSON_FULL_PATH: $ANDROID_JSON_FULL_PATH"
mkdir ../dist

if [ "$1" = "." ] 
then
    echo "game directory is at the root of the repo"
else
    echo "game directory is inside a sub directory of the repo"
fi

SDK_VERSION=$(yq read "$CONFIG_FULL_PATH" '.renutil.version')
echo ::set-output name=sdk-version::"$SDK_VERSION"

GAME_VERSION=$(grep -ERoh --include "*.rpy" "define\s+config.version\s+=\s+\".+\"" . | cut -d '"' -f 2)
echo ::set-output name=version::"$GAME_VERSION"

BUILD_NAME=$(grep -ERoh --include "*.rpy" "define\s+build.name\s+=\s+\".+\"" . | cut -d '"' -f 2)
echo ::set-output name=build-name::"$BUILD_NAME"

NUMERIC_GAME_VERSION="${GAME_VERSION//[\!0-9]/}"
echo ::set-output name=android-numeric-game-version::"$NUMERIC_GAME_VERSION"

# Update Android version config json to match game version
jq -c --arg ver "$GAME_VERSION" --arg nver "$NUMERIC_GAME_VERSION" '.numeric_version = $nver | . | .version = $ver | .' "$ANDROID_JSON_FULL_PATH" >| "$ANDROID_JSON_FULL_PATH"

ANDROID_PACKAGE_NAME=$(jq '.package' "$ANDROID_JSON_FULL_PATH")
echo ::set-output name=android-package::"$ANDROID_PACKAGE_NAME"

if [ "$(ls -A ../build)" ]; then
    echo "Cached copy of sdk found. No additional downloading will be required."
else
    echo "Build directory not found, renConstruct will download the SDK."
    mkdir ../build
fi

FULL_DIST_PATH=$(realpath "$GITHUB_WORKSPACE/../dist")
echo ::set-output name=dir::"$FULL_DIST_PATH"

# Execute renConstruct from within the build directory
cd ../build || exit 1
renconstruct -d -i "$CODE_FULL_PATH" -o ../dist -c "$CONFIG_FULL_PATH"
