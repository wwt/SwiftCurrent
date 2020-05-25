version=$1
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion '${version}'" Workflow/Info.plist
echo "Set plist version to $version"