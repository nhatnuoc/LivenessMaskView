#!/bin/bash

# Define paths
FRAMEWORKNAME='LivenessMask' # Use this as dynamic name..

XCFRAMEWORK_DIR='./build/LivenessMaskView.xcframework'
ZIP_FOLDER='./build'
ZIP_PATH='LivenessMask.zip'

GIT_REPO_PATH='../liveness-mask-view-pod' # Update this to your Git repository path
PODSPEC_FILE="$GIT_REPO_PATH/LivenessMaskView.podspec"
GITHUB_REPO='nhatnuoc/liveness-mask-view-pod' # Update with your actual GitHub repo name

# Step 1: Remove previous build
rm -rf './build/'

# Step 2: Build for iOS device
xcodebuild archive \
-workspace LivenessMask.xcworkspace \
-scheme LivenessMask \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/LivenessMaskView.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# Step 3: Build for iOS simulator
xcodebuild archive \
-workspace LivenessMask.xcworkspace \
-scheme LivenessMask \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/LivenessMaskView.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# Step 4: Create the XCFramework
xcodebuild -create-xcframework \
-framework './build/LivenessMaskView.framework-iphoneos.xcarchive/Products/Library/Frameworks/LivenessMask.framework' \
-framework './build/LivenessMaskView.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/LivenessMask.framework' \
-output "$XCFRAMEWORK_DIR"

find . -name "*.swiftinterface" -exec sed -i -e 's/LivenessMaskView\.//g' {} \;

# Step 6: Clean up the build archives
rm -rf './build/LivenessMaskView.framework-iphonesimulator.xcarchive'
rm -rf './build/LivenessMaskView.framework-iphoneos.xcarchive'

# Step 5: Zip the XCFramework
# Navigate to the folder containing LivenessMaskView
cd './build' || exit 1

# Zip only the contents of LivenessMaskView without the 'build' directory
zip -r "$ZIP_PATH" "LivenessMask.xcframework"

# Return to the original directory
cd - || exit 1

echo "Zip framework SUCCEEDED"
cp -a -f "./build" "$GIT_REPO_PATH"
cp -a -f "./build" "../liveness-mask-view-pod"
rm -rf './build'

# Step 7: Move to the Git repository folder
cd "$GIT_REPO_PATH" || exit 1

# Step 8: Create a new Git tag
echo "Enter the new version tag (e.g., 1.0.0):"
read versionTag

# Update spec.version
sed -i "" "s/spec.version *= *\"[^\"]*\"/spec.version      = \"$versionTag\"/g" "$PODSPEC_FILE"

# Update spec.source
sed -i "" "s|spec.source *= *{ *:http => \"[^\"]*\" *}|spec.source = { :http => \"https://github.com/$GITHUB_REPO/releases/download/$versionTag/$ZIP_PATH\" }|g" "$PODSPEC_FILE"

# Step 9: Commit the change in Git
git add "$PODSPEC_FILE"
git commit -m "Update podspec to version $versionTag"
git push origin main

# Step 10: Create a new Git tag
git tag "$versionTag"
git push origin "$versionTag"

# Step 11: Create a GitHub release and upload the zip file
echo "Creating GitHub release and uploading the zip..."
gh release create "$versionTag" "./$ZIP_PATH" --title "$versionTag" --notes "Release version $versionTag"

# Step 12: Push the podspec to CocoaPods trunk
#pod trunk push LivenessMaskView.podspec --allow-warnings --skip-import-validation

echo "Build, tag creation, release, and pod push completed successfully."
