// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

import Foundation

enum BoardStateException: Error {
    case foundSolution(BoardState)
}

struct BoardState {
    let board: Board
    let path: Path

    func possibleNextStates() -> [BoardState] {
        guard let lastPosition = path.positions.last else {
            return board.startingPaths().map {
                BoardState(board: board, path: $0)
            }
        }

        return board.moves(from: lastPosition)
                .filter { move in path.doesNotIntersectItselfByAddingMove(move, toBoard: board) }
                .map { move in makeState(adding: move) }
                .filter { state in !state.hitDeadEnd }
    }

    func makeState(adding move: Move) -> BoardState {
        let newPath = path.path(addingMove: move, onBoard: board)
        return BoardState(board: board, path: newPath)
    }

    func succeeded() throws -> Bool {
        guard let lastPosition = path.positions.last else {
            return false
        }

        if !board.endPositions.contains(lastPosition) {
            return false
        }

        if board.caresAboutRegions {
            for regionContents in regionCells() {
                var checkedSquares = false

                for cell in regionContents {
                    switch cell {
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
                            switch (regionContents.countCell(.star(color)), regionContents.countCell(.square(color))) {
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

        if actualToRequiredAdjacentSegmentsForTriangles(is: !=) {
            return false
        }

        if case .first = board.solutionStrategy {
            throw BoardStateException.foundSolution(self)
        }

        return true
    }

    func actualToRequiredAdjacentSegmentsForTriangles(is compare: ((Int, Int) -> Bool), bordering segment: Segment? = nil) -> Bool {
        let triangles: [Triangle]

        if let segment_ = segment {
            triangles = board.trianglesBorderingSegment[segment_] ?? []
        } else {
            triangles = board.triangles
        }

        return triangles.contains { triangle in
            let actualCount = board.allSegments(bordering: triangle.position).intersection(path.segments).count
            return compare(actualCount, triangle.requiredSegmentCount)
        }
    }

    var hitDeadEnd: Bool {
        guard let segment = path.segments.last else {
            return false
        }

        return actualToRequiredAdjacentSegmentsForTriangles(is: >, bordering: segment)
    }

    func regionCells() -> [[Cell]] {
        return regions().values.map {
            (region) in
            return region.map {
                return board.cells[$0.y][$0.x]
            }
        }
    }

    func regions() -> [Position: Region] {
        var regionMap = [Position: Region]()

        for x in 0 ..< board.cellWidth {
            for y in 0 ..< board.cellHeight {
                let p = Position(x, y)
                if regionMap[p] != nil {
                    continue
                }
                let set: Set<Position> = [p]
                let newRegion = set.union(reachableCellPositions(from: p, done: set))
                for position in newRegion {
                    regionMap[position] = newRegion
                }
            }
        }

        return regionMap
    }

    func reachableCellPositions(from position: Position, done: Set<Position> = []) -> Set<Position> {
        let moves = board.possibleAdjacentCellPositions(from: position).filter {
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

            return !path.segments.contains {
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
                self.reachableCellPositions(from: $0, done: done.union(moves))
            })
        }
    }

    func findSuccessfulStates() throws -> [BoardState] {
        let possibleStates = self.possibleNextStates()

        let immediateSuccessfulStates = try possibleStates
                .filter { !$0.hitDeadEnd }
                .filter { try $0.succeeded() }

        let allSolutions = try immediateSuccessfulStates + possibleStates.flatMap { try $0.findSuccessfulStates() }

        switch board.solutionStrategy {
            case .all:
                return allSolutions
            case .shortestPath:
                if let shortest = allSolutions.sorted(by: { $0.path.length < $1.path.length }).first {
                    return [shortest]
                } else {
                    return []
                }
            case .first:
                // We would have quit by now if we'd found a solution.
                return []
        }
    }
}

extension BoardState: CustomDebugStringConvertible {
    var debugDescription: String {
        return "BoardState(path: \(path.movesString)"
    }
}
