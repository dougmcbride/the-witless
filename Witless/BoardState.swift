// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

import Foundation

struct BoardState {
    let board: Board
    let path: Path?

    func possibleBoardStates() -> [BoardState] {
        guard let lastPosition = path?.positions.last else {
            return board.startingPaths().map {
                BoardState(board: board, path: $0)
            }
        }

        return board.possibleMovesFrom(lastPosition)
                .filter {
                    return path!.doesNotIntersectItselfByAddingMove($0, toBoard: board)
                }
                .map {
                    makeState(addingMove: $0)
                }
                .filter {
                    !$0.trianglesAreOverwhelmed()
                }
    }

    func makeState(addingMove move: Move) -> BoardState {
        let newPath = path!.path(addingMove: move, onBoard: board)
        return BoardState(board: board, path: newPath)
    }

    var succeeded: Bool {
        guard let lastPosition = path?.positions.last else {
            return false
        }

        if !board.endPositions.contains(lastPosition) {
            return false
        }

        if board.caresAboutRegions {
            for regionContents in regionThings() {
                var checkedSquares = false

                for thing in regionContents {
                    switch thing {
                        case .square(let color):
                            if checkedSquares {
                                break
                            }
                            checkedSquares = true
                            if regionContents.contains(where: {
                                if case .square(let c) = $0, c != color {
                                    return true
                                } else {
                                    return false
                                }
                            }) {
                                return false
                            }
                        case .star(let color):
                            switch (regionContents.countThing(.star(color)), regionContents.countThing(.square(color))) {
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
                        case .triangle, .empty:
                            break
                    }
                }
            }
        }

        if trianglesAreUnsatisfied() {
            return false
        }

        return true
    }

    func trianglesAreUnsatisfied() -> Bool {
        // TODO functional
        for triangle in board.triangles {
            let borderingSegments = board.segmentsBordering(position: triangle.position).intersection(path!.segments)
            if borderingSegments.count != triangle.number {
                return true
            }
        }

        return false
    }

    func trianglesAreOverwhelmed() -> Bool {
//        print("path.movesString = \(path?.movesString): ", terminator: "")
        // TODO functional
        for triangle in board.triangles {
            let borderingSegments = board.segmentsBordering(position: triangle.position).intersection(path!.segments)
            if borderingSegments.count > triangle.number {
                return true
            }
        }

        return false
    }

    var failed: Bool {
        return possibleBoardStates().isEmpty || trianglesAreOverwhelmed()
    }

    func regionThings() -> [[Thing]] {
        return regions().values.map {
            (region) in
            return region.map {
                return board.things[$0.y][$0.x]
            }
        }
    }

    func regions() -> [Position: Region] {
        var regionMap = [Position: Region]()

        for x in 0 ..< board.thingWidth {
            for y in 0 ..< board.thingHeight {
                let p = Position(x, y)
                if regionMap[p] != nil {
                    continue
                }
                let set: Set<Position> = [p]
                let newRegion = set.union(reachableThingPositions(fromThingPosition: p, done: set))
                for position in newRegion {
                    regionMap[position] = newRegion
                }
            }
        }

        return regionMap
    }

    func reachableThingPositions(fromThingPosition position: Position, done: Set<Position> = []) -> Set<Position> {
        let moves = board.possibleAdjacentThingPositions(fromThingPosition: position).filter {
            !done.contains($0)
        }.filter {
            to in
            let targetDelta = (abs(to.y - position.y), abs(to.x - position.x))

            let (px, py): (Int, Int) = {
                switch targetDelta {
                    case (0, 1):
                        return (max(position.x, to.x), min(position.y, to.y))
                    case (1, 0):
                        return (min(position.x, to.x), max(position.y, to.y))
                    default:
                        fatalError("bad delta")
                }
            }()

            return !path!.segments.contains {
                segment in
                let p1 = Position(px, py)
                let p2 = Position(px + targetDelta.0, py + targetDelta.1)
                return segment == Segment(p1, p2)
            }
        }

        if moves.isEmpty {
            return []
        } else {
            let set: Set<Position> = Set(moves)
            return set.union(moves.flatMap {
                self.reachableThingPositions(fromThingPosition: $0, done: done.union(moves))
            })
        }
    }

    func successfulBoardStates(maximum: Int = Int.max) -> [BoardState] {
        let possibleBoards = self.possibleBoardStates()

        if possibleBoards.isEmpty {
            return []
        } else {
            return possibleBoards.filter {
                !$0.trianglesAreOverwhelmed()}.filter {
                $0.succeeded
            } + possibleBoards.flatMap {
                $0.successfulBoardStates()
            }
        }
    }
}

extension BoardState: CustomDebugStringConvertible {
    var debugDescription: String {
        return "BoardState(path: \(path?.movesString)"
    }
}
