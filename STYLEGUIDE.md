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

## Table of Contents

1. [Xcode Formatting](#xcode-formatting)
1. [Naming](#naming)
1. [Style](#style)
    1. [Functions](#functions)
    1. [Closures](#closures)
    1. [Operators](#operators)
1. [Patterns](#patterns)
1. [File Organization](#file-organization)
1. [Objective-C Interoperability](#objective-c-interoperability)

## Xcode Formatting

* **Trim trailing whitespace in all lines.**
* **Indent Case Statements in a Switch.**
  <details>

  #### Why?
  We feel this greatly increases readability. We find it a little surprising that isn't the default.
  
  #### How?
  Under `Xcode -> Preferences -> Text Editing -> Indentation` you can tell Xcode to indent case statements in Swift.

  </details>

**[⬆ back to top](#table-of-contents)**

## Naming

* <a id='bool-names'></a>(<a href='#bool-names'>link</a>) **Name booleans like `isSpaceship`, `hasSpacesuit`, `areTermsAccepted` etc.** This makes it clear that they are booleans and not other types.

* <a id='past-tense-events'></a>(<a href='#past-tense-events'>link</a>) **Event-handling functions should be named like past-tense sentences.** The subject can be omitted if it's not needed for clarity.

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

* <a id='avoid-controller-suffix'></a>(<a href='#avoid-controller-suffix'>link</a>) **Avoid `*Controller` in names of classes that aren't view controllers.**
  <details>

  #### Why?
  Controller is an overloaded suffix that doesn't provide information about the responsibilities of the class.

  </details>

**[⬆ back to top](#table-of-contents)**

## Style

* <a id='use-implicit-types'></a>(<a href='#use-implicit-types'>link</a>) **Don't include types where they can be easily inferred.**

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

* **Don't use `self` unless it's necessary for disambiguation or required by the language.**

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

* <a id='upgrade-self'></a>(<a href='#upgrade-self'>link</a>) **Bind to `self` when upgrading from a weak reference.** [![SwiftFormat: strongifiedSelf](https://img.shields.io/badge/SwiftFormat-strongifiedSelf-7B0051.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#strongifiedSelf)

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

* **Prefer `self` in argument capture lists.**

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

* <a id='colon-spacing'></a>(<a href='#colon-spacing'>link</a>) **Place the colon immediately after an identifier, followed by a space.** [![SwiftLint: colon](https://img.shields.io/badge/SwiftLint-colon-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#colon)

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

* <a id='return-arrow-spacing'></a>(<a href='#return-arrow-spacing'>link</a>) **Place a space on either side of a return arrow for readability.** [![SwiftLint: return_arrow_whitespace](https://img.shields.io/badge/SwiftLint-return__arrow__whitespace-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#returning-whitespace)

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

* <a id='unnecessary-parens'></a>(<a href='#unnecessary-parens'>link</a>) **Omit unnecessary parentheses.** [![SwiftFormat: redundantParens](https://img.shields.io/badge/SwiftFormat-redundantParens-7B0051.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#redundantParens)

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

* <a id='unnecessary-enum-arguments'></a> (<a href='#unnecessary-enum-arguments'>link</a>) **Omit enum associated values from case statements when all arguments are unlabeled.** [![SwiftLint: empty_enum_arguments](https://img.shields.io/badge/SwiftLint-empty__enum__arguments-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#empty-enum-arguments)

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


* <a id='multi-line-array'></a>(<a href='#multi-line-array'>link</a>) **Multi-line arrays should have each bracket on a separate line.** Put the opening and closing brackets on separate lines from any of the elements of the array. Also add a trailing comma on the last element. [![SwiftFormat: wrapArguments](https://img.shields.io/badge/SwiftFormat-wrapArguments-7B0051.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#wrapArguments)

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

* <a id='favor-constructors'></a>(<a href='#favor-constructors'>link</a>) **Use constructors instead of Make() functions for NSRange and others.** [![SwiftLint: legacy_constructor](https://img.shields.io/badge/SwiftLint-legacy__constructor-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#legacy-constructor)

  <details>

  ```swift
  // WRONG
  let range = NSMakeRange(10, 5)

  // RIGHT
  let range = NSRange(location: 10, length: 5)
  ```

  </details>

### Functions

* <a id='omit-function-void-return'></a>(<a href='#omit-function-void-return'>link</a>) **Omit `Void` return types from function definitions.** [![SwiftLint: redundant_void_return](https://img.shields.io/badge/SwiftLint-redundant__void__return-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#redundant-void-return)

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

* **Separate long function declarations with line breaks before each argument label after the first, but not before the return signature.** Put the open curly brace on the next line so the first executable line doesn't look like it's another parameter.

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

* <a id='long-function-invocation'></a>(<a href='#long-function-invocation'>link</a>) **[Long](https://github.com/airbnb/swift#column-width) function invocations should also break on each argument.** Put the closing parenthesis on the last line of the invocation. [![SwiftFormat: wrapArguments](https://img.shields.io/badge/SwiftFormat-wrapArguments-7B0051.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#wrapArguments)

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

* <a id='favor-void-closure-return'></a>(<a href='#favor-void-closure-return'>link</a>) **Favor `Void` return types over `()` in closure declarations.** If you must specify a `Void` return type in a function declaration, use `Void` rather than `()` to improve readability. [![SwiftLint: void_return](https://img.shields.io/badge/SwiftLint-void__return-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#void-return)

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

* **Name unused closure parameters as underscores (`_`) unless none are used.**

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

* **Prefer anonymous closure values when there are less than 2 arguments and it does not greatly increase cognitive complexity**

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

* <a id='closure-brace-spacing'></a>(<a href='#closure-brace-spacing'>link</a>) **Single-line closures should have a space inside each brace.** [![SwiftLint: closure_spacing](https://img.shields.io/badge/SwiftLint-closure__spacing-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#closure-spacing)

  <details>

  ```swift
  // WRONG
  let evenSquares = numbers.filter {$0 % 2 == 0}.map {  $0 * $0  }

  // RIGHT
  let evenSquares = numbers.filter { $0 % 2 == 0 }.map { $0 * $0 }
  ```

  </details>

### Operators

* <a id='infix-operator-spacing'></a>(<a href='#infix-operator-spacing'>link</a>) **Infix operators should have a single space on either side.** Prefer parenthesis to visually group statements with many operators rather than varying widths of whitespace. This rule does not apply to range operators (e.g. `1...3`) and postfix or prefix operators (e.g. `guest?` or `-1`). [![SwiftLint: operator_usage_whitespace](https://img.shields.io/badge/SwiftLint-operator__usage__whitespace-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#operator-usage-whitespace)

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

* <a id='implicitly-unwrapped-optionals'></a>(<a href='#implicitly-unwrapped-optionals'>link</a>) **Prefer initializing properties at `init` time whenever possible, rather than using implicitly unwrapped optionals.**  A notable exception is UIViewController's `view` property. [![SwiftLint: implicitly_unwrapped_optional](https://img.shields.io/badge/SwiftLint-implicitly__unwrapped__optional-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#implicitly-unwrapped-optional)

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

* **Prefer default values in property declarations over initializers setting values.**
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

* <a id='time-intensive-init'></a>(<a href='#time-intensive-init'>link</a>) **Avoid performing any meaningful or time-intensive work in `init()`.** Avoid doing things like opening database connections, making network requests, reading large amounts of data from disk, etc. Create a factory if these things need to be done before an object is ready for use.

* <a id='complex-property-observers'></a>(<a href='#complex-property-observers'>link</a>) **Extract complex property observers into methods.** This reduces nestedness, separates side-effects from property declarations, and makes the usage of implicitly-passed parameters like `oldValue` explicit.

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
  
* **Prefer Combine functional chains over completion handlers**. 

* <a id='complex-callback-block'></a>(<a href='#complex-callback-block'>link</a>) **Extract complex callback blocks into methods**. This limits the complexity introduced by weak-self in blocks and reduces nestedness. If you need to reference self in the method call, make use of `guard` to unwrap self for the duration of the callback.

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
  
* **Prefer using `guard` over `if` for preconditions.**

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

* **Prefer using `guard` at the beginning of a scope.**

  <details>

  #### Why?
  It's easier to reason about a block of code when all `guard` statements are grouped together at the top rather than intermixed with business logic.

  </details>

* <a id='limit-access-control'></a>(<a href='#limit-access-control'>link</a>) **Access control should be at the strictest level possible.** Prefer `public` to `open` and `private` to `fileprivate` unless you need that behavior.

* <a id='avoid-global-functions'></a>(<a href='#avoid-global-functions'>link</a>) **Avoid global functions whenever possible.** Prefer methods within type definitions.

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

* <a id='namespace-using-enums'></a>(<a href='#namespace-using-enums'>link</a>) **Use caseless `enum`s for organizing `public` or `internal` constants and functions into namespaces.**
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

* <a id='auto-enum-values'></a>(<a href='#auto-enum-values'>link</a>) **Use Swift's automatic enum values unless they map to an external source, or have a value type like string, that will not cause issues when inserted in the middle.** Add a comment explaining why explicit values are defined. [![SwiftLint: redundant_string_enum_value](https://img.shields.io/badge/SwiftLint-redundant__string__enum__value-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#redundant-string-enum-value)

  <details>

  #### Why?
  To minimize user error, improve readability, and write code faster, rely on Swift's automatic enum values. If the value maps to an external source (e.g. it's coming from a network request) or is persisted across binaries, however, define the values explicity, and document what these values are mapping to.

  This ensures that if someone adds a new value in the middle, they won't accidentally break things.

  ```swift
  // WRONG
  enum ErrorType: String {
    case error = "error"
    case warning = "warning"
  }
 
  // These values are internal, so we do not need to explicity define the values.
  // Planet is an Int to support sorting
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

  enum ErrorCode: Int {
    case notEnoughMemory
    case invalidResource
    case timeOut
  }

  // RIGHT
  enum ErrorType: String {
    case error
    case warning
  }

  enum UserType: String {
    case owner
    case manager
    case member
  }

  // These values are internal, so we do not need to explicity define the values.
  // Planet is an Int to support sorting
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

  /// These values come from the server, so we set them here explicitly to match those values.
  enum ErrorCode: Int {
    case notEnoughMemory = 0
    case invalidResource = 1
    case timeOut = 2
  }
  ```

  </details>

* **Prefer throwing or optional intializers over optional properties that should have a value.**
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

* **Prefer implicitly unwrapped optionals when a value can be safely assumed.**
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
  
* <a id='prefer-immutable-values'></a>(<a href='#prefer-immutable-values'>link</a>) **Prefer immutable values whenever possible.** Use `map` and `compactMap` instead of appending to a new collection. Use `filter` instead of removing elements from a mutable collection.

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

* <a id='static-type-methods-by-default'></a>(<a href='#static-type-methods-by-default'>link</a>) **Default type methods to `static`.**

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

* <a id='final-classes-by-default'></a>(<a href='#final-classes-by-default'>link</a>) **Default classes to `final`.**

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

* <a id='switch-never-default'></a>(<a href='#switch-never-default'>link</a>) **Never use the `default` case when `switch`ing over an enum.**

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

* <a id='optional-nil-check'></a>(<a href='#optional-nil-check'>link</a>) **Check for nil rather than using optional binding if you don't need to use the value.** [![SwiftLint: unused_optional_binding](https://img.shields.io/badge/SwiftLint-unused_optional_binding-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#unused-optional-binding)

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

* <a id='omit-return'></a>(<a href='#omit-return'>link</a>) **Omit the `return` keyword when not required by the language.** [![SwiftFormat: redundantReturn](https://img.shields.io/badge/SwiftFormat-redundantReturn-7B0051.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#redundantReturn)

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

* <a id='use-anyobject'></a>(<a href='#use-anyobject'>link</a>) **Use `AnyObject` instead of `class` in protocol definitions.** [![SwiftFormat: anyObjectProtocol](https://img.shields.io/badge/SwiftFormat-anyObjectProtocol-7B0051.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#anyobjectprotocol)

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

* <a id='extension-access-control'></a>(<a href='#extension-access-control'>link</a>) **Specify the access control for each declaration in an extension individually.** [![SwiftFormat: extensionAccessControl](https://img.shields.io/badge/SwiftFormat-extensionAccessControl-7B0051.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#extensionaccesscontrol)

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

* <a id='limit-vertical-whitespace'></a>(<a href='#limit-vertical-whitespace'>link</a>) **Limit empty vertical whitespace to one line.** Favor the following formatting guidelines over whitespace of varying heights to divide files into logical groupings. [![SwiftLint: vertical_whitespace](https://img.shields.io/badge/SwiftLint-vertical__whitespace-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#vertical-whitespace)

* <a id='newline-at-eof'></a>(<a href='#newline-at-eof'>link</a>) **Files should end in a newline.** [![SwiftLint: trailing_newline](https://img.shields.io/badge/SwiftLint-trailing__newline-007A87.svg)](https://github.com/realm/SwiftLint/blob/master/Rules.md#trailing-newline)

* <a id='subsection-organization'></a>(<a href='#subsection-organization'>link</a>) **Within each top-level section, place content in the following order.** This allows a new reader of your code to more easily find what they are looking for. [![SwiftFormat: organizeDeclarations](https://img.shields.io/badge/SwiftFormat-organizeDeclarations-008489.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#organizeDeclarations)
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

* <a id='newline-between-subsections'></a>(<a href='#newline-between-subsections'>link</a>) **Add empty lines between property declarations by logical group.** (e.g. between static properties and instance properties.) [![SwiftFormat: organizeDeclarations](https://img.shields.io/badge/SwiftFormat-organizeDeclarations-008489.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#organizeDeclarations)

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

* <a id='computed-properties-at-end'></a>(<a href='#computed-properties-at-end'>link</a>) **Computed properties and properties with property observers should appear at the end of the set of declarations of the same kind.** (e.g. instance properties.) [![SwiftFormat: organizeDeclarations](https://img.shields.io/badge/SwiftFormat-organizeDeclarations-008489.svg)](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md#organizeDeclarations)

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

* <a id='prefer-pure-swift-classes'></a>(<a href='#prefer-pure-swift-classes'>link</a>) **Prefer pure Swift classes over subclasses of NSObject.** If your code needs to be used by some Objective-C code, wrap it to expose the desired functionality. Use `@objc` on individual methods and variables as necessary rather than exposing all API on a class to Objective-C via `@objcMembers`.

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
This styleguide was forked from the [AirBnB styleguide](https://github.com/airbnb/swift). Thanks AirBnB!
