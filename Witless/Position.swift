// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

typealias Region = Set<Position>

struct Segment: Equatable {
    let from, to: Position
}

func ==(s1:Segment, s2:Segment) -> Bool {
    return s1.from == s2.from && s1.to == s2.to
}

enum Move: String {
    case Up = "U"
    case Down = "D"
    case Left = "L"
    case Right = "R"

    static let allMoves: [Move] = [.Up, .Down, .Left, .Right]
}

struct RawPosition {
    let x: Int
    let y: Int
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

struct Position {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    let xWrapping: Bool
    var rawPosition: RawPosition {
        return RawPosition(x, y)
    }

    init(_ x: Int, _ y: Int, width: Int, height: Int, xWrapping: Bool) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.xWrapping = xWrapping
    }

    func positionByMoving(move: Move) -> Position? {
        let position: Position?
        switch move {
            case .Down:
                position = makePosition(x, y + 1)
            case .Up:
                position = makePosition(x, y - 1)
            case .Left:
                position = makePosition(x - 1, y)
            case .Right:
                position = makePosition(x + 1, y)
        }

        return position
    }

    private func makePosition(x: Int, _ y: Int) -> Position? {
        let xRange = xWrapping ? (-1 ..< width) : 0 ..< width
        if xRange.contains(x) && (0 ..< height).contains(y) {
            let answer = Position((x + width) % width, y, width: width, height: height, xWrapping: xWrapping)
            return answer
        }

        return nil
    }

    func effectiveSegmentForMove(move: Move) -> Segment {
        let effectivePosition: Position

        switch (move, x) {
            case (.Left, 0):
                effectivePosition = Position(width, y, width: width, height: height, xWrapping: xWrapping)
            default:
                effectivePosition = self
        }

        return Segment(from: effectivePosition, to: effectivePosition.positionByMoving(move)!)
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