//  The Witless
//  Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

extension SequenceType where Generator.Element == Thing {
    func countThing(t: Thing) -> Int {
        return filter({ $0 == t }).count
    }
}

enum Thing {
    case Empty
    case BlackStar
    case WhiteSquare
    case BlackSquare
}

struct Board {
    let width: Int
    let height: Int
    let startPositions: [Position]
    let endPositions: [Position]
    let path: Path
    let things: [[Thing]]

    var thingWidth: Int {
        return width - 1
    }

    var thingHeight: Int {
        return height - 1
    }

    init(start: Position, end: Position, things: [[Thing]]) {
        self.init(width: 5, height: 5, start: start, end: end, things: things)
    }

    init(width: Int, height: Int, start: Position, end: Position, things: [[Thing]]) {
        self.init(width: width, height: height, startPositions: [start], endPositions: [end], path: Path(positions: [start]), things: things)
    }

    init(width: Int, height: Int, startPositions: [Position], endPositions: [Position], path: Path, things: [[Thing]]) {
        self.width = width
        self.height = height
        self.path = path
        self.startPositions = startPositions
        self.endPositions = endPositions
        self.things = things
    }

    func possibleBoards() -> [Board] {
        guard let lastMove = path.positions.last else {
            return startingMoves().map {
                move($0)
            }
        }

        let moves = possibleMovesFrom(lastMove).filter {
            move in
            return !path.contains(move)
        }

        return moves.map {
            move($0)
        }
    }

    func possibleAdjacentsFrom(p: Position) -> [Position] {
        return [
                Position(p.x - 1, p.y),
                Position(p.x + 1, p.y),
                Position(p.x, p.y - 1),
                Position(p.x, p.y + 1),
        ].filter {
            return (0 ..< width - 1).contains($0.x) && (0 ..< height - 1).contains($0.y)
        }
    }

    func possibleMovesFrom(p: Position) -> [Position] {
        return [
                Position(p.x - 1, p.y),
                Position(p.x + 1, p.y),
                Position(p.x, p.y - 1),
                Position(p.x, p.y + 1),
        ].filter {
            isValidPosition($0)
        }
    }

    private func startingMoves() -> [Position] {
        return startPositions.flatMap {
            self.possibleMovesFrom($0)
        }
    }

    func startingPaths() -> [Path] {
        return startingMoves().map({ Path(positions: [$0]) })
    }

    func isValidPosition(p: Position) -> Bool {
        return (0 ..< width).contains(p.x) && (0 ..< height).contains(p.y)
    }

    func move(move: Position) -> Board {
        let newPath = path.add(move)
        return Board(width: width, height: height, startPositions: startPositions, endPositions: endPositions, path: newPath, things: things)
    }

    var succeeded: Bool {
        guard let lastMove = path.positions.last else {
            return false
        }

        if !endPositions.contains({
            $0 == lastMove
        }) {
            return false
        }

        let (rThings, r) = regionThings()
        for things in rThings {
            if things.contains(.WhiteSquare) && things.contains(.BlackSquare) {
                return false
            }

            switch (things.countThing(.BlackStar), things.countThing(.BlackSquare)) {
                case (0, _):
                    break
                case (1, 1):
                    break
                case (1, _):
                    return false
                case (2, 0):
                    break
                default:
                    return false
            }
        }

//        ASCIIRenderer().drawBoard(self)
//        ASCIIRenderer().drawBoard(self, regionMap: r)
        return true
    }

    var failed: Bool {
        return possibleBoards().isEmpty
    }

    func regionThings() -> ([[Thing]], [Position:Region]) {
        let r = regions()
        return (r.values.map {
            (region) in
            return region.positions.map {
                return things[$0.y][$0.x]
            }
        }, r)
    }

    func regions() -> [Position:Region] {
        var regionMap = [Position: Region]()

        for x in 0 ..< (width - 1) {
            for y in 0 ..< (height - 1) {
                let p = Position(x, y)
                if regionMap[p] != nil {
                    continue
                }
                let set: Set<Position> = [p]
                let newRegion = Region(positions: set.union(reachablePositionsFrom(p, done: set)))
                for position in newRegion.positions {
                    regionMap[position] = newRegion
                }
            }
        }

        return regionMap
    }

    private func reachablePositionsFrom(from: Position, done: Set<Position> = []) -> Set<Position> {
        let moves = possibleAdjacentsFrom(from).filter {
            !done.contains($0)
        }.filter {
            to in
            let targetDelta = (abs(to.y - from.y), abs(to.x - from.x))

            let (px, py): (Int, Int) = {
                switch targetDelta {
                    case (0, 1):
                        return (max(from.x, to.x), min(from.y, to.y))
                    case (1, 0):
                        return (min(from.x, to.x), max(from.y, to.y))
                    default:
                        fatalError("bad delta")
                }
            }()

            return !path.moves.contains {
                move in
                let p1 = Position(px, py)
                let p2 = Position(px + targetDelta.0, py + targetDelta.1)
                return (move.from == p1 && move.to == p2) || (move.from == p2 && move.to == p1)
            }
        }

        if moves.isEmpty {
            return []
        } else {
            let set: Set<Position> = Set(moves)
            return set.union(moves.flatMap {
                self.reachablePositionsFrom($0, done: done.union(moves))
            })
        }
    }
}

struct Region {
    let positions: Set<Position>
}

struct Path {
    let positions: [Position]

    init(positions: [Position] = []) {
        self.positions = positions
    }

    var moves: [Move] {
        let length = positions.count - 1

        if length < 0 {
            return []
        }

        let a = positions.prefix(length)
        let b = positions.suffix(length)
        return zip(a, b).map {
            Move(from: $0.0, to: $0.1)
        }
    }

    func contains(position: Position) -> Bool {
        return positions.contains {
            $0 == position
        }
    }

    func add(position: Position) -> Path {
        var newPositions = positions
        newPositions.append(position)
        return Path(positions: newPositions)
    }
}

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

let things: [[Thing]] = [
        [.BlackStar,   .Empty,       .Empty,       .BlackSquare],
        [.WhiteSquare, .WhiteSquare, .BlackStar,       .Empty],
        [.BlackSquare, .Empty,       .WhiteSquare, .Empty],
        [.Empty      , .BlackSquare, .WhiteSquare, .BlackStar],
]

let board = Board(width: 5, height: 5, start: Position(2, 4), end: Position(4, 0), things: things)

func successfulBoards(board: Board) -> [Board] {
    let possibleBoards = board.possibleBoards()

    if possibleBoards.isEmpty {
        return []
    } else {
        return possibleBoards.filter {
            $0.succeeded
        } + possibleBoards.flatMap {
            successfulBoards($0)
        }
    }
}

let boards = successfulBoards(board)
print("Found \(boards.count) possible solutions")

if let solution = boards.first {
    ASCIIRenderer().drawBoard(solution)
}


