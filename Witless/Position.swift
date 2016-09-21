// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

typealias Region = Set<Position>

struct Segment {
    let positions: Set<Position>

    init(_ p1: Position, _ p2: Position) {
        self.positions = [p1, p2]
    }

    func contains(x: Int, _ y: Int) -> Bool {
        guard let position = positions.first?.makePosition(x, y) else {
            return false
        }
        return positions.contains(position)
    }

    var minX: Int {
        return positions.reduce(Int.max) {
            running, position in
            return min(running, position.x)
        }
    }

    var column: Int? {
        return positions.reduce(nil) {
            running, position in
            if running == nil {
                return position.x
            } else if position.x == running {
                return running
            } else {
                return nil
            }
        }
    }

    var row: Int? {
        return positions.reduce(nil) {
            running, position in
            if running == nil {
                return position.y
            } else if position.y == running {
                return running
            } else {
                return nil
            }
        }
    }
}

extension Segment: Hashable {
    var hashValue: Int {
        return positions.reduce(51) {
            running, current in
            running * 51 + current.hashValue
        }
    }
}

func ==(s1:Segment, s2:Segment) -> Bool {
    return s1.positions == s2.positions
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
//        print("  \(self).positionByMoving(\(move)) = ", terminator: "")
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

//        print(position)
        return position
    }

    func makePosition(x: Int, _ y: Int) -> Position? {
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

        return Segment(effectivePosition, effectivePosition.positionByMoving(move)!)
    }

    var borderingSegments: Set<Segment> {
        // TODO cache this
        let topSegment = Segment(makePosition(x, y)!, makePosition(x + 1, y)!)
        let bottomSegment = Segment(makePosition(x, y + 1)!, makePosition(x + 1, y + 1)!)
        let leftSegment = Segment(makePosition(x, y)!, makePosition(x, y + 1)!)
        let effectiveRightX: Int
        if x == width - 1 && xWrapping {
            effectiveRightX = 0
        } else {
            effectiveRightX = x + 1
        }
        let rightSegment = Segment(makePosition(effectiveRightX, y)!,
                                   makePosition(effectiveRightX, y + 1)!)

        return [topSegment, bottomSegment, leftSegment, rightSegment]
    }
}

extension Position: Equatable {
}

extension RawPosition: Hashable, Equatable {
    var hashValue: Int {
        return (51 + x.hashValue) * 51 + y.hashValue
    }
}

extension Position: Hashable {
    var hashValue: Int {
        return rawPosition.hashValue
    }
}

func ==(lhs: RawPosition, rhs: RawPosition) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.rawPosition == rhs.rawPosition
}