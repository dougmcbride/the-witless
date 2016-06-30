// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

extension SequenceType where Generator.Element == Thing {
    func countThing(t: Thing) -> Int {
        return filter({ $0 == t }).count
    }
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

    static func parseStars(string: String) -> [[Thing]] {
        return string.characters.split("/").map {
            $0.map {
                .Star(Color(rawValue: String($0))!)
            }
        }
    }

    static func parseSquares(string: String) -> [[Thing]] {
        return string.characters.split("/").map {
            $0.map {
                .Square(Color(rawValue: String($0))!)
            }
        }
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
