version=$1
pathToPlist=$2
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion '${version}'" $pathToPlist
echo "Set plist version to $version in $pathToPlist"