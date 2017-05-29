#!/bin/bash
# Merge Script

# 1
# Set bash script to exit immediately if any commands fail.
set -e

# 2
# Setup some constants for use later on.
FRAMEWORK_NAME="Kingfisher"
FRAMEWORK_BUILD_DIR=$PWD/out
UNIVERSAL_FRAMEWORK_DIR=$PWD/universal
# 3
# If remnants from a previous build exist, delete them.
if [ -d "${FRAMEWORK_BUILD_DIR}" ]; then
rm -rf "${FRAMEWORK_BUILD_DIR}"
fi

mkdir "${FRAMEWORK_BUILD_DIR}"

if [ -d "${UNIVERSAL_FRAMEWORK_DIR}" ]; then
    rm -rf "${UNIVERSAL_FRAMEWORK_DIR}"
fi

mkdir "${UNIVERSAL_FRAMEWORK_DIR}"

# 4
# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild -workspace "${FRAMEWORK_NAME}.xcworkspace" -scheme "${FRAMEWORK_NAME}" BUILD_DIR="out" BUILD_ROOT="${PWD}" -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos" clean build
xcodebuild  -workspace "${FRAMEWORK_NAME}.xcworkspace" -scheme "${FRAMEWORK_NAME}" BUILD_DIR="out" BUILD_ROOT="${PWD}" -configuration Release -arch x86_64 -arch i386 only_active_arch=no defines_module=yes -sdk "iphonesimulator" clean build

# 5
# Remove .framework file if exists on Desktop from previous run.
if [ -d "${HOME}/Desktop/${FRAMEWORK_NAME}.framework" ]; then
rm -rf "${HOME}/Desktop/${FRAMEWORK_NAME}.framework"
fi
# 6
# Copy the device version of framework to Desktop.
cp -r "${FRAMEWORK_BUILD_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework" "${UNIVERSAL_FRAMEWORK_DIR}/${FRAMEWORK_NAME}.framework"
cp -r "${FRAMEWORK_BUILD_DIR}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/" "${UNIVERSAL_FRAMEWORK_DIR}/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/"
# 7
# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.
lipo -create -output "${UNIVERSAL_FRAMEWORK_DIR}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "${FRAMEWORK_BUILD_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "${FRAMEWORK_BUILD_DIR}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

# 8
# Copy the Swift module mappings for the simulator into the
# framework.  The device mappings already exist from step 6.
#cp -r "${SRCROOT}/build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/" "${HOME}/Desktop/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"

# 9
# Delete the most recent build.
if [ -d "${SRCROOT}/build" ]; then
rm -rf "${SRCROOT}/build"
fi
