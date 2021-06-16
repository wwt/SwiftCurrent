<!-- All PRs should have some kind of issue backing them. This means the community has had some opportunity to contribute ideas, or that the PR is fixing a problem that is being tracked -->
### Linked Issue: 

<!-- (See our contributing guidelines for more details) -->
## Checklist:
- [ ] Is the linter reporting 0 errors?
- [ ] Did you comply with our [styleguide](https://github.com/wwt/SwiftCurrent/blob/main/STYLEGUIDE.md)?
- [ ] Is there [adequate test coverage](https://github.com/wwt/SwiftCurrent/blob/main/CONTRIBUTING.md#test-etiquette) for your new code?
- [ ] Does the CI pipeline pass?
- [ ] Did you [update the documentation](https://github.com/wwt/SwiftCurrent/blob/main/CONTRIBUTING.md#documentation)?
- [ ] Did you [update the sample app](https://github.com/wwt/SwiftCurrent/blob/main/CONTRIBUTING.md#sample-app)?
- [ ] Do we need to [increment the minor/major version](https://github.com/wwt/SwiftCurrent/blob/main/CONTRIBUTING.md#versioning)?
- [ ] Did you [change the public API](https://github.com/wwt/SwiftCurrent/blob/main/CONTRIBUTING.md#public-api)?
- [ ] Have you done everything you can to make sure that errors that can occur are compile-time errors, and if they have to be runtime do you have adequate tests and documentation around those runtime errors? [For more details](https://github.com/wwt/SwiftCurrent/blob/main/CONTRIBUTING.md#errors).

----

### If Applicable:
- [ ] Did you test when the first item is skipped?
- [ ] Did you test when the last item is skipped?
- [ ] Did you test when middle items are skipped?
- [ ] Did you test when incorrect data is passed forward?
- [ ] Did you test proceeding backwards?

----

### If Public API Has Changed:
- [ ] Did you deprecate (rather than remove) any old methods/variables/etc? [Our philosophy for deprecation](https://github.com/wwt/SwiftCurrent/blob/main/CONTRIBUTING.md#deprecation).
- [ ] Have you done the best that you can to make sure that the compiler guides people to changing to the new API? (Example: the renamed attribute)
- [ ] If necessary, have you tested the upgrade path for at least N-1 versions? For example, if data persists between v1 and v2 then that upgrade should be tested and as easy as we can make it.
