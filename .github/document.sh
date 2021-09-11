SDK_PATH=`xcrun --sdk iphonesimulator --show-sdk-path`
sourcekitten doc --module-name SwiftCurrent -- -workspace ./SwiftCurrent.xcworkspace -scheme SwiftCurrent -destination "platform=iOS Simulator,name=iPhone 12" > swiftcurrent-docs.json
sourcekitten doc --module-name SwiftCurrent_UIKit -- -workspace ./SwiftCurrent.xcworkspace -scheme SwiftCurrent_UIKit -destination "platform=iOS Simulator,name=iPhone 12" > swiftcurrentuikit-docs.json
sourcekitten doc --module-name SwiftCurrent_SwiftUI -- -workspace ./SwiftCurrent.xcworkspace -scheme SwiftCurrent_SwiftUI -destination "platform=iOS Simulator,name=iPhone 12" > swiftcurrent-swiftui-docs.json
jazzy --config .github/.jazzy.yaml --podspec SwiftCurrent.podspec --sourcekitten-sourcefile swiftcurrent-docs.json,swiftcurrentuikit-docs.json,swiftcurrent-swiftui-docs.json
rm swiftcurrent-docs.json
rm swiftcurrentuikit-docs.json
rm swiftcurrent-swiftui-docs.json
cd .github/DocsPostProcessor
swift run DocsPostProcessor ../../Docs --replace-overview-with-readme --replace-readme-video-with-vimeo-embed
open ../../docs/index.html