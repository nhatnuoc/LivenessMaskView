rm -rf './build/'

xcodebuild archive \
-workspace FlashLiveness.xcworkspace \
-scheme FlashLiveness \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/FlashLiveness/FlashLiveness.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive \
-workspace FlashLiveness.xcworkspace \
-scheme FlashLiveness \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/FlashLiveness/FlashLiveness.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework './build/FlashLiveness/FlashLiveness.framework-iphoneos.xcarchive/Products/Library/Frameworks/FlashLiveness.framework' \
-framework './build/FlashLiveness/FlashLiveness.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/FlashLiveness.framework' \
-output './build/FlashLiveness/FlashLiveness.xcframework'

rm -rf './build/FlashLiveness/FlashLiveness.framework-iphonesimulator.xcarchive'
rm -rf './build/FlashLiveness/FlashLiveness.framework-iphoneos.xcarchive'

cp -R "./build/FlashLiveness" ../FlashLivenessPod

rm -rf './build/'
