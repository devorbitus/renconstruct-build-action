# renconstruct-build-action
Github Action to utilize renConstruct to build Mac/PC/Linux and Android distributions of a VN project

## Table of Contents
<!-- TOC -->
- [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Inputs](#inputs)
    - [Required Input](#required-input)
        - [Config file](#config-file)
    - [Optional Inputs](#optional-inputs)
        - [Android Config file](#android-config-file)
        - [Shared Mount Path](#shared-mount-path)
        - [Action Shared Mount Path](#action-shared-mount-path)
        - [Android Auto Upgrade Version](#android-auto-upgrade-version)
- [Output](#output)
    - [Local Dir](#local-dir)
    - [Action Dir](#action-dir)
    - [Version](#version)
    - [Android Numeric Game Version](#android-numeric-game-version)
    - [SDK Version](#sdk-version)
    - [Android Package](#android-package)
    - [Build Name](#build-name)
- [Advanced Usage](#advanced-usage)
    - [Caching SDK download](#caching-sdk-download)
    - [Caching SDK AND Upload distributions to Mega AND Itch.io](#caching-sdk-and-upload-distributions-to-mega-and-itchio)
<!-- /TOC -->

## Usage
Build for mac and/or pc/linux only and NOT android
```yml
  - name: Build VN Project New
    uses: devorbitus/renconstruct-build-action@main
    id: buildStep
    with:
        config-file: 'config.yml'
```
Build for mac and/or pc/linux only AND android
```yml
  - name: Build VN Project New
    uses: devorbitus/renconstruct-build-action@main
    id: buildStep
    with:
        config-file: 'config.yml'
        android-config-file: '.android.json'
    env:
        RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
```
Looking up your existing keystore file and getting the base64 encoded string representation of that file stored as a GitHub secret can be done using a site [like this](https://base64.guru/converter/encode/file) and instructions for creating a Github secret can be [found here](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository).

The keystore file can be found within the Ren'Py SDK `rapt` directory in a file called `android.keystore`, you can use that file to get the base64 string representation.

## Inputs

### Required Input

#### Config file

```yml
    id: buildStep
    with:
        config-file: 'config.yml'
```

The path to the renConstruct config file relative to the root of the project

### Optional Inputs

#### Android Config file

```yml
    id: buildStep
    with:
        config-file: 'config.yml'
        android-config-file: '.android.json'
```

The path to the android config JSON file relative to the root of the project

#### Shared Mount Path

```yml
    id: buildStep
    with:
        config-file: 'config.yml'
        android-config-file: '.android.json'
        shared-mount-path: '/home/runner/work/_temp/_github_workflow'
```

This path is undocumented, so placing it here in case it needs to be changed in the future without a code change to the action

#### Action Shared Mount Path

```yml
    id: buildStep
    with:
        config-file: 'config.yml'
        android-config-file: '.android.json'
        shared-mount-path: '/home/runner/work/_temp/_github_workflow'
        action-shared-mount-path: '/github/workflow'
```

This path is undocumented, so placing it here in case it needs to be changed in the future without a code change to the action that container-based actions will have access to as actions mounts the host directory into the container.

#### Android Auto Upgrade Version

```yml
    id: buildStep
    with:
        config-file: 'config.yml'
        android-config-file: '.android.json'
        shared-mount-path: '/home/runner/work/_temp/_github_workflow'
        action-shared-mount-path: '/github/workflow'
        android-auto-upgrade-version: 'true'
```

Change this default to anything other than `true`, and it won't auto-increment the version within the android config JSON file

## Output

### Local Dir

```yml
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@v1.0.0
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      # ... maybe other steps
      - name: List Built Distributions
        run: ls -al ${{ steps.buildStep.outputs.local-dir }}
```

The directory where the distributed files exist

### Action Dir

```yml
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@v1.0.0
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      # ... maybe other steps
      - name: Upload to Mega
        id: uploadMega
        uses: Difegue/action-megacmd@master
        with:
          args: put ${{ format('{0}/{1}-{2}-mac.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }} /path/to/my-mega-dist-folder/
```

The directory where the distributed files exist that another container-based GitHub action can access

### Version

```yml
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@v1.0.0
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      # ... maybe other steps
      - name: Upload to Mega
        id: uploadMega
        uses: Difegue/action-megacmd@1.1.0
        with:
          args: put ${{ format('{0}/{1}-{2}-mac.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }} /path/to/my-mega-dist-folder/
```

The built version of the desktop project (config.version)

### Android Numeric Game Version

```yml
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@v1.0.0
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      # ... maybe other steps
      - name: Upload to Mega
        id: uploadMega
        uses: Difegue/action-megacmd@1.1.0
        with:
          args: put ${{ format('{0}/{1}-{2}-universal-release.apk', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.android-package, steps.buildStep.outputs.android-numeric-game-version) }} /path/to/my-mega-dist-folder/
```

The numeric android version of the built version

### SDK Version

```yml
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@v1.0.0
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      # ... maybe other steps
      - name: Upload to Mega
        id: uploadMega
        uses: Difegue/action-megacmd@1.1.0
        with:
          # adding the -c makes mega create the folder for the version if it doesn't exist
          args: put -c ${{ format('{0}/{1}-{2}-mac.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }} /path/to/my-mega-dist-folder/sdk/${{ steps.buildStep.outputs.sdk-version }}/gameVersion/${{ steps.buildStep.outputs.version }}/
```

The SDK version used (pulled from the config.yml of renConstruct)

### Android Package

```yml
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@v1.0.0
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      # ... maybe other steps
      - name: Upload to Mega
        id: uploadMega
        uses: Difegue/action-megacmd@1.1.0
        with:
          args: put ${{ format('{0}/{1}-{2}-universal-release.apk', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.android-package, steps.buildStep.outputs.android-numeric-game-version) }} /path/to/my-mega-dist-folder/
```

The package name inside the configured .android.json file

### Build Name

```yml
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@v1.0.0
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      # ... maybe other steps
      - name: Upload to Mega
        id: uploadMega
        uses: Difegue/action-megacmd@1.1.0
        with:
          args: put ${{ format('{0}/{1}-{2}-mac.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }} /path/to/my-mega-dist-folder/
```

The official build name from the desktop project (build.name)

## Advanced Usage

Be sure to set the required secrets within GitHub before triggering any releases

### Caching SDK download

We are utilizing the [GitHub Cache Action](https://github.com/actions/cache) to cache the SDK download. We want the required renConstruct configuration to be the only place we store the SDK version to build, so we are using the [yq action output](https://github.com/devorbitus/yq-action-output) to pull the config file location inside the workflow file (itself). We then go lookup the SDK version from the renConstruct config file and expose it to downstream steps.

Contents of an example release workflow found at `.github/workflows/release-action.yml` :
```yml
name: Release Workflow

on:
  release:
    types: [created]

jobs:
  build:
    name: Build Automation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Get SDK Version from config
        id: lookupSdkVersion
        uses: devorbitus/yq-action-output@v1.0
        with:
          cmd: yq eval '.renutil.version' $(yq eval '.jobs.build.steps[] | select(.id == "buildStep") | .with.config-file' .github/workflows/release-action.yml)
      - name: show yq result
        run: echo Result is ${{ steps.lookupSdkVersion.outputs.result }}
      - name: Restore Cache
        id: restore-cache
        uses: actions/cache@v2
        with:
          path: ../build
          key:  ${{ runner.os }}-sdk-${{ steps.lookupSdkVersion.outputs.result }}
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@main
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      - name: Cache SDK
        id: save-cache
        if: steps.restore-cache.outputs.cache-hit != 'true'
        uses: actions/cache@v2
        with:
          path: ../build
          key:  ${{ runner.os }}-sdk-${{ steps.lookupSdkVersion.outputs.result }}
```

### Caching SDK AND Upload distributions to Mega AND Itch.io

Actions used:
- [GitHub Cache Action](https://github.com/actions/cache)
- [yq action output](https://github.com/devorbitus/yq-action-output)
- [GitHub Action for MEGA](https://github.com/Difegue/action-megacmd)
- [Butler Push (itch.io upload)](https://github.com/josephbmanley/butler-publish-itchio-action)

Contents of an example release workflow found at `.github/workflows/release-action.yml` :
```yml
name: Release Workflow

on:
  release:
    types: [created]

jobs:
  build:
    name: Build Automation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Get SDK Version from config
        id: lookupSdkVersion
        uses: devorbitus/yq-action-output@v1.0
        with:
          cmd: yq eval '.renutil.version' $(yq eval '.jobs.build.steps[] | select(.id == "buildStep") | .with.config-file' .github/workflows/release-action.yml)
      - name: show yq result
        run: echo Result is ${{ steps.lookupSdkVersion.outputs.result }}
      - name: Restore Cache
        id: restore-cache
        uses: actions/cache@v2
        with:
          path: ../build
          key:  ${{ runner.os }}-sdk-${{ steps.lookupSdkVersion.outputs.result }}
      - name: Build VN Project New
        uses: devorbitus/renconstruct-build-action@main
        id: buildStep
        with:
          config-file: 'config.yml'
          android-config-file: '.android.json'
        env:
          RC_KEYSTORE: ${{ secrets.BASE64_ANDROID_KEYSTORE }}
      - name: Cache SDK
        id: save-cache
        if: steps.restore-cache.outputs.cache-hit != 'true'
        uses: actions/cache@v2
        with:
          path: ../build
          key:  ${{ runner.os }}-sdk-${{ steps.lookupSdkVersion.outputs.result }}
      - name: List Built Distributions
        run: ls -al ${{ steps.buildStep.outputs.local-dir }}
      - name: Upload to Mega
        id: uploadMega
        uses: Difegue/action-megacmd@1.1.0
        with:
          args: put ${{ format('{0}/{1}-{2}-mac.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }} ${{ format('{0}/{1}-{2}-pc.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }} ${{ format('{0}/{1}-{2}-universal-release.apk', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.android-package, steps.buildStep.outputs.android-numeric-game-version) }} /path/to/my-mega-dist-folder/
        env:
          USERNAME: ${{ secrets.MEGA_USERNAME }}
          PASSWORD: ${{ secrets.MEGA_PASSWORD }}
      - name: Upload to itch.io for PC
        id: uploadItchPC
        uses: josephbmanley/butler-publish-itchio-action@v1.0.2
        env:
          BUTLER_CREDENTIALS: ${{ secrets.BUTLER_CREDENTIALS }}
          CHANNEL: windows
          ITCH_GAME: my-itch-game # change me
          ITCH_USER: my-itch-user-account # change me
          PACKAGE: ${{ format('{0}/{1}-{2}-pc.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }}
          VERSION: ${{ steps.buildStep.outputs.version }}
      - name: Upload to itch.io for Mac
        id: uploadItchMac
        uses: josephbmanley/butler-publish-itchio-action@v1.0.2
        env:
          BUTLER_CREDENTIALS: ${{ secrets.BUTLER_CREDENTIALS }}
          CHANNEL: mac
          ITCH_GAME: my-itch-game # change me
          ITCH_USER: my-itch-user-account # change me
          PACKAGE: ${{ format('{0}/{1}-{2}-mac.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }}
          VERSION: ${{ steps.buildStep.outputs.version }}
      - name: Upload to itch.io for Linux
        id: uploadItchLinux
        uses: josephbmanley/butler-publish-itchio-action@v1.0.2
        env:
          BUTLER_CREDENTIALS: ${{ secrets.BUTLER_CREDENTIALS }}
          CHANNEL: linux
          ITCH_GAME: my-itch-game # change me
          ITCH_USER: my-itch-user-account # change me
          PACKAGE: ${{ format('{0}/{1}-{2}-pc.zip', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.build-name, steps.buildStep.outputs.version) }}
          VERSION: ${{ steps.buildStep.outputs.version }}
      - name: Upload to itch.io for Android
        id: uploadItchAndroid
        uses: josephbmanley/butler-publish-itchio-action@v1.0.2
        env:
          BUTLER_CREDENTIALS: ${{ secrets.BUTLER_CREDENTIALS }}
          CHANNEL: android
          ITCH_GAME: my-itch-game # change me
          ITCH_USER: my-itch-user-account # change me
          PACKAGE: ${{ format('{0}/{1}-{2}-universal-release.apk', steps.buildStep.outputs.action-dir, steps.buildStep.outputs.android-package, steps.buildStep.outputs.android-numeric-game-version) }}
          VERSION: ${{ steps.buildStep.outputs.version }}
```
