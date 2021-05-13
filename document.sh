cd Workflow
SDK_PATH=`xcrun --sdk iphonesimulator --show-sdk-path`
sourcekitten doc --spm --module-name Workflow -- -Xswiftc "-sdk" -Xswiftc "$SDK_PATH" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios14.0-simulator" > ../workflow-docs.json
sourcekitten doc --module-name WorkflowUIKit -- -workspace ../Workflow.xcworkspace -scheme WorkflowUIKit -destination "platform=iOS Simulator,name=iPhone 12" > ../workflowuikit-docs.json
# echo ${workflowdocs%?}', '${uikitdocs:1} > ../kitty.json
cd ../
jazzy --sourcekitten-sourcefile workflow-docs.json,workflowuikit-docs.json
rm workflow-docs.json
rm workflowuikit-docs.json
open docs/index.html