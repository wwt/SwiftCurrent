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
1. [Patterns](#patterns)
    1. [Initializers](#initializers)
    1. [Method Complexity](#method-complexity)
    1. [Control Flow](#control-flow)
    1. [Access Control](#access-control)
    1. [Enumerations](#enumerations)
    1. [Optionals](#optionals)
    1. [OTHERS](#others)
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
 
  ## Why?
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

* **AVOID having 1-line functions unless they actually increase readability and trend towards english fluency.**

  <details>
 
  ## Why?
  Overly terse code is often difficult to reason about or modify. 

  ```swift
  // WRONG
  func didTapBookButton() { User.add(book: books[someIndex]) }

  // RIGHT
  var isEmpty: Bool { count == 0 }
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

### Enumerations
* **DO use Swift's automatic enum values unless they map to an external source, or have a value type like String, that will not cause issues when inserted in the middle.** Add a comment explaining why explicit values are defined.

  <details>

  #### Why?
  To minimize user error, improve readability, and write code faster, rely on Swift's automatic enum values. If the value maps to an external source (e.g. it's coming from a network request) or is persisted across binaries, however, define the values explicity, and document what these values are mapping to. The exception to this is when the value type is like `String` that will not cause issues when inserted in the middle.

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
  ### Why?
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

### OTHERS
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

**[⬆ back to top](#table-of-contents)**

## File Organization

* **DO limit empty vertical whitespace to one line.** Favor the following formatting guidelines over whitespace of varying heights to divide files into logical groupings.

* **DO end files with a newline.**

* **DO place content in the correct order within a file.** This allows a new reader of your code to more easily find what they are looking for.
  * Nested types and typealiases
  * Static Properties using propertywrappers (like `@State`, `@Binding`, `@Published`, etc...)
  * Static properties
  * Class Properties using propertywrappers (like `@State`, `@Binding`, `@Published`, etc...)
  * Class properties
  * Instance Properties using propertywrappers (like `@State`, `@Binding`, `@Published`, etc...)
  * Instance properties
  * Static methods
  * Class methods
  * Instance methods

* **DO add empty lines between property declarations by logical group.** (e.g. between static properties and instance properties.)

  <details>

  ```swift
  // WRONG
  var title: String
  static let gravityEarth: CGFloat = 9.8
  static let gravityMoon: CGFloat = 1.6
  var gravity: CGFloat

  // RIGHT
  var title: String
  
  static let gravityEarth: CGFloat = 9.8
  static let gravityMoon: CGFloat = 1.6
  var gravity: CGFloat
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
