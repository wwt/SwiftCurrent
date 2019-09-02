var plist = require('simple-plist');
var data = plist.readFileSync('Workflow/Info.plist');
data.CFBundleVersion = process.argv[2].toString();
plist.writeFileSync('Workflow/Info.plist', data);
