# Contributing to Workflow
Thank you for your interest in Workflow!

## Submitting issues
### Filing bugs
If you found a bug in Workflow, thank you!  Please go to [issues](https://github.com/Tyler-Keith-Thompson/Workflow/issues/new/choose) and use the `Bug report` template to file it.  We'll reach out to you as soon as we can.  Some things the template will ask for are:
- Steps to reproduce
- Context around your environment
- Optional screenshots and debugging logs

### Feature requests
If you have an idea or change you would like to request, please go to [issues](https://github.com/Tyler-Keith-Thompson/Workflow/issues/new/choose) and use the `Feature request` template to make your request.  We'll reach out to you as soon as we can to discuss.  The more "why" you put into your request, the better we will be able to help build a solution that meets our styling and achieves your goals.

## Pull Requests:
PRs have a checklist that walks you through the things that you should do for any PR. This document provides greater detail and context around what some of those checklist items mean. Please take the time to read through this document and our styleguide before contributing so that we can keep Workflow clean, and maintainable. By the time you submit code we want to be focused on the logic, not the formatting, or patterns. Also please be sure to read the section on testing in this guide as tests are incredibly important to us.

## Style guide
Please review our [style guide](STYLEGUIDE.md) to ensure the least amount of rework and changes in your pull request.  If there are changes that you would like to make to the style guide, the process is:
1. Propose your change as an issue for tracking.
1. Create the Draft PR for changing STYLEGUIDE.md.
1. The whole team discusses (including you) to reach consensus.
1. The whole team (including you) works to refactor the entire codebase to adhere to the new style.
1. The PR is reviewed and merged into master.

<!-- When a tool is selected for Static Analysis add a section here to document what we care about and the process to change the things about it that we don't like -->

## Test Etiquette
- We are big believers in [TDD](https://en.wikipedia.org/wiki/Test-driven_development) and it is the practice we use for writing code. 
  - You do NOT have to practice TDD, as that's not enforceable. However, your tests should be written to provide the same value. TDD helps (but doesn't guarantee) not only tests, and high coverage but *valuable* tests. If you do a bunch of `XCTAssertNotNil(thing)` on things that should never be nil all your test did was get coverage numbers up, it didn't really assert anything we care about.
  - If you do not use TDD please comment out your production code, then run your tests. Make sure they *fail*, then slowly bring back your production code a few lines at a time all while running your tests. If they turn *green* before you have all your code back, you have more to cover.
- Prefer [sociable unit tests](https://martinfowler.com/bliki/UnitTest.html/) to solitary or "strict" unit tests.
  - Specifically this should indicate to you that tests are driven as much as possible from the public API layer. Our unit tests mimic how developers consume our library, and assert that it behaves as expected.
  - This should also indicate to you that we don't have many tests that make sure 2 classes talk to each other as expected, this means we have the freedom to refactor as we see fit, but still have confidence that what is important to our library consumers is working.
- Make sure all tests are passing before submitting a PR
- When you are fixing a bug please write a test first that clearly reproduces the bug, then write the fix. Writing the test first for bugs is generally more important to us than writing the tests first for features.
- As you're working in a section of the codebase look at the existing tests and make sure they're understandable. If your changes break any of them don't immediately assume they're wrong, it's more likely that you've broken something unexpected.

## Public API
### Versioning
We use a version of [semantic versioning](https://semver.org/#summary). Our semantic versioning can be summarized as:

* Major version changes when there is a breaking change to the public API.
* Minor version changes when something of consequence happens, e.g. new feature, bug fix that impacts numerous areas, adding deprecation warnings.
* Patch version always changes.

We strive to have this process automated. Patch increments with every commit to trunk, through the CI/CD pipeline. Major and Minor are currently updated through a script when the `podspec`'s version is manually updated and your PR gets to trunk.

### Deprecation
We want to give consumers of our code the opportunity to adapt to changes, outright removal means we'll constantly be breaking down-stream teams and that's a good way to frustrate developers.

We will do our best to support older methods, but we will also not hesitate to do something new and better if there's a new and better way of doing things. This is the same approach Apple tends to take.

## Documentation
### What needs documentation?
If you make any changes to the public API, these changes need to be documented in code with documentation comments. In addition, all documentation that references the changed API or provides samples needs to be updated. For example:
* Readme
* Wiki
* Installation guide
* Any GitHub pages
* GitHub discussions
* Runtime errors and edge cases

This is not just about code. If any change affects statements that we have made within our documentation, we need to update that too! 

### How do we write good documentation?
Our documentation goal is to be clear and concise. We don't want superfluous statements; we also want to avoid ambiguity. We choose to use US English for our documentation. 

For an example of documentation that we like, look at our style guide. Our style guide communicates complex topics unambiguously. People should understand the value of what we are documenting. If they're reading documentation about Workflow they should understand why Workflow is valuable to them. If they're reading documentation about our choice to use a fluent API, then they should understand why we chose it and how it helps them.  

### What don't we document? 
We do not document things that are irrelevent to our users. If we refactor internal workings of the library, our users are unaffected by that and therefore documenting it would be superfluous. We also don't document that anything that the linter or compiler will tell you. For example, we will not document compiler errors unless they are unclear. 



### Sample App
* Any additions/changes, etc. are represented in the sample app and how to use it
* Don't do testable imports (for the framework you are consuming)
* 

### Errors