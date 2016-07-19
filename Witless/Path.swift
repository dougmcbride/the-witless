// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

struct Path {
    let startPosition: Position
    let moves: [Move]
    let positions: [Position]
    let segments: [Segment]

    init(startPosition: Position, moves: [Move]) {
        self.startPosition = startPosition
        self.moves = moves
        self.positions = moves.reduce([startPosition]) {
            running, direction in
            let nextPosition = running.last!.positionByMoving(direction)!
            return running + [nextPosition]
        }
        self.segments = zip(positions.dropLast(), moves).reduce([]) {
            running, tuple in
            let (position, move) = tuple
            return running + [position.effectiveSegmentForMove(move)]
        }
    }

    init(startPosition: Position, movesString: String) {
        self.init(startPosition: startPosition, moves: movesString.characters.map {
            Move(rawValue: String($0))!
        })
    }

    init(startPosition: Position) {
        self.init(startPosition: startPosition, moves: [])
    }

    func contains(position: Position) -> Bool {
        return positions.contains {
            $0 == position
        }
    }

    func pathAddingMove(move: Move) -> Path {
        return Path(startPosition: startPosition, moves: moves + [move])
    }

    func doesNotIntersectItselfByAddingMove(move: Move) -> Bool {
        guard let lastPosition = positions.last else {
            return true
        }

        return !positions.contains(lastPosition.positionByMoving(move)!)
    }
}

func ==(p1: Path, p2: Path) -> Bool {
    return p1.startPosition == p2.startPosition &&
            p1.moves == p2.moves
}