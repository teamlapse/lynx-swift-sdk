#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILDER_DIR="$SCRIPT_DIR/builder"
XCODE_WORKSPACE="$BUILDER_DIR/LynxFrameworkBuilder.xcworkspace"
OUTPUT_DIR="$SCRIPT_DIR/XCFrameworks"
STAMP_FILE="$OUTPUT_DIR/.build_stamp"
PODFILE="$BUILDER_DIR/Podfile"

FRAMEWORKS="Lynx LynxBase LynxServiceAPI PrimJS LynxService XElement LynxDevtool BaseDevtool DebugRouter SocketRocket ServalSVG"

# Check if rebuild needed
needs_rebuild() {
    # No xcframeworks yet
    [ ! -d "$OUTPUT_DIR/Lynx.xcframework" ] && return 0

    # No stamp file
    [ ! -f "$STAMP_FILE" ] && return 0

    # Podfile changed
    current_hash=$(shasum -a 256 "$PODFILE" | cut -d' ' -f1)
    stamp_hash=$(cat "$STAMP_FILE" 2>/dev/null || echo "")
    [ "$current_hash" != "$stamp_hash" ] && return 0

    return 1
}

if ! needs_rebuild; then
    echo "LynxJS XCFrameworks up to date (Podfile unchanged)"
    exit 0
fi

echo "Building LynxJS XCFrameworks..."

cd "$BUILDER_DIR"

# Always run pod install to ensure deps are current
echo "Running pod install..."
pod install

# Clean output
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Build for iOS Device
echo "Building for iOS..."
xcodebuild -workspace "$XCODE_WORKSPACE" -scheme Pods-LynxFrameworkBuilder \
    -configuration Release -destination "generic/platform=iOS" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES CODE_SIGNING_ALLOWED=NO build -quiet

# Build for iOS Simulator
echo "Building for Simulator..."
xcodebuild -workspace "$XCODE_WORKSPACE" -scheme Pods-LynxFrameworkBuilder \
    -configuration Release -destination "generic/platform=iOS Simulator" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES CODE_SIGNING_ALLOWED=NO build -quiet

# Find DerivedData path
DERIVED_DATA=$(xcodebuild -workspace "$XCODE_WORKSPACE" -scheme Pods-LynxFrameworkBuilder -showBuildSettings 2>/dev/null | grep -m1 BUILD_DIR | awk '{print $3}' | sed 's|/Build/Products||')

# Create XCFrameworks
echo "Creating XCFrameworks..."
for FW in $FRAMEWORKS; do
    IOS_FW="$DERIVED_DATA/Build/Products/Release-iphoneos/$FW/$FW.framework"
    SIM_FW="$DERIVED_DATA/Build/Products/Release-iphonesimulator/$FW/$FW.framework"

    if [ -d "$IOS_FW" ] && [ -d "$SIM_FW" ]; then
        xcodebuild -create-xcframework -framework "$IOS_FW" -framework "$SIM_FW" \
            -output "$OUTPUT_DIR/$FW.xcframework" 2>/dev/null
        echo "  $FW.xcframework"
    fi
done

# Copy resource bundles
cp -R "$DERIVED_DATA/Build/Products/Release-iphoneos/Lynx/LynxResources.bundle" "$OUTPUT_DIR/" 2>/dev/null || true
cp -R "$DERIVED_DATA/Build/Products/Release-iphoneos/BaseDevtool/LynxBaseDevToolResources.bundle" "$OUTPUT_DIR/" 2>/dev/null || true
cp -R "$DERIVED_DATA/Build/Products/Release-iphoneos/LynxDevtool/LynxDebugResources.bundle" "$OUTPUT_DIR/" 2>/dev/null || true

# Write stamp file
shasum -a 256 "$PODFILE" | cut -d' ' -f1 > "$STAMP_FILE"

echo ""
echo "Done! XCFrameworks at: $OUTPUT_DIR"
ls "$OUTPUT_DIR"
