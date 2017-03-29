// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

import Foundation

struct Path {
    let startPosition: Position
    let moves: [Move]
    let positions: [Position]
    let segments: [Segment]

    var movesString: String {
        return moves.map{$0.rawValue}.joined(separator: "")
    }

    var wasdMovesString: String {
        return moves.map{$0.wasdValue()}.joined(separator: "")
    }

    init(startPosition: Position, moves: [Move], board: Board) {
        self.startPosition = startPosition
        self.moves = moves

        self.positions = moves.reduce([startPosition]) {
            running, move in
            let nextPosition = board.pathPosition(from: running.last!, moving: move)!
            return running + [nextPosition]
        }

        self.segments = zip(positions.dropLast(), moves).reduce([]) { (running, tuple) -> [Segment] in
            let (position, move) = tuple
            return running + [board.segment(fromPosition: position, withMove: move)]
        }
    }

    init(startPosition: Position, movesString: String, board: Board) {
        self.init(startPosition: startPosition, moves: movesString.characters.map { Move(rawValue: String($0))! }, board: board)
    }

    init(startPosition: Position, board: Board) {
        self.init(startPosition: startPosition, moves: [], board: board)
    }

    func contains(_ position: Position) -> Bool {
        return positions.contains {
            $0 == position
        }
    }

    func path(addingMove move: Move, onBoard board: Board) -> Path {
        return Path(startPosition: startPosition, moves: moves + [move], board: board)
    }

    func doesNotIntersectItselfByAddingMove(_ move: Move, toBoard board: Board) -> Bool {
        guard let lastPosition = positions.last else {
            return true
        }

        let allowed = !positions.contains(board.pathPosition(from: lastPosition, moving: move)!)
        //print("path \(movesString), move \(move.rawValue) -> \(lastPosition.positionByMoving(move)!.rawPosition), \(allowed ? "ok" : "NOPE")")
        return allowed
    }
}

func ==(p1: Path, p2: Path) -> Bool {
    return p1.startPosition == p2.startPosition &&
            p1.moves == p2.moves
}
