#!/usr/bin/env bash

if [ "$6" = "macOS" ];
then
    echo "::debug::runner is macOS"
    if [ -d "$HOME/Library/Android/sdk/ndk/" ];
    then
        echo "::warning::Existing conflicting Android NDK found so deleting it"
        rm -rf "$HOME/Library/Android/sdk/ndk/"
    fi
    if [ -d "$HOME/Library/Android/sdk/ndk-bundle/" ];
    then
        echo "::warning::Existing conflicting Android NDK bundle found so deleting it"
        rm -rf "$HOME/Library/Android/sdk/ndk-bundle/"
    fi
fi

if ! command -v realpath &> /dev/null
then
    echo "::warning::realpath command could not be found, so installing it"
    if ! command -v brew &> /dev/null
    then
        echo "::error::brew command could not be found, so aborting"
        exit 1
    fi
    brew install coreutils
else
    echo "::debug::Found realpath to already be installed, yay!"
fi
if ! command -v yq &> /dev/null
then
    echo "::warning::yq command could not be found, so installing it"
    if ! command -v brew &> /dev/null
    then
        echo "::error::brew command could not be found, so aborting"
        exit 1
    fi
    brew install yq
else
    echo "::debug::Found yq to already be installed, yay!"
fi
if ! command -v renutil &> /dev/null
then
    echo "::warning::renutil command could not be found, so installing it"
    if ! command -v pip3 &> /dev/null
    then
        echo "::error::pip3 command could not be found, so aborting"
        exit 1
    fi
    pip3 install renutil
else
    echo "::debug::Found renutil to already be installed, yay!"
fi
if ! command -v renconstruct &> /dev/null
then
    echo "::warning::renconstruct command could not be found, so installing it"
    if ! command -v pip3 &> /dev/null
    then
        echo "::error::pip3 command could not be found, so aborting"
        exit 1
    fi
    pip3 install renconstruct
else
    echo "::debug::Found renconstruct to already be installed, yay!"
fi

BUILD_FOLDER_NAME="build"
echo "::debug::\$BUILD_FOLDER_NAME: $BUILD_FOLDER_NAME"
DIST_FOLDER_NAME="renpy"
echo "::debug::\$DIST_FOLDER_NAME: $DIST_FOLDER_NAME"
CODE_FULL_PATH="$GITHUB_WORKSPACE"
echo "::debug::\$CODE_FULL_PATH: $CODE_FULL_PATH"
CONFIG_FULL_PATH="$CODE_FULL_PATH/$1"
echo "::debug::\$CONFIG_FULL_PATH: $CONFIG_FULL_PATH"
ANDROID_JSON_FULL_PATH="$CODE_FULL_PATH/$2"
echo "::debug::\$ANDROID_JSON_FULL_PATH: $ANDROID_JSON_FULL_PATH"
FULL_BUILD_PATH="$3/$BUILD_FOLDER_NAME"
echo "::debug::\$FULL_BUILD_PATH: $FULL_BUILD_PATH"
FULL_DIST_PATH="$3/$DIST_FOLDER_NAME"
echo "::debug::\$FULL_DIST_PATH: $FULL_DIST_PATH"
REAL_FULL_BUILD_PATH=$(realpath -s "$FULL_BUILD_PATH")
echo "::debug::\$REAL_FULL_BUILD_PATH: $REAL_FULL_BUILD_PATH"
REAL_FULL_DIST_PATH=$(realpath -s "$FULL_DIST_PATH")
echo "::debug::\$REAL_FULL_DIST_PATH: $REAL_FULL_DIST_PATH"
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
echo "::debug::\$REPO_NAME: $REPO_NAME"
PUBLIC_DIST_PATH="$3/$DIST_FOLDER_NAME"
echo "::debug::\$PUBLIC_DIST_PATH: $PUBLIC_DIST_PATH"
PUBLIC_ACTION_WORKFLOW_PATH="$GITHUB_ACTION_PATH"
echo "::debug::\$PUBLIC_ACTION_WORKFLOW_PATH: $PUBLIC_ACTION_WORKFLOW_PATH"
PUBLIC_ACTION_WORKFLOW_DIST_PATH="$PUBLIC_ACTION_WORKFLOW_PATH/$DIST_FOLDER_NAME"
echo "::debug::\$PUBLIC_ACTION_WORKFLOW_DIST_PATH: $PUBLIC_ACTION_WORKFLOW_DIST_PATH"

mkdir -p "$REAL_FULL_DIST_PATH"

echo ::set-output name=local-dir::"$PUBLIC_DIST_PATH"
echo ::set-output name=dist-folder::"$DIST_FOLDER_NAME"
echo ::set-output name=action-dir::"$PUBLIC_ACTION_WORKFLOW_DIST_PATH"

SDK_VERSION=$(yq eval '.renutil.version' "$CONFIG_FULL_PATH")
echo ::set-output name=sdk-version::"$SDK_VERSION"
echo "::debug::\$SDK_VERSION: $SDK_VERSION"

ANDROID_BUILD_ENABLED=$(yq eval '.build.android' "$CONFIG_FULL_PATH")
echo "::debug::\$ANDROID_BUILD_ENABLED: $ANDROID_BUILD_ENABLED"

GAME_VERSION=$(grep -ERoh --include "*.rpy" "define\s+config.version\s+=\s+\".+\"" . | cut -d '"' -f 2)
echo ::set-output name=version::"$GAME_VERSION"
echo "::debug::\$GAME_VERSION: $GAME_VERSION"

BUILD_NAME=$(grep -ERoh --include "*.rpy" "define\s+build.name\s+=\s+\".+\"" . | cut -d '"' -f 2)
echo ::set-output name=build-name::"$BUILD_NAME"
echo "::debug::\$BUILD_NAME: $BUILD_NAME"

NUMERIC_GAME_VERSION="${GAME_VERSION//[!0-9]/}"
echo ::set-output name=android-numeric-game-version::"$NUMERIC_GAME_VERSION"
echo "::debug::\$NUMERIC_GAME_VERSION: $NUMERIC_GAME_VERSION"

if [ "$5" = "true" ] && [ "$ANDROID_BUILD_ENABLED" = "true" ];
then
    if [ ! -f "$ANDROID_JSON_FULL_PATH" ]; 
    then
        echo "::error::Android configuration json not found but android build is enabled. Try creating an android configuration json file through building an android distribution locally within the renpy launcher first and checking that android config file into the repo."
        exit 1
    else
        echo "Android configuration json found. Changing Android configuration json version information to match."
        mv "$ANDROID_JSON_FULL_PATH" "$ANDROID_JSON_FULL_PATH".bak
        # Update Android version config json to match game version
        jq -c --arg ver "$GAME_VERSION" --arg nver "$NUMERIC_GAME_VERSION" '.numeric_version = $nver | . | .version = $ver | .' "$ANDROID_JSON_FULL_PATH".bak > "$ANDROID_JSON_FULL_PATH"

        ANDROID_PACKAGE_NAME=$(jq -r '.package' "$ANDROID_JSON_FULL_PATH")
    fi
else
    echo "Android build not enabled within renConstruct config file."
fi

echo ::set-output name=android-package::"$ANDROID_PACKAGE_NAME"

mkdir -p "$REAL_FULL_BUILD_PATH"

# Execute renConstruct from within the build directory
cd "$REAL_FULL_BUILD_PATH" || exit 1

# echo "SIMULATION: runningRenconstructWithArgs -d -i \"$CODE_FULL_PATH\" -o \"$REAL_FULL_DIST_PATH\" -c \"$CONFIG_FULL_PATH\""

if renconstruct -d -i "$CODE_FULL_PATH" -o "$REAL_FULL_DIST_PATH" -c "$CONFIG_FULL_PATH";
then
    echo "::debug::renconstruct was successful!"
else
    echo "::error::renconstruct was NOT successful"
    exit 1
fi

REAL_FULL_DIST_PATH_LIST="$(ls -al "$REAL_FULL_DIST_PATH")"
echo "::debug::\$REAL_FULL_DIST_PATH_LIST: $REAL_FULL_DIST_PATH_LIST"
