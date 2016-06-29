// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

typealias Region = Set<Position>

struct Move {
    let from, to: Position
}

struct Position {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

extension Position: Equatable {
}

extension Position: Hashable {
    var hashValue: Int {
        return x.hashValue + y.hashValue
    }
}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}