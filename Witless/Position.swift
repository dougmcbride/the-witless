// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

typealias Region = Set<Position>

struct Segment {
    let from, to: Position
}

enum Move: String {
    case Up = "U"
    case Down = "D"
    case Left = "L"
    case Right = "R"

    static let allMoves: [Move] = [.Up, .Down, .Left, .Right]
}

struct Position {
    let x: Int
    let y: Int
    let width: Int
    let height: Int

    init(_ x: Int, _ y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    func positionByMoving(move: Move) -> Position {
        let position: Position
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

    private func makePosition(x: Int, _ y: Int) -> Position {
        return Position(x, y, width: width, height: height)
    }

    func effectiveSegmentForMove(move: Move) -> Segment {
        let effectivePosition: Position

        switch (move, x) {
            case (.Left, 0):
                effectivePosition = Position(width, y, width: width, height: height)
            default:
                effectivePosition = self
        }

        return Segment(from: effectivePosition, to: effectivePosition.positionByMoving(move))
    }

    func validPosition(width: Int, height: Int, wrapping: Bool = false) -> Position? {
        let xRange = wrapping ? (-1 ..< width) : 0 ..< width
        let effectiveWidth = wrapping ? width - 1 : width
        if xRange.contains(x) && (0 ..< height).contains(y) {
            let answer = Position((x + effectiveWidth) % effectiveWidth, y, width: width, height: height)
            return answer
        }

        return nil
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