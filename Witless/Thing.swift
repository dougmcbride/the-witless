// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

extension SequenceType where Generator.Element == Thing {
    func countThing(t: Thing) -> Int {
        return filter({ $0 == t }).count
    }
}

enum ParsingError: ErrorType {
    case UnknownSymbol
}

enum Color: String {
    case White = "W"
    case Black = "K"
    case Green = "G"
    case Red = "R"
    case Blue = "B"
    case Yellow = "Y"
    case Purple = "P"
}

enum Thing: Equatable {
    case Empty
    case Star(Color)
    case Square(Color)
    case Triangle(Int)

    static func parse(string: String) throws -> [[Thing]] {
        return try string.characters.split("/").map {
            try $0.map {
                let charString = String($0)
                switch charString {
                    case "E":
                        return .Empty
                    case "1", "2", "3":
                        return .Triangle(Int(charString)!)
                    default:
                        let uppercaseString = charString.uppercaseString
                        if uppercaseString == charString {
                        return .Square(try colorForSymbol(charString))
                        } else {
                        return .Star(try colorForSymbol(charString))
                    }
                        }
                }
            }
        }

    static private func colorForSymbol(symbol: String) throws -> Color {
        let uppercaseString = symbol.uppercaseString
        guard let color = Color(rawValue: uppercaseString) else {
            throw ParsingError.UnknownSymbol
        }
        return color

    }
}

func ==(a: Thing, b: Thing) -> Bool {
    switch (a, b) {
        case (.Empty, .Empty):
            return true
        case (.Star(let c1), .Star(let c2)):
            return c1 == c2
        case (.Square(let c1), .Square(let c2)):
            return c1 == c2
        default:
            return false
    }
}
