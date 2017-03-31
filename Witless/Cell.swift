// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

import Foundation

extension Sequence where Iterator.Element == Cell {
    func countCell(_ t: Cell) -> Int {
        return filter({ $0 == t }).count
    }
}

enum ParsingError: Error {
    case unknownCharacter(Character)

    var localizedDescription: String {
        switch self {
            case .unknownCharacter(let c):
                return "Invalid character '\(c)'"
        }
    }
}


enum Cell: Equatable {
    typealias Color = Character

    case empty
    case star(Color)
    case square(Color)
    case triangle(Int)

    /// Parse a /-delimited String into rows of cells
    static func parse(_ string: String) throws -> [[Cell]] {
        return try string.characters.split(separator: "/").map { (sequence: AnySequence<Character>) in
            try sequence.map { (character: Character) -> Cell in
                let charString = String(character)
                switch charString {
                    case "E", "e", " ", ".":
                        return .empty
                    case "1", "2", "3":
                        return .triangle(Int(charString)!)
                    case "A"..."Z":
                        return .square(character)
                    case "a"..."z":
                        return .star(character)
                    default:
                        throw ParsingError.unknownCharacter(character)
                }
            }
        }
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

func ==(a: Cell, b: Cell) -> Bool {
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
