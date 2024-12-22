#!/bin/bash

cd $(dirname $0)/..

set -e

mkdir -p build
pushd build > /dev/null

echo "[*] preparing source..."
LIBSSH2_TAG=$(curl -s -L -o /dev/null -w "%{url_effective}\n" https://github.com/libssh2/libssh2/releases/latest | sed 's|.*/tag/\(.*\)$|\1|')
echo "[*] latest version: $LIBSSH2_TAG"

if [ -z "$LIBSSH2_TAG" ]; then
    echo "[!] Failed to fetch the latest tag from GitHub."
    exit 1
fi

TARGET_TAG=${LIBSSH2_TAG#libssh2-}  # 提取版本号部分，用于本地git标签匹配

popd > /dev/null # build
echo "[*] checking current tag"

git pull --tags > /dev/null
if [ $(git tag | grep -E "^$TARGET_TAG$" | wc -l) -gt 0 ]; then
    echo "[*] tag $TARGET_TAG already exists, skip building"
    exit 0
fi

pushd build > /dev/null

# 下载tar包
TAR_URL="https://libssh2.org/download/$LIBSSH2_TAG.tar.gz"
TAR_FILE="libssh2-$LIBSSH2_TAG.tar.gz"
curl -L -o $TAR_FILE $TAR_URL

# 解压tar包
tar -xzf $TAR_FILE
SOURCE_DIR=$(pwd)/libssh2-$TARGET_TAG

popd > /dev/null # build


echo "[*] generating source..."

PACKAGE_NAME="SwiftCSSH"

rm -rf Sources
mkdir -p Sources/$PACKAGE_NAME

TARGET_INCLUDE_DIR=$(pwd)/Sources/$PACKAGE_NAME/include
TARGET_SOURCE_DIR=$(pwd)/Sources/$PACKAGE_NAME

echo "[*] copying include..."
pushd $SOURCE_DIR/include > /dev/null
for FILE in $(find . -type f); do
    if [ ${FILE:0:2} == "./" ]; then
        FILE=${FILE:2}
    fi
    TARGET_PATH=$TARGET_INCLUDE_DIR/$FILE
    mkdir -p $(dirname $TARGET_PATH)
    cp $FILE $TARGET_PATH
done
popd > /dev/null # include

echo "[*] copying src..."
pushd $SOURCE_DIR/src > /dev/null
for FILE in $(find . -type f); do
    if [ ${FILE##*.} != "c" ] && [ ${FILE##*.} != "h" ]; then
        continue
    fi
    if [ ${FILE:0:2} == "./" ]; then
        FILE=${FILE:2}
    fi
    TARGET_PATH=$TARGET_SOURCE_DIR/$FILE
    mkdir -p $(dirname $TARGET_PATH)
    cp $FILE $TARGET_PATH
done
popd > /dev/null # src


echo $TARGET_TAG > tag.txt
echo "[*] done $(basename $0) : $TARGET_TAG"

cd "$(dirname "$0")"
cd ..

SCEHEME="SwiftCSSH"

function test_build() {
    DESTINATION=$1
    echo "[*] test build for $DESTINATION"
    xcodebuild -scheme $SCEHEME -destination "$DESTINATION" | xcbeautify
    EXIT_CODE=${PIPESTATUS[0]}
    echo "[*] finished with exit code $EXIT_CODE"
    if [ $EXIT_CODE -ne 0 ]; then
        echo "[!] failed to build for $DESTINATION"
        exit 1
    fi
}

function test_test() {
    DESTINATION=$1
    echo "[*] execute test for $DESTINATION"
    xcodebuild test -scheme $SCEHEME -destination "$DESTINATION" | xcbeautify
    EXIT_CODE=${PIPESTATUS[0]}
    echo "[*] finished with exit code $EXIT_CODE"
    if [ $EXIT_CODE -ne 0 ]; then
        echo "[!] failed to build for $DESTINATION"
        exit 1
    fi
}

# to reset all cache
# rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang/ModuleCache"
# rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang.$(whoami)/ModuleCache"
# rm -rf ~/Library/Developer/Xcode/DerivedData/*
# rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
# rm -rf ~/Library/Caches/org.swift.swiftpm
# rm -rf ~/Library/org.swift.swiftpm

test_build "generic/platform=macOS"
test_build "generic/platform=macOS,variant=Mac Catalyst"
test_build "generic/platform=iOS"
test_build "generic/platform=iOS Simulator"
test_build "generic/platform=tvOS"
test_build "generic/platform=tvOS Simulator"
test_build "generic/platform=watchOS"
test_build "generic/platform=watchOS Simulator"

test_test "platform=macOS"