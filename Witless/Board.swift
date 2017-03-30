// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

struct Triangle {
    let requiredSegmentCount: Int
    let position: Position
}

enum Corner {
    case lowerLeft
    case upperLeft
    case lowerRight
    case upperRight

    func position(cellWidth: Int, cellHeight: Int) -> Position {
        switch self {
            case .lowerLeft:
                return Position(0, cellHeight)
            case .lowerRight:
                return Position(cellWidth, cellHeight)
            case .upperLeft:
                return .zero
            case .upperRight:
                return Position(cellWidth, 0)
        }
    }
}

enum SolutionStrategy {
    /// Quit after finding the first solution (fastest)
    case first
    /// Find all solutions
    case all
    /// Find all solutions and only return the shortest
    case shortestPath
}

struct Board {
    let width: Int
    let height: Int
    let startPositions: [Position]
    let endPositions: Set<Position>
    let cells: [[Cell]]
    let xWrapping: Bool
    var solutionStrategy: SolutionStrategy = .all

    let cellWidth: Int
    let cellHeight: Int
    let caresAboutRegions: Bool
    let segments: [[Set<Segment>]]
    let triangles: [Triangle]

    init(startCorner: Corner, endCorner: Corner, cells: [[Cell]]) {
        let cellHeight = cells.count
        let cellWidth = cells.first!.count
        let startPosition = startCorner.position(cellWidth: cellWidth, cellHeight: cellHeight)
        let endPosition = endCorner.position(cellWidth: cellWidth, cellHeight: cellHeight)

        self.init(start: startPosition, end: endPosition, cells: cells, wrapHorizontal: false)
    }

    init(start: Position, end: Position, cells: [[Cell]], wrapHorizontal: Bool = false) {
        self.init(startPositions: [start], endPositions: [end], cells: cells, wrapHorizontal: wrapHorizontal)
    }

    init(startPositions: [Position], endPositions: [Position], cells: [[Cell]], wrapHorizontal: Bool = false) {
        let widthAdjustment = wrapHorizontal ? 0 : 1
        let width = cells.first!.count + widthAdjustment
        let height = cells.count + 1

        self.init(width: width, height: height,
                  startPositions: startPositions, endPositions: endPositions, cells: cells, wrapHorizontal: wrapHorizontal)
    }

    init(width: Int, height: Int, startPositions: [Position], endPositions: [Position], cells: [[Cell]], wrapHorizontal: Bool) {
        self.width = width
        self.height = height
        self.startPositions = startPositions
        self.endPositions = Set<Position>(endPositions)
        self.cells = cells
        self.xWrapping = wrapHorizontal

        let cellHeight = cells.count
        let cellWidth = cells.first!.count

        var segments = [[Set<Segment>]]()
        var triangles = [Triangle]()

        for y in 0 ..< cellHeight {
            var row = [Set<Segment>]()

            for x in 0 ..< cellWidth {
                if case .triangle(let count) = cells[y][x] {
                    triangles.append(Triangle(requiredSegmentCount: count, position: Position(x, y)))
                }

                let topSegment = Segment(Position(x, y), Position(x + 1, y))
                let bottomSegment = Segment(Position(x, y + 1), Position(x + 1, y + 1))
                let leftSegment = Segment(Position(x, y), Position(x, y + 1))

                let effectiveRightX = x == width - 1 && wrapHorizontal ? 0 : x + 1

                let rightSegment = Segment(Position(effectiveRightX, y),
                                           Position(effectiveRightX, y + 1))

                row.append([topSegment, bottomSegment, leftSegment, rightSegment])
            }

            segments.append(row)
        }

        self.cellHeight = cellHeight
        self.cellWidth = cellWidth
        self.caresAboutRegions = FlattenCollection(cells).contains { $0.caresAboutRegions }
        self.segments = segments
        self.triangles = triangles
    }

    var initialState: BoardState {
        return BoardState(board: self, path: nil)
    }

    func pathPosition(from position: Position, moving move: Move) -> Position? {
        return makePosition(fromPosition: position, move: move) { x, y in
            return positionAt(x, y)
        }
    }

    func cellPosition(fromPosition position: Position, moving move: Move) -> Position? {
        return makePosition(fromPosition: position, move: move) { x, y in
            return positionAt(x, y, useCellPosition: true)
        }
    }

    func moves(from p: Position) -> [Move] {
        return Move.allMoves.filter {
            pathPosition(from: p, moving: $0) != nil
        }
    }

    func startingPaths() -> [Path] {
        return startPositions.flatMap { p -> [Path] in
            moves(from: p).map { Path(startPosition: p, moves: [$0], board: self) }
        }
    }

    func segment(fromPosition position: Position, withMove move: Move) -> Segment {
        let effectivePosition: Position

        switch (move, position.x) {
            case (.left, 0):
                effectivePosition = Position(width, position.y)
            default:
                effectivePosition = position
        }

        return Segment(effectivePosition, self.pathPosition(from: position, moving: move)!)
    }

    func positionAt(_ x: Int, _ y: Int, useCellPosition: Bool = false) -> Position? {
        let effectiveWidth = useCellPosition ? cellWidth : width
        let effectiveHeight = useCellPosition ? cellHeight : height

        let xRange = xWrapping && !useCellPosition ? (-1 ..< effectiveWidth) : 0 ..< effectiveWidth
        let yRange = 0 ..< effectiveHeight

        if xRange.contains(x) && yRange.contains(y) {
            return Position((x + effectiveWidth) % effectiveWidth, y)
        }

        return nil
    }

    func makePosition(fromPosition position: Position, move: Move, block: ((Int, Int) -> Position?)) -> Position? {
        switch move {
            case .down:
                return block(position.x, position.y + 1)
            case .up:
                return block(position.x, position.y - 1)
            case .left:
                return block(position.x - 1, position.y)
            case .right:
                return block(position.x + 1, position.y)
        }
    }

    func possibleAdjacentCellPositions(fromCellPosition p: Position) -> [Position] {
        return Move.allMoves.flatMap {
            cellPosition(fromPosition: p, moving: $0)
        }
    }

    func allSegments(bordering position: Position) -> Set<Segment> {
        return segments[position.y][position.x]
    }

    func findSuccessfulBoardStates() -> [BoardState] {
        do {
            return try initialState.findSuccessfulStates()
        } catch BoardStateException.foundSolution(let solvedState) {
            return [solvedState]
        } catch {
            print("Error: \(error)")
            return []
        }
    }
}
