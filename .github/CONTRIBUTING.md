# Contributing to SwiftCurrent
Thank you for your interest in SwiftCurrent!

[![Issues](https://img.shields.io/github/issues/wwt/SwiftCurrent?color=bright-green)](https://github.com/wwt/SwiftCurrent/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/wwt/SwiftCurrent?color=bright-green)](https://github.com/wwt/SwiftCurrent/pulls)

## Submitting issues
### Filing bugs
If you found a bug in SwiftCurrent, thank you!  Please go to [issues](https://github.com/wwt/SwiftCurrent/issues/new/choose) and use the `Bug report` template to file it.  We'll reach out to you as soon as we can.  Some things the template will ask for are:
- Steps to reproduce
- Context around your environment
- Optional screenshots and debugging logs

### Feature requests
If you have an idea or change you would like to request, please go to [issues](https://github.com/wwt/SwiftCurrent/issues/new/choose) and use the `Feature request` template to make your request.  We'll reach out to you as soon as we can to discuss.  The more "why" you put into your request, the better we will be able to help build a solution that meets our styling and achieves your goals.

## Pull Requests
PRs have a checklist that walks you through the things that you should do for any PR. This document provides greater detail and context around what some of those checklist items mean. Please take the time to read through this document and our styleguide before contributing so that we can keep SwiftCurrent clean, and maintainable. By the time you submit code we want to be focused on the logic, not the formatting, or patterns. Also please be sure to read the section on testing in this guide as tests are incredibly important to us.

> The SwiftCurrent team finds value in structuring our commit messages in a consistent way. We would love it if you would do the same:
> 
> ```[branch-name] - description```

## Sign the CLA

Before you can contribute to SwiftCurrent, you will need to sign the [Contributor License Agreement](https://cla-assistant.io/wwt/SwiftCurrent).

## Code of Conduct

Please make sure to read and observe the [Code of Conduct](https://github.com/wwt/SwiftCurrent/blob/main/.github/CODE_OF_CONDUCT.md).

## Style guide
Please review our [style guide](STYLEGUIDE.md) to ensure the least amount of rework and changes in your pull request.  If there are changes that you would like to make to the style guide, the process is:
1. Propose your change as an issue for tracking.
1. Create the Draft PR for changing STYLEGUIDE.md.
1. The whole team discusses (including you) to reach consensus.
1. The whole team (including you) works to refactor the entire codebase to adhere to the new style.
1. The PR is reviewed and merged into main.

<!-- When a tool is selected for Static Analysis add a section here to document what we care about and the process to change the things about it that we don't like -->

## Test Etiquette
- We are big believers in [TDD](https://en.wikipedia.org/wiki/Test-driven_development) and it is the practice we use for writing code. 
  - You do NOT have to practice TDD, as that's not enforceable. However, your tests should be written to provide the same value. TDD helps (but doesn't guarantee) not only tests, and high coverage but *valuable* tests. If you do a bunch of `XCTAssertNotNil(thing)` on things that should never be nil all your test did was get coverage numbers up, it didn't really assert anything we care about.
  - If you do not use TDD please comment out your production code, then run your tests. Make sure they *fail*, then slowly bring back your production code a few lines at a time all while running your tests. If they turn *green* before you have all your code back, you have more to cover.
- Prefer [sociable unit tests](https://martinfowler.com/bliki/UnitTest.html) to solitary or "strict" unit tests.
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
Our documentation goal is to be clear and concise. We don't want superfluous statements; we also want to avoid ambiguity. We choose to use US English for our documentation. If you are going to include sample code in your documentation it is vital that code can be copied and pasted into Xcode and work with the latest version of our library.

For an example of documentation that we like, look at our style guide. Our style guide communicates complex topics unambiguously. People should understand the value of what we are documenting. If they're reading documentation about SwiftCurrent they should understand why SwiftCurrent is valuable to them. If they're reading documentation about our choice to use a fluent API, then they should understand why we chose it and how it helps them.  

### What don't we document? 
We do not document things that are irrelevant to our users. This means we do not document implementation details of our public methods, but we do document how to use those public methods. If we refactor internal workings of the library, our users are unaffected by that and therefore documenting it would be superfluous. We also don't document anything that the linter or compiler will tell you. For example, we will not document compiler errors unless they are unclear. 

## Sample App
Different consumers of our library prefer to learn how to use it in their own way. For some, that means reading through sample code that they can copy and paste, other consumers prefer reading details about what our thought processes were and why we built this, and others still want a space to stand up our library and poke at it to see how it responds. This is where our sample app comes in.

Our sample app is meant to showcase how we believe our users will consume our library. It should import like they would import (using a package manager), and it should have scenarios that are generally the kinds of scenarios our users want to use the library for.

It also serves as our very own "best practice" guide. The code that's in there should be just as cared for as any other code we write. The sample app should be well-tested so that our users know how they can test our library effectively. Lastly, it should be kept up-to-date with the latest versions of Xcode, Swift, and our Library.

## Errors
We believe the best developer experience for errors lies in their interactions with their compiler. Compiler errors force developers to solve for edge cases before the code is running, and long before the code is in production. They also reduce testing overhead, there's really not much point in unit testing an error that can't compile.

Because of this we strive for compiler errors where possible, we will effectively use generics for type safety, and we will use annotations like `@deprecated`, `@unavailable`, and `@available(*, unavailable, renamed:)`. When we run into situations where a runtime error is the only reasonable option, we document it and we write good tests around it. We also prefer the most noticeable errors we can have for the best developer experience.

For example, sometimes a `throws` method is both a good developer experience and a clear error scenario. Other times making something throw just adds overhead. So we might prefer a `fatalError` with a clear description of the problem, fatal errors are noticeable when they happen, app execution stops. This means developers have a greater chance of noticing that something has gone wrong. We DO NOT like having errors that only print to the console, this is difficult to spot and generally unhelpful.
