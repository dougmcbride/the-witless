// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

import Foundation

typealias Region = Set<Position>

struct Segment {
    let position1: Position
    let position2: Position

    init(_ p1: Position, _ p2: Position) {
        self.position1 = p1
        self.position2 = p2
    }

    func contains(_ x: Int, _ y: Int) -> Bool {
        return (position1.x == x && position1.y == y) ||
               (position2.x == x && position2.y == y)
    }

    var minX: Int {
        return min(position1.x, position2.x)
    }

    var column: Int? {
        return (position1.x == position2.x) ? position2.x : nil
    }

    var row: Int? {
        return (position1.y == position2.y) ? position2.y : nil
    }
}

extension Segment: Equatable {
}

extension Segment: Hashable {
    var hashValue: Int {
        return 51 * position1.hashValue + 51 * position2.hashValue
    }
}

func ==(s1: Segment, s2: Segment) -> Bool {
    return (s1.position1 == s2.position1 && s1.position2 == s2.position2) ||
           (s1.position1 == s2.position2 && s1.position2 == s2.position1)
}

enum Move: String {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"

    func wasdValue() -> String {
      switch self {
          case .up:
              return "W"
          case .down:
              return "S"
          case .left:
              return "A"
          case .right:
              return "D"
      }
    }

    static let allMoves: [Move] = [.up, .down, .left, .right]
}

struct Position {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

extension Position: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
}

extension Position: Equatable {
}

extension Position: Hashable {
    var hashValue: Int {
        return (51 + x.hashValue) * 51 + y.hashValue
    }
}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
