## Goals

Following this style guide should:

* Make it easier to read and begin understanding unfamiliar code.
* Make code easier to maintain.
* Reduce simple programmer errors.
* Reduce cognitive load while coding.
* Keep discussions on diffs focused on the code's logic rather than its style.

Note that brevity is not a primary goal. Code should be made more concise only if other good code qualities (such as readability, simplicity, and clarity) remain equal or are improved.

## Guiding Tenets

* The [official swift API design guidelines](https://swift.org/documentation/api-design-guidelines/) are all unilaterally accepted for any public API and generally have good information for private or internal APIs. If you are not making a public API we do not require the same level of documentation, but the naming conventions and general design guidelines are still great and should be adhered to.
* These rules should not fight Xcode's <kbd>^</kbd> + <kbd>I</kbd> indentation behavior.
* We strive to make rules lintable:
  * If a rule changes the format of the code, it needs to be able to be reformatted automatically using [SwiftLint](https://github.com/realm/SwiftLint).
  * For rules that don't directly change the format of the code, we should have a lint rule that throws a warning.
  * For rules that cannot be handled directly with SwiftLint we will strive to have our own linter (for example, file names).

## How to read the guides
Each guide is broken into a few sections. Sections contain a list of guidelines. Each guideline starts with one of these words:

- **DO** guidelines describe practices that should always be followed. There will almost never be a valid reason to stray from them.
- **DON’T** guidelines are the converse: things that are almost never a good idea. 
- **PREFER** guidelines are practices that you should follow. However, there may be circumstances where it makes sense to do otherwise. Just make sure you understand the full implications of ignoring the guideline when you do.
- **AVOID** guidelines are the dual to “prefer”: stuff you shouldn’t do but where there may be good reasons to on rare occasions.
- **CONSIDER** guidelines are practices that you might or might not want to follow, depending on circumstances, precedents, and your own preference.

## Table of Contents

1. [Xcode Formatting](#xcode-formatting)
1. [Naming](#naming)
1. [Style](#style)
    1. [Functions](#functions)
    1. [Closures](#closures)
    1. [Operators](#operators)
    1. [Enumerations](#enumerations)
    1. [Generics](#generics)
1. [Patterns](#patterns)
    1. [Initializers](#initializers)
    1. [Method Complexity](#method-complexity)
    1. [Control Flow](#control-flow)
    1. [Access Control](#access-control)
    1. [Optionals](#optionals)
    1. [Immutability](#immutability)
    1. [Protocols](#protocols)
    1. [Type Erasure](#type-erasure)
1. [File Organization](#file-organization)
1. [Objective-C Interoperability](#objective-c-interoperability)

## Xcode Formatting

* **DO Trim trailing whitespace in all lines.**
* **DO Indent Case Statements in a Switch.**
  <details>

  #### Why?
  We feel this greatly increases readability. We find it a little surprising that isn't the default.
  
  #### How?
  Under `Xcode -> Preferences -> Text Editing -> Indentation` you can tell Xcode to indent case statements in Swift.

  </details>

* **DO use 4 spaces over tabs.** This is the Xcode default, and not something we will change.

* **DON'T use #imageLiteral or #colorLiteral (don't drag colors or images from xcode into code).**

**[⬆ back to top](#table-of-contents)**

## Naming

* **DO name booleans like `isSpaceship`, `hasSpacesuit`, `areTermsAccepted` etc.** This makes it clear that they are booleans and not other types.

* **DO name event-handling like past-tense sentences.** The subject can be omitted if it's not needed for clarity.

  <details>

  ```swift
  // WRONG
  class ExperiencesViewController {

    private func handleBookButtonTap() {
      // ...
    }

    private func modelChanged() {
      // ...
    }
  }

  // RIGHT
  class ExperiencesViewController {

    private func didTapBookButton() {
      // ...
    }

    private func modelDidChange() {
      // ...
    }
  }
  ```

  </details>

* **AVOID `*Controller` in names of classes that aren't view controllers.**
  <details>

  #### Why?
  Controller is an overloaded suffix that doesn't provide information about the responsibilities of the class.

  </details>

* **PREFER prefixing types with modules over creating wrongly named classes.**

  <details>

  ```swift
  // WRONG
  // in module 1
  struct Appointment {
    var time: Date
  }

  // in module2
  struct OtherAppointment {
    var time: Date
    var reason: String
  }

  // in calling code
  Appointment(time: Date())
  OtherAppointment(time: Date(), reason: "sick")

  // RIGHT
  // in module 1
  struct Appointment {
    var time: Date
  }

  // in module2
  struct Appointment {
    var time: Date
    var reason: String
  }

  // in calling code
  Module1.Appointment(time: Date())
  Module2.Appointment(time: Date(), reason: "sick")
  ```

  </details>

* **DO use US english spellings of words in code.** This is to fit with the convention of english spellings that is already part of the swift standard libraries

**[⬆ back to top](#table-of-contents)**

## Style

* **DON'T include types where they can be easily inferred.**

  <details>

  ```swift
  // WRONG
  let host: Host = Host()

  // RIGHT
  let host = Host()
  ```

  ```swift
  enum Direction {
    case left
    case right
  }

  func someDirection() -> Direction {
    // WRONG
    return Direction.left

    // RIGHT
    return .left
  }
  
  extension Container {
      static let `default` = Container()
  }
  
  // WRONG
  func getContainer() -> Container {
      return Container.default
  }
  
  // RIGHT
  func getContainer() -> Container { .default }
  
  ```

  </details>

* **PREFER type inference over explicit typing.**

  <details>
  While similar to the rule on not including types when they can easily be inferred this is slightly different. When declaring properties prefer type inference over explicit typing.

  ```swift
  // WRONG
  let host: Host = Host()
  let arr: [String] = []
  let dict: [AnyHashable: Any] = [:]

  // RIGHT
  let host = Host()
  let arr = [String]()
  let dict = [AnyHashable: Any]()
  ```

  </details>


* **DON'T use `self` unless it's necessary for disambiguation or required by the language.**

  <details>

  ```swift
  final class Listing {

    init(capacity: Int, allowsPets: Bool) {
      // WRONG
      self.capacity = capacity
      self.isFamilyFriendly = !allowsPets // `self.` not required here

      // RIGHT
      self.capacity = capacity
      isFamilyFriendly = !allowsPets
    }

    private let isFamilyFriendly: Bool
    private var capacity: Int

    private func increaseCapacity(by amount: Int) {
      // WRONG
      self.capacity += amount

      // RIGHT
      capacity += amount

      // WRONG
      self.save()

      // RIGHT
      save()
    }
  }
  ```

  </details>

* **DO bind to `self` when upgrading from a weak reference.**

  <details>

  ```swift
  //WRONG
  class MyClass {

    func request(completion: () -> Void) {
      API.request { [weak self] response in
        guard let strongSelf = self else { return }
        // Do work
        completion()
      }
    }
  }

  // RIGHT
  class MyClass {

    func request(completion: () -> Void) {
      API.request { [weak self] response in
        guard let self = self else { return }
        // Do work
        completion()
      }
    }
  }
  ```

  </details>

* **PREFER `self` in argument capture lists.**

  <details>

  ```swift
   //WRONG
  class MyClass {
    func example {
      performSomeTask {
        self.thing = new
        self.otherThing = otherNew
        self.runSomeMethod()
      }
    }
  }

  // RIGHT
  class MyClass {
    func example {
      performSomeTask { [self] in
        thing = new
        otherThing = otherNew
        runSomeMethod()
      }
    }
  }
  ```

  </details>

* **DO place the colon immediately after an identifier, followed by a space.**

  <details>

  ```swift
  // WRONG
  var something : Double = 0

  // RIGHT
  var something: Double = 0
  ```

  ```swift
  // WRONG
  class MyClass : SuperClass {
    // ...
  }

  // RIGHT
  class MyClass: SuperClass {
    // ...
  }
  ```

  ```swift
  // WRONG
  var dict = [KeyType:ValueType]()
  var dict = [KeyType : ValueType]()

  // RIGHT
  var dict = [KeyType: ValueType]()
  ```

  </details>

* **DO place a space on either side of a return arrow for readability.**

  <details>

  ```swift
  // WRONG
  func doSomething()->String {
    // ...
  }

  // RIGHT
  func doSomething() -> String {
    // ...
  }
  ```

  ```swift
  // WRONG
  func doSomething(completion: ()->Void) {
    // ...
  }

  // RIGHT
  func doSomething(completion: () -> Void) {
    // ...
  }
  ```

  </details>

* **DO omit unnecessary parentheses.**

  <details>

  ```swift
  // WRONG
  if (userCount > 0) { ... }
  switch (someValue) { ... }
  let evens = userCounts.filter { (number) in number % 2 == 0 }
  let squares = userCounts.map() { $0 * $0 }

  // RIGHT
  if userCount > 0 { ... }
  switch someValue { ... }
  let evens = userCounts.filter { number in number % 2 == 0 }
  let squares = userCounts.map { $0 * $0 }
  ```

  </details>

* **DO have brackets on separate lines for multi-line.** Put the opening and closing brackets on separate lines from any of the elements of the array. Also add a trailing comma on the last element.

  <details>

  ```swift
  // WRONG
  let rowContent = [listingUrgencyDatesRowContent(),
                    listingUrgencyBookedRowContent(),
                    listingUrgencyBookedShortRowContent()]

  // RIGHT
  let rowContent = [
    listingUrgencyDatesRowContent(),
    listingUrgencyBookedRowContent(),
    listingUrgencyBookedShortRowContent(),
  ]
  ```

* **PREFER constructors instead of Make() functions for NSRange and others.**

  <details>

  ```swift
  // WRONG
  let range = NSMakeRange(10, 5)

  // RIGHT
  let range = NSRange(location: 10, length: 5)
  ```

  </details>
  
* **AVOID using backticks to escape reserved keywords.**

  <details>
 
  #### Why?
  Reserved keywords are well...reserved and usually very generic. If you find yourself using overly generic terms your code is likely less readable. A notable exception to this is when dot syntax clears up that ambiguity, for example: `Container.default`, or even `.default` in context.

  ```swift
  // WRONG
  @IBOutlet var `switch`: UISwitch!

  // RIGHT
  @IBOutlet var notificationSwitch: UISwitch!
  
  extension Container {
      static let `default` = Container()
  }
  ```

  </details>
  
* **DO omit the `return` keyword when not required by the language.**

  <details>

  ```swift
  // WRONG
  ["1", "2", "3"].compactMap { return Int($0) }

  var size: CGSize {
    return CGSize(
      width: 100.0,
      height: 100.0)
  }

  func makeInfoAlert(message: String) -> UIAlertController {
    return UIAlertController(
      title: "ℹ️ Info",
      message: message,
      preferredStyle: .alert)
  }

  // RIGHT
  ["1", "2", "3"].compactMap { Int($0) }

  var size: CGSize {
    CGSize(
      width: 100.0,
      height: 100.0)
  }

  func makeInfoAlert(message: String) -> UIAlertController {
    UIAlertController(
      title: "ℹ️ Info",
      message: message,
      preferredStyle: .alert)
  }
  ```

  </details>

* **AVOID using semicolons after each statement in your code.** It is only required if you wish to combine multiple statements on a single line.

  <details>

  ```swift

  class SomeClass {
    var name:String?
    private func fooy() {
      // WRONG
      let foo = "foo is a common term in programming";

      // RIGHT
      let foo = "foo is a common term in programming" 

      // RIGHT
      guard let x = name else { print("there is no name"); return }
    }
  }
  ```

  </details>

* **AVOID having more than 1 statement per line.** An exception is `guard` statements when you may need a single statement before the `return`.

  <details>

  ```swift

  class SomeClass {
    var name:String?
    private func fooy() {
      // WRONG
      let foo = "statement"; let bar = "bar"
      guard let x = name else { logFailure(); makeDebugBreadcrumbs(); completion(); return }

      // RIGHT
      let foo = "statement"
      let bar = "bar"
      guard let x = name else { logFailure(); makeDebugBreadcrumbs(); completion(); return }
    }
  }
  ```

  </details>

### Functions

* **PREFER omitting `Void` return types from function definitions.**

  <details>

  ```swift
  // WRONG
  func doSomething() -> Void {
    ...
  }

  // RIGHT
  func doSomething() {
    ...
  }
  ```

  </details>

* **DO separate long function declarations with line breaks before each argument label after the first, but not before the return signature.** Put the open curly brace on the next line so the first executable line doesn't look like it's another parameter.

  <details>

  ```swift
  class Universe {

    // WRONG
    func generateStars(at location: Point, count: Int, color: StarColor, withAverageDistance averageDistance: Float) -> String {
      // This is too long and will probably auto-wrap in a weird way
    }

    // WRONG
    func generateStars(
      at location: Point,
      count: Int,
      color: StarColor,
      withAverageDistance averageDistance: Float) -> String {
      populateUniverse() // this line blends in with the argument list
    }

    // WRONG
    func generateStars(
      at location: Point,
      count: Int,
      color: StarColor,
      withAverageDistance averageDistance: Float) throws
      -> String {
      populateUniverse() // this line blends in with the argument list
    }

    // RIGHT
    func generateStars(at location: Point,
                       count: Int,
                       color: StarColor,
                       withAverageDistance averageDistance: Float) -> String {
        populateUniverse()
    }

    // RIGHT
    func generateStars(at location: Point,
                       count: Int,
                       color: StarColor,
                       withAverageDistance averageDistance: Float) throws -> String {
        populateUniverse()
    }
  }
  ```

  </details>

* **DO break each argument on long function invocations.** Put the closing parenthesis on the last line of the invocation.

  <details>

  ```swift
  // WRONG
  universe.generateStars(at: location, count: 5, color: starColor, withAverageDistance: 4)

  // WRONG
  universe.generateStars(at: location,
                         count: 5,
                         color: starColor,
                         withAverageDistance: 4
                         )

  // RIGHT
  universe.generateStars(at: location,
                         count: 5,
                         color: starColor,
                         withAverageDistance: 4)
  ```

  </details>

* **AVOID having 1-line functions unless they actually increase readability and trend towards english fluency.**

  <details>
 
  #### Why?
  Overly terse code is often difficult to reason about or modify. 

  ```swift
  // WRONG
  func didTapBookButton() { User.add(book: books[someIndex]) }

  // RIGHT
  var isEmpty: Bool { count == 0 }
  ```

  </details>
  
### Closures

* **PREFER `Void` return types over `()` in closure declarations.** If you must specify a `Void` return type in a function declaration, use `Void` rather than `()` to improve readability.

  <details>

  ```swift
  // WRONG
  func method(completion: () -> ()) {
    ...
  }
  

  // RIGHT
  func method(completion: () -> Void) {
    ...
  }
  ```

  </details>

* **DO name unused closure parameters as underscores (`_`) unless none are used.**

    <details>

    #### Why?
    Naming unused closure parameters as underscores reduces the cognitive overhead required to read
    closures by making it obvious which parameters are used and which are unused.

    ```swift
    // WRONG
    someAsyncThing() { argument1, argument2, argument3 in
      print(argument3)
    }

    // RIGHT
    someAsyncThing() { _, _, argument3 in
      print(argument3)
    }

    // RIGHT
    someAsyncThing() {
      print($2)
    }
    ```

    </details>

* **PREFER anonymous closure values when there are less than 2 arguments and it does not greatly increase cognitive complexity**

    <details>

    #### Why?
    Anonymous closure values ($0, $1, $2, etc...) can make it hard to reason able what you're dealing with barring some very specific circumstances. If you have more than 2 anonymous closure arguments you should name them to decrease ambiguity.

    ```swift
    // WRONG
    someAsyncThing() {
        print($0)
        modify($1)
        if ($2 == someValue.flatMap ({ $0 })) { //wait which $0????? 
        }
    }

    // RIGHT
    someAsyncThing() { name, age, isWearingSunglasses in
        print(name)
        modify(age)
        if (isWearingSunglasses == someValue.flatMap ({ $0 }).isEmpty) {
        }
    }

    // RIGHT
    [:].merging([:]) { $1 }
    ```

    </details>

* **DO put a space around single-line closures.**

  <details>

  ```swift
  // WRONG
  let evenSquares = numbers.filter {$0 % 2 == 0}.map {  $0 * $0  }

  // RIGHT
  let evenSquares = numbers.filter { $0 % 2 == 0 }.map { $0 * $0 }
  ```

  </details>

* **DO use trailing closure syntax.** If there are multiple trailing closure parameters, use the new syntax for multiple trailing closures available in Swift 5.x

  <details>

  ```swift

  class SomeClass {
    var name:String?
    private func fooy() {
      // WRONG
      UIView.animate(withDuration: 0.6, animations: { _ in self.view.alpha = 0}) { _ in
          self.view.removeFromSuperview()
      }

      // WRONG
      UIView.animate(withDuration: 0.6, animations: { _ in self.view.alpha = 0}, completion: { _ in self.view.removeFromSuperview() })


      // RIGHT
      UIView.animate(withDuration: 0.3) {
        self.view.alpha = 0
      } completion: { _ in
        self.view.removeFromSuperview()
      }
    }
  }
  ```

  </details>

* **AVOID multiple optional trailing closures.**

### Operators

* **DO put a single space around infix operators.** Prefer parenthesis to visually group statements with many operators rather than varying widths of whitespace. This rule does not apply to range operators (e.g. `1...3`) and postfix or prefix operators (e.g. `guest?` or `-1`).

  <details>

  ```swift
  // WRONG
  let capacity = 1+2
  let capacity = currentCapacity   ?? 0
  let mask = (UIAccessibilityTraitButton|UIAccessibilityTraitSelected)
  let capacity=newCapacity
  let latitude = region.center.latitude - region.span.latitudeDelta/2.0

  // RIGHT
  let capacity = 1 + 2
  let capacity = currentCapacity ?? 0
  let mask = (UIAccessibilityTraitButton | UIAccessibilityTraitSelected)
  let capacity = newCapacity
  let latitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
  ```

  </details>

* **AVOID creating custom operators.**

  <details>

  #### Why?
  Custom operators can drastically decrease readability. While there are times when they can be beneficial, they should either follow other common language conventions (like how ~= is used for regex matching in many languages) or they should have a clear precedent inside the codebase (like a `%%` postfix operator that has an x percent change of executing, `if 10%%`)

  </details>

* **DO overload existing operators when your use of the operator is semantically equivalent to the existing uses in the standard library.**

  <details>
  Overloading operators is permitted when your use of the operator is semantically equivalent to the existing uses in the standard library. Examples of permitted use cases are implementing the operator requirements for Equatable and Hashable, or defining a new Matrix type that supports arithmetic operations.
  </details>

### Enumerations
* **DO omit enum associated values from case statements when all arguments are unlabeled.**

  <details>

  ```swift
  // WRONG
  if case .done(_) = result { ... }

  switch animal {
  case .dog(_, _, _):
    ...
  }

  // RIGHT
  if case .done = result { ... }

  switch animal {
  case .dog:
    ...
  }
  ```

  </details>

* **DO use Swift's automatic enum values unless they map to an external source. Unless the external source has a value type like String that will not cause issues when inserted in the middle.** Add a comment explaining why explicit values are defined.

  <details>

  #### Why?
  To minimize user error, improve readability, and write code faster, rely on Swift's automatic enum values. If the value maps to an external source (e.g. it's coming from a network request) or is persisted across binaries, define the values explicitly and document what these values are mapping to. The exception to this is when the value type is like `String` that will not cause issues when inserted in the middle.

  This ensures that if someone adds a new value in the middle, they won't accidentally break things.

  ```swift
  // WRONG
  enum ErrorType: String {
    case error = "error"
    case warning = "warning"
  }
 
  // These values are internal, so we should not have explicity defined the values.
  enum Planet: Int {
    case mercury = 0
    case venus = 1
    case earth = 2
    case mars = 3
    case jupiter = 4
    case saturn = 5
    case uranus = 6
    case neptune = 7
  }

  // These values come from a server, so we should have set them here explicitly to match those values.
  enum ErrorCode: Int {
    case notEnoughMemory
    case invalidResource
    case timeOut
  }
  
  // These values also come from a server, but they are of string type so we should have continued to use the automatic values.
  enum UserType: String {
    case owner = "owner"
    case manager = "manager"
    case member = "member"
  }

  // RIGHT
  enum ErrorType: String {
    case error
    case warning
  }

  // These values are internal, so we do not need to explicity define the values.
  enum Planet: Int {
    case mercury
    case venus
    case earth
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
  }

  // These values come from a server, so we set them here explicitly to match those values.
  enum ErrorCode: Int {
    case notEnoughMemory = 0
    case invalidResource = 1
    case timeOut = 2
  }
  
  // These values also come from a server, but they are of string type so we can continue to use the automatic values.
  enum UserType: String {
    case owner
    case manager
    case member
  }
  ```

  </details>

* **DO put each `case` on its own line in an `enum`.** The expectation to this is if none of the cases have associated values or raw values, all cases fit on a single line, and the cases do not need further documentation because their meanings are obvious from their names.

  <details>

  ```swift
    // WRONG
    public enum Token {
      case comma, semicolon, identifier(String)
    }

    // RIGHT
    public enum Token {
      case comma
      case semicolon
      case identifier
    }
  ```

  </details>

* **DO declare the `enum` as `indirect` when all cases must be indirect.** Omit the keyword on individual cases.

  <details>

  ```swift
    // WRONG
    public enum DependencyGraphNode {
      indirect case userDefined(dependencies: [DependencyGraphNode])
      indirect case synthesized(dependencies: [DependencyGraphNode])
    }

    // RIGHT
    public indirect enum DependencyGraphNode {
      case userDefined(dependencies: [DependencyGraphNode])
      case synthesized(dependencies: [DependencyGraphNode])
    }
  ```

  </details>

* **DO order `enum` cases in a logical order.** If there is no obvious logical ordering, use a lexicographical odering based on the cases' names. 

  <details>

  ```swift
    // WRONG
    // These are sorted lexicographically, but the meaningful groupings of related values has been lost.
    public enum HTTPStatus: Int {
      case badRequest = 400
      case forbidden = 403
      case internalServerError = 500
      case notAuthorized = 401
      case notFound = 404
      case ok = 200
      case paymentRequired = 402
    }

    // RIGHT
    public enum HTTPStatus: Int {
      case ok = 200

      case badRequest = 400
      case notAuthorized = 401
      case paymentRequired = 402
      case forbidden = 403
      case notFound = 404

      case internalServerError = 500
    }
  ```

  </details>

### Generics
* **DO use generic `where` clauses for constraints, and use the generic specialization for typing.**

  <details>

  #### Why?
  We strive for code that delivers relevant information quickly. When reading the below examples from left to right, there is less cognitive load to provide the type of the specialization when the generic is introduced than to retain the generic, its uses, and then retroactively apply the type. It also creates a separation between specialization and restrictions when reading.

  ```swift
  // WRONG
  class SpecializedGeneric<F, B, FB> where F: Foo, B: Bar, FB: FooBar, F.Input == FB.Input {
    init<T, S, O>(thing: T, stuff: S, other: O) where T: Thing, S: Stuff, O: Other, T.Output == String, O.Input == T.Output {}
  }

  // RIGHT
  class SpecializedGeneric<F: Foo, B: Bar, FB: FooBar> where F.Input == FB.Input {
    init<T: Thing, S: Stuff, O: Other>(thing: T, stuff: S, other: O) where T.Output == String, O.Input == T.Output {}
  }
  ```

  </details>

* **DO use meaningful names when specializing with generics.**

  <details>

  #### Why?
  Often times with generics we lazily write `T` and move on, in the right contexts a single letter generic is just fine however as you start getting into increasingly complex scenarios this drastically reduces readability.

  ```swift
  // WRONG
  class Bookshelf<T> {

  }

  func<T, U, V> doThing() {

  }

  // RIGHT
  class Bookshelf<ReadableContent> {

  }

  func<S: Sequence, P: SomeType & SomeProtocol, N: Numeric> doThing() {

  }
  ```

  </details>
  
**[⬆ back to top](#table-of-contents)**

## Patterns

### Initializers
* **PREFER initializing properties at `init` time whenever possible, rather than using implicitly unwrapped optionals.**  A notable exception is UIViewController's `view` property.

  <details>

  ```swift
  // WRONG
  class MyClass {
    var someValue: Int!
    init() {
      super.init()
      someValue = 5
    }
  }

  // RIGHT
  class MyClass {
    var someValue: Int
    init() {
      someValue = 0
      super.init()
    }
  }
  ```

  </details>

* **PREFER default values in property declarations over initializers setting values.**
  <details>

  ```swift
  // WRONG
  class MyClass {
    var someValue: Int
    init() {
      someValue = 5
    }
  }

  // RIGHT
  class MyClass {
    var someValue: Int = 5
    init() { }
  }
  ```
  
  </details>

* **AVOID performing any meaningful or time-intensive work in `init()`.** Avoid doing things like opening database connections, making network requests, reading large amounts of data from disk, etc. Create a factory if these things need to be done before an object is ready for use.

### Method Complexity
* **DO extract complex property observers into methods.** This reduces nestedness, separates side-effects from property declarations, and makes the usage of implicitly-passed parameters like `oldValue` explicit.

  <details>

  ```swift
  // WRONG
  class TextField {
    var text: String? {
      didSet {
        guard oldValue != text else {
          return
        }

        // Do a bunch of text-related side-effects.
      }
    }
  }

  // RIGHT
  class TextField {
    var text: String? {
      didSet { textDidUpdate(from: oldValue) }
    }

    private func textDidUpdate(from oldValue: String?) {
      guard oldValue != text else {
        return
      }

      // Do a bunch of text-related side-effects.
    }
  }
  ```

  </details>
  
* **PREFER Combine functional chains over completion handlers**. 

* **DO extract complex callback blocks into methods**. This limits the complexity introduced by weak-self in blocks and reduces nestedness. If you need to reference self in the method call, make use of `guard` to unwrap self for the duration of the callback.

  <details>

  ```swift
  // WRONG
  class MyClass {

    func request(completion: () -> Void) {
      API.request() { [weak self] response in
        if let self = self {
          // Processing and side effects
        }
        completion()
      }
    }
  }

  // RIGHT
  class MyClass {

    func request(completion: () -> Void) {
      API.request() { [weak self] response in
        guard let self = self else { return }
        self.doSomething(with: self.property, response: response)
        completion()
      }
    }

    func doSomething(with nonOptionalParameter: SomeClass, response: SomeResponseClass) {
      // Processing and side effects
    }
  }
  ```

  </details>
  
### Control Flow
* **PREFER using `guard` over `if` for preconditions.**

  <details>
  
  ```swift
  // WRONG
  class MyClass {
    var thingWeNeed: String?
    func doThings() {
      if let thing = thingWeNeed {
        // lets do something with the thing
      }
    }
  }

  // RIGHT
  class MyClass {
    var thingWeNeed: String?
    func doThings() {
        guard let thing = thingWeNeed else { return }
        // lets do something with the thing
    }
  }
  
  // WRONG
  class MyClass {
    var arr = [String]()
    func doThings() {
      if !arr.isEmpty {
        // lets do something with the thing
      }
    }
  }

  // RIGHT
  class MyClass {
    var arr = [String]()
    func doThings() {
        guard !arr.isEmpty else { return }
        // lets do something with the thing
    }
  }
  
  ```

  </details>

* **PREFER using `guard` at the beginning of a scope.**

  <details>

  #### Why?
  It's easier to reason about a block of code when all `guard` statements are grouped together at the top rather than intermixed with business logic.

  </details>

* **DO use the "Golden Path" rule.** GOLDEN PATH RULE: When coding with conditionals, the left-hand margin of the code should be the "golden" or "happy" path. That is, don't nest if statements. Multiple return statements are OK. The guard statement is built for this.

  <details>

  ```swift
  // WRONG
  func computeFFT(context: Context?, inputData: InputData?) throws -> Frequencies {
    if let context = context {
      if let inputData = inputData {
        // use context and input to compute the frequencies
        // notice the "return" line is far to the right, this violates the 'left margin' idea.
        return frequencies
      } else {
        throw FFTError.noInputData
      }
    } else {
      throw FFTError.noContext
    }
  }

  // RIGHT
  func computeFFT(context: Context?, inputData: InputData?) throws -> Frequencies {
    guard let context = context else {
      throw FFTError.noContext
    }
    guard let inputData = inputData else {
      throw FFTError.noInputData
    }

    // use context and input to compute the frequencies
    // notice the return statement is as far left as it can be, this satisfies the golden path rule.
    return frequencies
  }

  ```
  </details>

* **DO write if/else statements starting with the happy path.**

  <details>

  #### Why?
  Your code should read as a declaration of intent. Starting with the happy path case makes your intent more immediately apparent.

  NOTE: This does not conflict with the golden path rule for guards and early exits.

  ```swift
  // WRONG
  if case .failure(let err) = result {
    // handle error
  } else {
    // thing the code should really do
  }

  switch result {
    case .failure(let err): throw err
    case .success: //thing the code should do
  }

  if thingThatProbablyWillNotHappen || thingThatLikelyWillHappen {

  }

  // RIGHT
  guard case .success = result else {
    throw err
  }

  // thing the code should do

  switch result {
    case .success: // thing the code should do
    case .failure(let err): throw err
  }

  if thingThatLikelyWillHappen || thingThatProbablyWillNotHappen {
    
  }

  ```
  </details>

* **DON'T use the `default` case when `switch`ing over an enum.**

  <details>

  #### Why?
  Enumerating every case requires developers and reviewers have to consider the correctness of every switch statement when new cases are added.

  ```swift
  // WRONG
  switch anEnum {
  case .a:
    // Do something
  default:
    // Do something else.
  }

  // RIGHT
  switch anEnum {
  case .a:
    // Do something
  case .b, .c:
    // Do something else.
  }
  ```

  </details>

* **DON'T use nested ternaries.**
  <details>

  #### Why?
  Ternaries can be great, they actually serve a functional purpose over an `if` statement because they are expressions, so you can assign them to a constant or return them as an expression. That being said if you find yourself nesting them you have gone too far.

  ```swift
  // WRONG
  result = a > b ? x = c > d ? c : d : y

  // RIGHT
  result = value != 0 ? x : y
  ```
  </details>

* **DON'T use multi-line ternaries.**

  <details>
  A ternary is meant to be used for a very short conditional. If you find it cannot be reasonably expressed on one line then it should not be a ternary.
  </details>

### Access Control
* **PREFER the strictest possible access control.** Prefer `public` to `open` and `private` to `fileprivate` unless you need that behavior.

* **AVOID global functions whenever possible.** Prefer methods within type definitions.

  <details>

  ```swift
  // WRONG
  func age(of person, bornAt timeInterval) -> Int {
    // ...
  }

  func jump(person: Person) {
    // ...
  }

  // RIGHT
  class Person {
    var bornAt: TimeInterval

    var age: Int {
      // ...
    }

    func jump() {
      // ...
    }
  }
  ```

  </details>

* **DO use caseless `enum`s for organizing `public` or `internal` constants and functions into namespaces.**
  * Avoid creating non-namespaced global constants and functions.
  * Feel free to nest namespaces where it adds clarity.
  * `private` globals are permitted, since they are scoped to a single file and do not pollute the global namespace. Consider placing private globals in an `enum` namespace to match the guidelines for other declaration types.

  <details>

  #### Why?
  Caseless `enum`s work well as namespaces because they cannot be instantiated, which matches their intent.

  ```swift
  enum Environment {

    enum Earth {
      static let gravity = 9.8
    }

    enum Moon {
      static let gravity = 1.6
    }
  }
  ```

  </details>

* **DO default type methods to `static`.**

  <details>

  #### Why?
  If a method needs to be overridden, the author should opt into that functionality by using the `class` keyword instead.

  ```swift
  // WRONG
  class Fruit {
    class func eatFruits(_ fruits: [Fruit]) { ... }
  }

  // RIGHT
  class Fruit {
    static func eatFruits(_ fruits: [Fruit]) { ... }
  }
  ```

  </details>

* **DO default classes to `final`.**

  <details>

  #### Why?
  If a class needs to be overridden, the author should opt into that functionality by omitting the `final` keyword.

  ```swift
  // WRONG
  class SettingsRepository {
    // ...
  }

  // RIGHT
  final class SettingsRepository {
    // ...
  }
  ```

  </details>

* **DO specify the access control for each declaration in an extension individually.**

  <details>

  #### Why?

  Specifying the access control on the declaration itself helps engineers more quickly determine the access control level of an individual declaration.

  ```swift
  // WRONG
  public extension Universe {
    // This declaration doesn't have an explicit access control level.
    // In all other scopes, this would be an internal function,
    // but because this is in a public extension, it's actually a public function.
    func generateGalaxy() { }
  }

  // WRONG
  private extension Spaceship {
    func enableHyperdrive() { }
  }

  // RIGHT
  extension Universe {
    // It is immediately obvious that this is a public function,
    // even if the start of the `extension Universe` scope is off-screen.
    public func generateGalaxy() { }
  }

  // RIGHT
  extension Spaceship {
    // Recall that a private extension actually has fileprivate semantics,
    // so a declaration in a private extension is fileprivate by default.
    fileprivate func enableHyperdrive() { }
  }
  ```

  </details>

### Optionals
* **PREFER throwing or optional intializers over optional properties that should have a value.**
  <details>
 
  ```swift
  // WRONG
  struct Person {
    var firstName: String? // firstName should have a value, but won't necessarily if we just create a new person
    var lastName: String? // lastName may, or may not have a value based on culture
  }

  // RIGHT
  struct Person: Decodable {
    var firstName: String // firstName should have a value, if a REST API does not return it Decodable has a throwing intializer that will well...throw
    var lastName: String? // lastName may, or may not have a value based on culture, so it should remain optional
  }

  // STILL RIGHT
  struct Person: Decodable {
    var firstName: String // firstName should have a value
    var lastName: String? // lastName may, or may not have a value based on culture, so it should remain optional

    init?(_ dictionary: [String: Any]) {
        guard let firstName = dictionary["firstName"] as? String else { return nil }
        self.firstName = firstName
        lastName = dictionary["lastName"] as? String
    }
  }
  
  ```

  </details>

* **PREFER implicitly unwrapped optionals when a value can be safely assumed.**
  <details>

  #### Why?
  Implicitly unwrapped optionals aren't *bad*, contrary to some opinions. While Swift does give us a lot of safety implicitly unwrapped optionals merely mean "this likely has a value when you need it". You can still treat them like optionals, unwrap them, use optional chaining syntax. Or you can treat them as if they have an expected value. Use them where appropriate and write adequate tests.
 
  ```swift
  // WRONG
  class ViewController {
    @IBOutlet var textField: UITextField?
  }

  // RIGHT
  class ViewController {
    @IBOutlet var textField: UITextField!
  }

  // STILL RIGHT
  class ViewModel {
    // where we have a test proving that SomeAPI is registered in the container in the app lifecycle
    @DependencyInjected var someAPI: SomeAPI!
  }
  
  ```

  </details>
  
* **DO check for nil rather than using optional binding if you don't need to use the value.**

  <details>

  #### Why?
  Checking for nil makes it immediately clear what the intent of the statement is. Optional binding is less explicit.

  ```swift
  var thing: Thing?

  // WRONG
  if let _ = thing {
    doThing()
  }

  // RIGHT
  if thing != nil {
    doThing()
  }
  ```

  </details>

### Immutability
* **PREFER immutable values whenever possible.** Use `map` and `compactMap` instead of appending to a new collection. Use `filter` instead of removing elements from a mutable collection.

  <details>

  #### Why?
  Mutable variables increase complexity, so try to keep them in as narrow a scope as possible.

  ```swift
  // WRONG
  var results = [SomeType]()
  for element in input {
    let result = transform(element)
    results.append(result)
  }

  // RIGHT
  let results = input.map { transform($0) }
  ```

  ```swift
  // WRONG
  var results = [SomeType]()
  for element in input {
    if let result = transformThatReturnsAnOptional(element) {
      results.append(result)
    }
  }

  // RIGHT
  let results = input.compactMap { transformThatReturnsAnOptional($0) }
  ```

  </details>


* **PREFER structs over classes.**
  <details>
  
  #### Why?
  This follows the previous rule of preferring immutability. Structs explicitly mark mutating members as mutating, they favor composition over inheritance, they have synthesized initializers, and they are copy-on-write meaning that unintended side-effects from modifying a reference are less prevalent.
 
  ```swift
  // WRONG
  class User: Codable {
      var username: String
      var email: String
      var dateOfBirth: Date

      init(username: String, email: String, dateOfBirth: Date) {
          self.username = username
          self.email = email
          self.dateOfBirth = dateOfBirth
      }
  }

  // RIGHT
  struct User: Codable {
      var username: String
      var email: String
      var dateOfBirth: Date
  }
  ```

  </details>

### Protocols
* **DO use `AnyObject` instead of `class` in protocol definitions.**

  <details>

  #### Why?

  [SE-0156](https://github.com/apple/swift-evolution/blob/master/proposals/0156-subclass-existentials.md]), which introduced support for using the `AnyObject` keyword as a protocol constraint, recommends preferring `AnyObject` over `class`:

  > This proposal merges the concepts of `class` and `AnyObject`, which now have the same meaning: they represent an existential for classes. To get rid of the duplication, we suggest only keeping `AnyObject` around. To reduce source-breakage to a minimum, `class` could be redefined as `typealias class = AnyObject` and give a deprecation warning on class for the first version of Swift this proposal is implemented in. Later, `class` could be removed in a subsequent version of Swift.

  ```swift
  // WRONG
  protocol Foo: class {}

  // RIGHT
  protocol Foo: AnyObject {}
  ```

  </details>

* **PREFER one conformance per extension or type declaration.**
  <details>

  #### Why?
  Choosing to have multiple conformances in a type means it is more difficult to extract code later, it also makes your type harder to reason about. 

  ```swift
  // WRONG
  class MyViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate {
    // all methods
  }

  // RIGHT
  class MyViewController: UIViewController {
    // class stuff here
  }

  extension MyViewController: UITableViewDataSource {
    // table view data source methods
  }

  extension MyViewController: UIScrollViewDelegate {
    // scroll view delegate methods
  }
  ```

  </details>

### Type Erasure
* **PREFER a wrapped `Any` type over a subclass for type erasure.**

  <details>

  #### Why?
  
  Subclassing based type erasure inherantly exposes implemention details to the end user that should not be exposed. Wrapping our types in the same way that Combine and SwiftUI do type erasure, ensures that the final exposed API is clean and correct for the end user to consume.

  ```swift
  // WRONG
  public protocol AnyStuff {
      // cannot make internal
      func erasedFoo(_ x: Any)
  }

  // End user should not see erasedFoo but can
  public protocol Stuff: AnyStuff {
      associatedtype T
      func foo(_ x: T)
  }

  extension Stuff {
      func foo(_ x: T) { erasedFoo(x) }
  }

  // RIGHT
  class AnyStuffBase {
      func foo(_ x: Any) { fatalError() }
  }

  class AnyStuffStorage<S: Stuff>: AnyStuffBase {
      let holder: S
      init(_ Stuff: S) { holder = Stuff }

      override func foo(_ x: Any) { holder.foo(x as! S.T) }
  }

  public class AnyStuff {
      private let base: AnyStuffBase
      public init<S: Stuff>(_ stuff: S) { base = AnyStuffStorage(stuff) }
      public func foo(_ x: Any) { base.foo(x) }
  }

  public protocol Stuff {
      associatedtype T
      func foo(_ x: T)
  }
  ```

  </details>

**[⬆ back to top](#table-of-contents)**

## File Organization

* **DO limit empty vertical whitespace to one line.** Favor the following formatting guidelines over whitespace of varying heights to divide files into logical groupings.

* **DO end files with a newline.**

* **DO place content in the correct order within a file based on impact to the codebase, grouped by similarity.** This allows a new reader of your code to more easily find what they are looking for.
  <details>
  
  #### Why?
  
  Things that can potentially effect more of the codebase go first. Similarly, related things (like the same property wrappers) take sorting precedence over the below list.  e.g. `@EnvironmentObject` comes before `@State`; `public` comes before `private`; `typealias`'s are potentially more affecting and thus go at the start.

  Still extract as necessary into extensions, but ensure those extensions also conform to the rule.

  The order:
  * Typealiases
  * Class properties
  * Static properties
  * Instance properties
  * Class methods
  * Static methods
  * Initializers
  * Instance methods
  * Nested types placed into extensions
 
  ```swift
  public struct ContentView: View {
    // typealias goes first as it impacts the rest of this struct and all other objects.
    // Also these are candidates for extraction into an extension
    public typealias CustomTypeAlias1 = String
    typealias CustomTypeAlias2 = String
    private typealias CustomTypeAlias3 = String

    // EnvironmentObject impacts this view and can impact all views beyond this one.
    @EnvironmentObject private var appModel: AppModel

    // ObservedObject impacts more than State and thus goes earlier even though hikeResult is public.
    @ObservedObject private var viewModel = ViewModel()
    @State var hikesResult: Result<[Hike], API.HikesService.Error>?

    // inspection impacts everything in body so it goes before body
    let inspection = Inspection<Self>()

    var body: some View { Empty() }

    // Candidates for extraction into an extension
    public class func classMethods1() {}
    class func classMethods2() {}
    private class func classMethods3() {}

    // Candidates for extraction into an extension
    public static func staticMethods1() {}
    static func staticMethods2() {}
    private static func staticMethods3() {}

    public init()
    init()
    init?()
    private init()

    public func instanceMethod1() {}
    func instanceMethod2() {}
    private func instanceMethod3() {}
  }
  ```

  </details>

* **DO put computed properties and properties with property observers at the end of the set of declarations of the same kind.** (e.g. instance properties.)
  <details>

  ```swift
  // WRONG
  var atmosphere: Atmosphere {
    didSet {
      print("oh my god, the atmosphere changed")
    }
  }
  var gravity: CGFloat

  // RIGHT
  var gravity: CGFloat
  var atmosphere: Atmosphere {
    didSet {
      print("oh my god, the atmosphere changed")
    }
  }
  ```

  </details>

* **DON'T keep dead code around.**
  <details>
  On the surface this may seem obvious but dead code takes many forms. File templates can really hurt you here because when you say create a new UIViewController it has methods that do nothing but call `super` that counts as dead code and clutters up the codebase needlessly.

  ```swift
  // WRONG
  override func didReceiveMemoryWarning() {
  super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return Database.contacts.count
  }

  // RIGHT
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Database.contacts.count
  }
  ```

  </details>

* **AVOID excessive comments.**
  <details>
  We are big believers in self documenting code. Public API deserve documentation comments in all their glory and you should follow our guide on that. When dealing with internal code comments should be reserved for times when meaning is genuinely unclear or non-intuitive. This tends to only be true when you cannot extract to a private method and *increase* readability. 

  ```swift
  // WRONG
  // calculates sum of all the ages of all the users
  func allUserAges() {
    users.reduce(0) { $0.ageInYears + $1.ageInYears }
  }

  // RIGHT
  /// max: Returns the maximum value in the comparable LinkedList
  /// - Returns: The maximum concrete value in the LinkedList or nil if there is none
  public func max() -> Value? {
      guard var m = first?.value else { return nil }
      forEach { m = Swift.max(m, $0.value) }
      return m
  }

  // STILL RIGHT
  // Implementation of Luhn's Algorithm in Swift
  // From the rightmost digit of your card number, double every other digit.
  // If the doubled digit is larger than 9 (ex. 8 * 2 = 16), subtract 9 from the product (16 – 9 = 7).
  // Sum the digits.
  // If there is no remainder after dividing by 10 (sum % 10 == 0), the card is valid.
  var isValidCreditCardNumber: Bool {
      let digits = reversed().compactMap { Int(String($0)) }
      guard digits.count == count, digits.count > 0 else { return false }
      let sum = digits.enumerated().reduce(0) {
          return $0 + ((($1.offset % 2) == 0) ? $1.element : (2 * $1.element - 1) % 9 + 1)
      }
      return sum % 10 == 0
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return Database.contacts.count
  }

  // RIGHT
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Database.contacts.count
  }
  ```

  </details>  
**[⬆ back to top](#table-of-contents)**

## Objective-C Interoperability

* **PREFER pure Swift classes over subclasses of NSObject.** If your code needs to be used by some Objective-C code, wrap it to expose the desired functionality. Use `@objc` on individual methods and variables as necessary rather than exposing all API on a class to Objective-C via `@objcMembers`.

  <details>

  ```swift
  class PriceBreakdownViewController {

    private let acceptButton = UIButton()

    private func setUpAcceptButton() {
      acceptButton.addTarget(
        self,
        action: #selector(didTapAcceptButton),
        forControlEvents: .touchUpInside)
    }

    @objc
    private func didTapAcceptButton() {
      // ...
    }
  }
  ```

  </details>

**[⬆ back to top](#table-of-contents)**

## Attribution:
- This styleguide was forked from the [AirBnB styleguide](https://github.com/airbnb/swift). Thanks AirBnB!
- Inspiration on format also came from [the effective dart docs](https://dart.dev/guides/language/effective-dart), Thanks google!
- Parts of the styleguide also inspired by [the google swift styleguide](https://google.github.io/swift/#defining-new-operators), Thanks google!
- Parts of the styleguide also inspired by [The Official raywenderlich.com Swift Style Guide](https://github.com/raywenderlich/swift-style-guide), Thanks Ray Wenderlich!
