//: Playground - noun: a place where people can play

import UIKit

// That's a good start
print("Hello, playground")

/*
 // Variables and Constants
 */

var myVariable = 42
myVariable = 50
let myConstant = 42

let implicitInteger = 70
let implicitDouble = 70.0
let explicitDouble: Double = 70

// Explicit casting
let label = "The width is "
let width = 94
let widthLabel = label + String(width)

let widthLabel2 = "The width is \(width)"


/*
 // Arrays and Dictionaries
 */

var shoppingList = ["catfish", "water", "tulips", "blue paint"]
shoppingList[1] = "bottle of water"

var occupations = [
    "Malcolm": "Captain",
    "Kaylee": "Mechanic",
]
occupations["Jayne"] = "Public Relations"

// Empty Arrays
let emptyArray = [String]()
shoppingList = []

// Empty Dictionaries
let emptyDictionary = [String: Float]()
occupations = [:]


/*
 // Optionals
 */

var optionalString: String? = "Hello"
print(optionalString == nil)

var optionalName: String? = "John Appleseed"
var greeting = "Hello!"
if let name = optionalName {
    greeting = "Hello, \(name)"
}

var nickName: String? = nil
let fullName: String = "John Appleseed"
let informalGreeting = "Hi \(nickName ?? fullName)"


/*
 // Control Flow
 */

// if
let individualScores = [75, 43, 103, 87, 12]
var teamScore = 0
for score in individualScores {
    if score > 50 {
        teamScore += 3
    } else {
        teamScore += 1
    }
}
print(teamScore)

// Switch
let vegetable = "red pepper"
switch vegetable {
case "celery":
    print("Add some raisins and make ants on a log.")
case "cucumber", "watercress":
    print("That would make a good tea sandwich.")
case let x where x.hasSuffix("pepper"): // let can be used here
    print("Is it a spicy \(x)?")
default:  // Always present!
    print("Everything tastes good in soup.")
}

// for in
let interestingNumbers = [
    "Prime": [2, 3, 5, 7, 11, 13],
    "Fibonacci": [1, 1, 2, 3, 5, 8],
    "Square": [1, 4, 9, 16, 25],
]
var largest = 0
for (kind, numbers) in interestingNumbers {
    for number in numbers {
        if number > largest {
            largest = number
        }
    }
}
print(largest)


var total = 0
for i in 0..<4 { // ... includes both values
    total += i
}
print(total)

// while
var n = 2
while n < 100 {
    n = n * 2
}
print(n)

var m = 2
repeat {
    m = m * 2
} while m < 100
print(m)


/*
 // Functions and Closures
 */

func greet(name: String, day: String) -> String {
    return "Hello \(name), today is \(day)."
}
greet("Bob", day: "Tuesday")

// It returns a tuple
func calculateStatistics(scores: [Int]) -> (min: Int, max: Int, sum: Int) {
    var min = scores[0]
    var max = scores[0]
    var sum = 0
    
    for score in scores {
        if score > max {
            max = score
        } else if score < min {
            min = score
        }
        sum += score
    }
    
    return (min, max, sum)
}
let statistics = calculateStatistics([5, 3, 100, 3, 9])
print(statistics.sum)
print(statistics.2)

// Variable number of arguments, collecting them into an array
func sumOf(numbers: Int...) -> Int {
    var sum = 0
    for number in numbers {
        sum += number
    }
    return sum
}
sumOf()
sumOf(42, 597, 12)

// Nested functions
func returnFifteen() -> Int {
    var y = 10
    func add() {
        y += 5
    }
    add()
    return y
}
returnFifteen()

// Functions are a first-class type. This means that a function can return another function as its value.
func makeIncrementer() -> ((Int) -> Int) {
    func addOne(number: Int) -> Int {
        return 1 + number
    }
    return addOne
}
var increment = makeIncrementer()
increment(7)

// A function can take another function as one of its arguments.
func hasAnyMatches(list: [Int], condition: (Int) -> Bool) -> Bool {
    for item in list {
        if condition(item) {
            return true
        }
    }
    return false
}
func lessThanTen(number: Int) -> Bool {
    return number < 10
}
var numbers = [20, 19, 7, 12]
hasAnyMatches(numbers, condition: lessThanTen)

// Functions are actually a special case of closures: blocks of code that can be called later
// You can write a closure without a name by surrounding code with braces ({}).
// Use in to separate the arguments and return type from the body.
numbers.map({
    (number: Int) -> Int in // (parameters) -> return type in
    let result = 3 * number //  statements
    return result
})

// When a closure’s type is already known, such as the callback for a delegate, you can omit
// the type of its parameters, its return type, or both
let mappedNumbers = numbers.map({ number in 3 * number })
print(mappedNumbers)

let sortedNumbers = numbers.sort { $0 > $1 }
print(sortedNumbers)

let reversedNumbers = numbers.sort(>)
print(reversedNumbers)

/*
 // Object and Classes
 */

class Shape {
    var numberOfSides = 0
    func simpleDescription() -> String {
        return "A shape with \(numberOfSides) sides."
    }
}

var shape = Shape()
shape.numberOfSides = 7
var shapeDescription = shape.simpleDescription()

// initialiser
class NamedShape {
    var numberOfSides: Int = 0
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func simpleDescription() -> String {
        return "A shape with \(numberOfSides) sides."
    }
    
    deinit {
        // Perform some cleanup
    }
}

// Inheritance
class Square: NamedShape {
    var sideLength: Double
    
    init(sideLength: Double, name: String) {
        self.sideLength = sideLength
        super.init(name: name)
        numberOfSides = 4
    }
    
    func area() ->  Double {
        return sideLength * sideLength
    }
    
    override func simpleDescription() -> String {
        return "A square with sides of length \(sideLength)."
    }
}
let test = Square(sideLength: 5.2, name: "my test square")
test.area()
test.simpleDescription()

// Properties
class EquilateralTriangle: NamedShape {
    var sideLength: Double = 0.0
    
    init(sideLength: Double, name: String) {
        self.sideLength = sideLength
        super.init(name: name)
        numberOfSides = 3
    }
    
    var perimeter: Double {
        get {
            return 3.0 * sideLength
        }
        set {
            sideLength = newValue / 3.0
        }
    }
    
    override func simpleDescription() -> String {
        return "An equilateral triangle with sides of length \(sideLength)."
    }
}
var triangle = EquilateralTriangle(sideLength: 3.1, name: "a triangle")
print(triangle.perimeter)
triangle.perimeter = 9.9
print(triangle.sideLength)

// If the value before the ? is nil, everything after the ? is ignored and the value of
// the whole expression is nil. Otherwise, the optional value is unwrapped, and everything
// after the ? acts on the unwrapped value
let optionalSquare: Square? = Square(sideLength: 2.5, name: "optional square")
let sideLength = optionalSquare?.sideLength

// Use ? if the value can become nil in the future, so that you test for this.
// Use ! if it really shouldn't become nil in the future, but it needs to be nil initially.


/*
 // Enumerations and Structures
 */

// Enumerations can have methods
enum Rank: Int {
    case Ace = 1
    case Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten
    case Jack, Queen, King
    func simpleDescription() -> String {
        switch self {
        case .Ace:
            return "ace"
        case .Jack:
            return "jack"
        case .Queen:
            return "queen"
        case .King:
            return "king"
        default:
            return String(self.rawValue)
        }
    }
}
let ace = Rank.Ace
let aceRawValue = ace.rawValue

// Can use init?(rawValue:)
if let convertedRank = Rank(rawValue: 3) {
    let threeDescription = convertedRank.simpleDescription()
}

// I could have no raw values at all
enum Suit {
    case Spades, Hearts, Diamonds, Clubs
    func simpleDescription() -> String {
        switch self {
        case .Spades:
            return "spades"
        case .Hearts:
            return "hearts"
        case .Diamonds:
            return "diamonds"
        case .Clubs:
            return "clubs"
        }
    }
}
let hearts = Suit.Hearts
let heartsDescription = hearts.simpleDescription()

// Struct
// One of the most important differences between structures and classes is that structures
// are always copied when they are passed around in your code, but classes are passed by reference.
struct Card {
    var rank: Rank
    var suit: Suit
    func simpleDescription() -> String {
        return "The \(rank.simpleDescription()) of \(suit.simpleDescription())"
    }
}
let threeOfSpades = Card(rank: .Three, suit: .Spades)
let threeOfSpadesDescription = threeOfSpades.simpleDescription()


/*
 // Protocol and Extensions
 */

// Define a new Protocol
protocol ExampleProtocol {
    var simpleDescription: String { get }
    mutating func adjust()
}

// Classes, enumerations, and structs can all adopt protocols.
class SimpleClass: ExampleProtocol {
    var simpleDescription: String = "A very simple class."
    var anotherProperty: Int = 69105
    func adjust() {
        simpleDescription += "  Now 100% adjusted."
    }
}
var a = SimpleClass()
a.adjust()
let aDescription = a.simpleDescription

struct SimpleStructure: ExampleProtocol {
    var simpleDescription: String = "A simple structure"
    mutating func adjust() {
        simpleDescription += " (adjusted)"
    }
}
var b = SimpleStructure()
b.adjust()
let bDescription = b.simpleDescription

// Extensions: add functionality to an existing type
extension Int: ExampleProtocol {
    var simpleDescription: String {
        return "The number \(self)"
    }
    mutating func adjust() {
        self += 42
    }
}
print(7.simpleDescription)


/*
 // Delegation
 */
// Delegation is a design pattern that enables a class or structure to hand off
// (or delegate) some of its responsibilities to an instance of another type.


protocol ProtocolDelegate {
    func start() -> String
    func stop() -> String
}

class Class {
    var delegate: ProtocolDelegate?
    
    func doSomething() -> String {
        let start = delegate?.start() ?? ""
        let stop = delegate?.stop() ?? ""
        return "\(start) doSomething \(stop)"
    }
}

class ProtocolHandler: ProtocolDelegate {
    func start() -> String {
        return "start"
    }
    func stop() -> String {
        return "stop"
    }
}

class ProtocolHandler2: ProtocolDelegate {
    func start() -> String {
        return "start2"
    }
    func stop() -> String {
        return "stop2"
    }
}

let c = Class()
// Assign the delegate
c.delegate = ProtocolHandler()
c.doSomething()

// Change of the delegate
c.delegate = ProtocolHandler2()
c.doSomething()

/*
 // Error Handling
 */

enum PrinterError: ErrorType {
    case OutOfPaper
    case NoToner
    case OnFire
}

// Use throw to throw an error and throws to mark a function that can throw an error.
func sendToPrinter(printerName: String) throws -> String {
    if printerName == "Never Has Toner" {
        throw PrinterError.NoToner
    }
    return "Job sent"
}

do {
    let printerResponse = try sendToPrinter("Bi Sheng")
    print(printerResponse)
} catch {
    print(error)
}

// Multiple catch
do {
    let printerResponse = try sendToPrinter("Gutenberg")
    print(printerResponse)
} catch PrinterError.OnFire {
    print("I'll just put this over here, with the rest of the fire.")
} catch let printerError as PrinterError {
    print("Printer error: \(printerError).")
} catch {
    print(error)
}

// With optionals
let printerSuccess = try? sendToPrinter("Mergenthaler")
let printerFailure = try? sendToPrinter("Never Has Toner")


// Defer: Use defer to write a block of code that is executed after all other code in
// the function, just before the function returns
var fridgeIsOpen = false
let fridgeContent = ["milk", "eggs", "leftovers"]

func fridgeContains(itemName: String) -> Bool {
    fridgeIsOpen = true
    defer {
        fridgeIsOpen = false
    }
    
    let result = fridgeContent.contains(itemName)
    return result
}
fridgeContains("banana")
print(fridgeIsOpen)

/*
 // Generics
 */

func repeatItem<Item>(item: Item, numberOfTimes: Int) -> [Item] {
    var result = [Item]()
    for _ in 0..<numberOfTimes {
        result.append(item)
    }
    return result
}
repeatItem("knock", numberOfTimes:4)
repeatItem(1, numberOfTimes:4)
