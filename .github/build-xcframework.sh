#!/bin/bash
# CREDIT: https://forums.swift.org/t/how-to-build-swift-package-as-xcframework/41414/4
# NOTE: This does modify the Package.swift file, which is less than ideal. 
set -x
set -e

# Pass scheme name as the first argument to the script
NAME=$1

# Build the scheme for all platforms that we plan to support
for PLATFORM in "${@:2}"; do

    case $PLATFORM in
    "iOS")
    RELEASE_FOLDER="Release-iphoneos"
    ;;
    "iOS Simulator")
    RELEASE_FOLDER="Release-iphonesimulator"
    ;;
    "WatchOS")
    RELEASE_FOLDER="Release-watchos"
    ;;
    "WatchOS Simulator")
    RELEASE_FOLDER="Release-watchossimulator"
    ;;
    "TvOS")
    RELEASE_FOLDER="Release-tvos"
    ;;
    "TvOS Simulator")
    RELEASE_FOLDER="Release-tvossimulator"
    ;;
    "macOS")
    RELEASE_FOLDER="Release-macos"
    ;;
    esac

    ARCHIVE_PATH=$RELEASE_FOLDER

    # Rewrite Package.swift so that it declares dynamic libraries, since the approach does not work with static libraries
    perl -i -p0e 's/type: .static,//g' Package.swift
    perl -i -p0e 's/type: .dynamic,//g' Package.swift
    perl -i -p0e 's/BETA_//g' Package.swift
    perl -i -p0e 's/(library[^,]*,)/$1 type: .dynamic,/g' Package.swift

    xcodebuild archive -workspace . -scheme $NAME \
            -destination "generic/platform=$PLATFORM" \
            -archivePath $ARCHIVE_PATH \
            -derivedDataPath ".build" \
            SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    FRAMEWORK_PATH="$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$NAME.framework"
    MODULES_PATH="$FRAMEWORK_PATH/Modules"
    mkdir -p $MODULES_PATH

    BUILD_PRODUCTS_PATH=".build/Build/Intermediates.noindex/ArchiveIntermediates/$NAME/BuildProductsPath"
    RELEASE_PATH="$BUILD_PRODUCTS_PATH/$RELEASE_FOLDER"
    SWIFT_MODULE_PATH="$RELEASE_PATH/$NAME.swiftmodule"
    RESOURCES_BUNDLE_PATH="$RELEASE_PATH/${NAME}_${NAME}.bundle"

    # Copy Swift modules
    if [ -d $SWIFT_MODULE_PATH ] 
    then
        cp -r $SWIFT_MODULE_PATH $MODULES_PATH
    else
        # In case there are no modules, assume C/ObjC library and create module map
        echo "module $NAME { export * }" > $MODULES_PATH/module.modulemap
        # TODO: Copy headers
    fi

    # Copy resources bundle, if exists 
    if [ -e $RESOURCES_BUNDLE_PATH ] 
    then
        cp -r $RESOURCES_BUNDLE_PATH $FRAMEWORK_PATH
    fi

    framework_builder="${framework_builder} -framework ${RELEASE_FOLDER}.xcarchive/Products/usr/local/lib/${NAME}.framework"
done

cmd="xcodebuild -create-xcframework ${framework_builder} -output ${NAME}.xcframework"

eval $cmd
