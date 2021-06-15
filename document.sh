SDK_PATH=`xcrun --sdk iphonesimulator --show-sdk-path`
sourcekitten doc --spm --module-name SwiftCurrent -- -Xswiftc "-sdk" -Xswiftc "$SDK_PATH" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios14.0-simulator" > swiftcurrent-docs.json
sourcekitten doc --module-name SwiftCurrent_UIKit -- -workspace ./SwiftCurrent.xcworkspace -scheme SwiftCurrent_UIKit -destination "platform=iOS Simulator,name=iPhone 12" > swiftcurrentuikit-docs.json
jazzy --sourcekitten-sourcefile swiftcurrent-docs.json,swiftcurrentuikit-docs.json
rm swiftcurrent-docs.json
rm swiftcurrentuikit-docs.json
open docs/index.html