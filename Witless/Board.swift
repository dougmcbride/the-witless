// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

struct Board {
    let width: Int
    let height: Int
    let startPositions: [Position]
    let endPositions: [Position]
    let path: Path
    let things: [[Thing]]
    let xWrapping: Bool

    var thingWidth: Int {
        return width - (xWrapping ? 0 : 1)
    }

    var thingHeight: Int {
        return height - 1
    }

    init(start: RawPosition, end: RawPosition, things: [[Thing]], wrapHorizontal: Bool = false) {
        let widthAdjustment = wrapHorizontal ? 0 : 1
        let width = things.first!.count + widthAdjustment
        let height = things.count + 1
        let startPosition = Position(start.x, start.y, width: width, height: height, xWrapping: wrapHorizontal)
        let endPosition = Position(end.x, end.y, width: width, height: height, xWrapping: wrapHorizontal)
        self.init(width: width, height: height,
                  start: startPosition, end: endPosition, things: things, wrapHorizontal: wrapHorizontal)
    }

    init(width: Int, height: Int, start: Position, end: Position, things: [[Thing]], wrapHorizontal: Bool = false) {
        self.init(width: width,
                  height: height,
                  startPositions: [start],
                  endPositions: [end],
                  path: Path(startPosition: start),
                  things: things,
                  wrapHorizontal: wrapHorizontal)
    }

    init(width: Int, height: Int, startPositions: [Position], endPositions: [Position], path: Path, things: [[Thing]], wrapHorizontal: Bool) {
        self.width = width
        self.height = height
        self.path = path
        self.startPositions = startPositions
        self.endPositions = endPositions
        self.things = things
        self.xWrapping = wrapHorizontal
    }

    func position(x: Int, _ y: Int) -> Position {
        return Position(x, y, width: width, height: height, xWrapping: xWrapping)
    }

    func possibleBoards() -> [Board] {
        guard let lastPosition = path.positions.last else {
            return startingPaths().map {
                Board(width: width, height: height, startPositions: startPositions, endPositions: endPositions, path: $0, things: things, wrapHorizontal: xWrapping)
            }
        }

        return possibleMovesFrom(lastPosition)
        .filter {
            return path.doesNotIntersectItselfByAddingMove($0)
        }
        .map {
            boardByAddingMove($0)
        }
    }

    private func possibleAdjacentsFrom(p: Position) -> [Position] {
        return Move.allMoves
        .flatMap {
            p.positionByMoving($0)
        }
    }

    private func possibleMovesFrom(p: Position) -> [Move] {
        return Move.allMoves.filter { p.positionByMoving($0) != nil }
    }

    private func startingPaths() -> [Path] {
        return startPositions.flatMap {
            Path(startPosition: $0, moves: self.possibleMovesFrom($0))
        }
    }

    func boardByAddingMove(move: Move) -> Board {
        let newPath = path.pathAddingMove(move)
        return Board(width: width, height: height, startPositions: startPositions, endPositions: endPositions, path: newPath, things: things, wrapHorizontal: xWrapping)
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
                    case .Triangle, .Empty:
                        break
                }
            }
        }

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

        for x in 0 ..< thingWidth {
            for y in 0 ..< thingHeight {
                let p = Position(x, y, width: thingWidth, height: thingHeight, xWrapping: xWrapping)
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

            return !path.segments.contains {
                segment in
                let p1 = Position(px, py, width: width, height: height, xWrapping: xWrapping)
                let p2 = Position(px + targetDelta.0, py + targetDelta.1, width: width, height: height, xWrapping: xWrapping)
                return (segment.from == p1 && segment.to == p2) || (segment.from == p2 && segment.to == p1)
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
