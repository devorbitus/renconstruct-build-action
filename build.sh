#!/usr/bin/env bash

if [ "$6" = "macOS" ];
then
    echo "::debug::runner is macOS"
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
FULL_BUILD_PATH="$GITHUB_WORKSPACE/../$BUILD_FOLDER_NAME"
echo "::debug::\$FULL_BUILD_PATH: $FULL_BUILD_PATH"
FULL_DIST_PATH="$GITHUB_ACTION_PATH/$DIST_FOLDER_NAME"
echo "::debug::\$FULL_DIST_PATH: $FULL_DIST_PATH"
REAL_FULL_BUILD_PATH=$(realpath -s "$FULL_BUILD_PATH")
echo "::debug::\$REAL_FULL_BUILD_PATH: $REAL_FULL_BUILD_PATH"
REAL_FULL_DIST_PATH=$(realpath -s "$FULL_DIST_PATH")
echo "::debug::\$REAL_FULL_DIST_PATH: $REAL_FULL_DIST_PATH"
REPO_NAME=$(basename "$GITHUB_REPOSITORY")
echo "::debug::\$REPO_NAME: $REPO_NAME"
PUBLIC_DIST_PATH="$3/$DIST_FOLDER_NAME"
echo "::debug::\$PUBLIC_DIST_PATH: $PUBLIC_DIST_PATH"
PUBLIC_ACTION_WORKFLOW_PATH="$4"
echo "::debug::\$PUBLIC_ACTION_WORKFLOW_PATH: $PUBLIC_ACTION_WORKFLOW_PATH"
PUBLIC_ACTION_WORKFLOW_DIST_PATH="$PUBLIC_ACTION_WORKFLOW_PATH/$DIST_FOLDER_NAME"
echo "::debug::\$PUBLIC_ACTION_WORKFLOW_DIST_PATH: $PUBLIC_ACTION_WORKFLOW_DIST_PATH"

mkdir -p "$REAL_FULL_DIST_PATH"

echo "$PUBLIC_DIST_PATH" >| "$GITHUB_ACTION_PATH/.local-dir"
echo "$PUBLIC_ACTION_WORKFLOW_DIST_PATH" >| "$GITHUB_ACTION_PATH/.action-dir"

SDK_VERSION=$(yq read "$CONFIG_FULL_PATH" 'renutil.version')
echo "::debug::\$SDK_VERSION: $SDK_VERSION"
echo "$SDK_VERSION" >| "$GITHUB_ACTION_PATH/.sdk-version"

ANDROID_BUILD_ENABLED=$(yq read "$CONFIG_FULL_PATH" 'build.android')
echo "::debug::\$ANDROID_BUILD_ENABLED: $ANDROID_BUILD_ENABLED"

GAME_VERSION=$(grep -ERoh --include "*.rpy" "define\s+config.version\s+=\s+\".+\"" . | cut -d '"' -f 2)
echo "::debug::\$GAME_VERSION: $GAME_VERSION"
echo "$GAME_VERSION" >| "$GITHUB_ACTION_PATH/.version"

BUILD_NAME=$(grep -ERoh --include "*.rpy" "define\s+build.name\s+=\s+\".+\"" . | cut -d '"' -f 2)
echo "::debug::\$BUILD_NAME: $BUILD_NAME"
echo "$BUILD_NAME" >| "$GITHUB_ACTION_PATH/.build-name"

NUMERIC_GAME_VERSION="${GAME_VERSION//[!0-9]/}"
echo "::debug::\$NUMERIC_GAME_VERSION: $NUMERIC_GAME_VERSION"
echo "$NUMERIC_GAME_VERSION" >| "$GITHUB_ACTION_PATH/.android-numeric-game-version"

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

echo "::debug::\$ANDROID_PACKAGE_NAME: $ANDROID_PACKAGE_NAME"
echo "$ANDROID_PACKAGE_NAME" >| "$GITHUB_ACTION_PATH/.android-package"

if [ "$(ls -A "$REAL_FULL_BUILD_PATH")" ]; then
    echo "Cached copy of sdk found. No additional downloading will be required."
else
    echo "Build directory not found, renConstruct will download the SDK."
    mkdir -p "$REAL_FULL_BUILD_PATH"
fi

# Execute renConstruct from within the build directory
cd "$REAL_FULL_BUILD_PATH" || exit 1
#renconstruct -d -i "$CODE_FULL_PATH" -o "$REAL_FULL_DIST_PATH" -c "$CONFIG_FULL_PATH"
echo "SIMULATION: runningRenconstructWithArgs -d -i \"$CODE_FULL_PATH\" -o \"$REAL_FULL_DIST_PATH\" -c \"$CONFIG_FULL_PATH\""

REAL_FULL_DIST_PATH_LIST="$(ls -al "$REAL_FULL_DIST_PATH")"
echo "::debug::\$REAL_FULL_DIST_PATH_LIST: $REAL_FULL_DIST_PATH_LIST"
