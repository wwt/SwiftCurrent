# get the latest code
if [[ -n ${TRAVIS_BRANCH} ]]; then
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
    git config --global push.default current
fi
git checkout master
git reset --hard origin/master
git clean -df

# commit the podspec bump
fastlane patch
version=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" Workflow/Info.plist`
git commit -am "[ci skip] publishing pod version: $version" 
git tag "$version"
git push https://${PERSONAL_ACCESS_TOKEN}@github.com/Tyler-Keith-Thompson/Workflow.git HEAD -u $version
git reset --hard
git clean -df
curl --data "{\"tag_name\": \"$version\",\"target_commitish\": \"master\",\"name\": \"$version\",\"body\": \"Release of version $version\",\"draft\": false,\"prerelease\": false}" -H "Authorization: token $PERSONAL_ACCESS_TOKEN" "https://api.github.com/repos/Tyler-Keith-Thompson/Workflow/releases"
pod trunk push DynamicWorkflow.podspec --allow-warnings