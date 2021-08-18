PACKAGE_SWIFT_LOCATION=$1

# Rewrite Package.swift so that it declares dynamic libraries, since the approach does not work with static libraries
perl -i -p0e 's/type: .static,//g' $PACKAGE_SWIFT_LOCATION
perl -i -p0e 's/type: .dynamic,//g' $PACKAGE_SWIFT_LOCATION
perl -i -p0e 's/BETA_//g' $PACKAGE_SWIFT_LOCATION
perl -i -p0e 's/(library[^,]*,)/$1 type: .dynamic,/g' $PACKAGE_SWIFT_LOCATION
