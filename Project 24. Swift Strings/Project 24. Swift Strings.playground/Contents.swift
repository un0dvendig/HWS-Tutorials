import UIKit

let string = "This is a test string"

string.hasPrefix("This ")

// Challenge 1
extension String {
    func withPrefix(_ prefix: String) -> String {
        guard !self.hasPrefix(prefix) else { return self }
        
        return prefix + self
    }
}

let carpet = "carpet"
let car = "car"
let pet = "pet"

pet.withPrefix(car)
pet.withPrefix(pet)
carpet.withPrefix(car)
carpet.withPrefix(pet)

// Challenge 2
extension String {
    var isNumeric: Bool {
        guard !self.isEmpty else { return false }
        
        guard (Double(self) != nil) else { return false }
        return true
    }
}

let empty = ""
let number = "number"
let number1 = "number1"
let just1 = "1"
let just10 = "1.9"

empty.isNumeric
number.isNumeric
number1.isNumeric
just1.isNumeric
just10.isNumeric

// Challenge 3
extension String {
    var lines: [String] {
        guard !self.isEmpty else { return [self] }
        
        return self.components(separatedBy: "\n")
    }
}

let test = "test"
test.lines

let testntest = "test\ntest"
testntest.lines

let example = "this\nis\na\ntest"
example.lines
