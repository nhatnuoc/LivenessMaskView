rm -rf './build/'

xcodebuild archive \
-scheme NDA \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/NDA/LivenessMaskView.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive \
-scheme NDA \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/NDA/LivenessMaskView.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework './build/NDA/FlashLiveness.framework-iphoneos.xcarchive/Products/Library/Frameworks/LivenessMaskView.framework' \
-framework './build/NDA/FlashLiveness.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/LivenessMaskView.framework' \
-output './build/NDA/LivenessMaskView.xcframework'

rm -rf './build/NDA/LivenessMaskView.framework-iphonesimulator.xcarchive'
rm -rf './build/NDA/LivenessMaskView.framework-iphoneos.xcarchive'
