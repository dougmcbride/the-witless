// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

extension SequenceType where Generator.Element == Thing {
    func countThing(t: Thing) -> Int {
        return filter({ $0 == t }).count
    }
}

enum Color {
    static let initials: [Color:String] = [
            .White: "W", .Black: "K",
            .Green: "G", .Red: "R",
            .Blue: "B", .Yellow: "Y",
            .Purple: "P"]

    case White, Black, Green, Red, Blue, Yellow, Purple

    var initial: String {
        return Color.initials[self]!
    }
}

enum Thing: Equatable {
    case Empty
    case Star(Color)
    case Square(Color)
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
