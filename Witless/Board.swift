// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

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

        for regionContents in regionThings() {
            var checkedSquares = false

            for thing in regionContents {
                switch thing {
                    case .Square(let color):
                        if checkedSquares {
                            break
                        }
                        checkedSquares = true
                        if regionContents.contains({
                            if case .Square(let c) = $0 where c != color {
                                return true
                            } else {
                                return false
                            }
                        }) {
                            return false
                        }
                    case .Star(let color):
                        switch (regionContents.countThing(.Star(color)), regionContents.countThing(.Square(color))) {
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
                    case .Empty:
                        break
                }
            }
        }

//        ASCIIRenderer().drawBoard(self)
//        ASCIIRenderer().drawBoard(self, regionMap: r)
        return true
    }

    var failed: Bool {
        return possibleBoards().isEmpty
    }

    func regionThings() -> [[Thing]] {
        return regions().values.map {
            (region) in
            return region.map {
                return things[$0.y][$0.x]
            }
        }
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
                let newRegion = set.union(reachablePositionsFrom(p, done: set))
                for position in newRegion {
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

    func successfulBoards() -> [Board] {
        let successfulBoards = possibleBoards()

        if successfulBoards.isEmpty {
            return []
        } else {
            return successfulBoards.filter {
                $0.succeeded
            } + successfulBoards.flatMap {
                $0.successfulBoards()
            }
        }
    }
}
