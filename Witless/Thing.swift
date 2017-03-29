// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

import Foundation

extension Sequence where Iterator.Element == Thing {
    func countThing(_ t: Thing) -> Int {
        return filter({ $0 == t }).count
    }
}

enum ParsingError: Error {
    case unknownSymbol
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
    case empty
    case star(Color)
    case square(Color)
    case triangle(Int)

    static func parse(_ string: String) throws -> [[Thing]] {
        return try string.characters.split(separator: "/").map { (sequence: AnySequence<Character>) in
            try sequence.map { (s: Character) -> Thing in
                let charString = String(s)
                switch charString {
                    case "E", "e", " ":
                        return .empty
                    case "1", "2", "3":
                        return .triangle(Int(charString)!)
                    default:
                        let uppercaseString = charString.uppercased()
                        if uppercaseString == charString {
                            return .square(try colorForSymbol(charString))
                        } else {
                            return .star(try colorForSymbol(charString))
                        }
                }
            }
        }
    }

    static fileprivate func colorForSymbol(_ symbol: String) throws -> Color {
        let uppercaseString = symbol.uppercased()
        guard let color = Color(rawValue: uppercaseString) else {
            throw ParsingError.unknownSymbol
        }
        return color
    }

    var caresAboutRegions: Bool {
        switch self {
            case .square, .star:
                return true
            default:
                return false
        }
    }
}

func ==(a: Thing, b: Thing) -> Bool {
    switch (a, b) {
        case (.empty, .empty):
            return true
        case (.star(let c1), .star(let c2)):
            return c1 == c2
        case (.square(let c1), .square(let c2)):
            return c1 == c2
        default:
            return false
    }
}
