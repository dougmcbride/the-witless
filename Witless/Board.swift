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

    func position(thingWidth: Int, thingHeight: Int) -> Position {
        switch self {
            case .lowerLeft:
                return Position(0, thingHeight)
            case .lowerRight:
                return Position(thingWidth, thingHeight)
            case .upperLeft:
                return .zero
            case .upperRight:
                return Position(thingWidth, 0)
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
    let things: [[Thing]]
    let xWrapping: Bool
    var solutionStrategy: SolutionStrategy = .all

    let thingWidth: Int
    let thingHeight: Int
    let caresAboutRegions: Bool
    let segments: [[Set<Segment>]]
    let triangles: [Triangle]

    init(startCorner: Corner, endCorner: Corner, things: [[Thing]]) {
        let thingHeight = things.count
        let thingWidth = things.first!.count
        let startPosition = startCorner.position(thingWidth: thingWidth, thingHeight: thingHeight)
        let endPosition = endCorner.position(thingWidth: thingWidth, thingHeight: thingHeight)

        self.init(start: startPosition, end: endPosition, things: things, wrapHorizontal: false)
    }

    init(start: Position, end: Position, things: [[Thing]], wrapHorizontal: Bool = false) {
        self.init(startPositions: [start], endPositions: [end], things: things, wrapHorizontal: wrapHorizontal)
    }

    init(startPositions: [Position], endPositions: [Position], things: [[Thing]], wrapHorizontal: Bool = false) {
        let widthAdjustment = wrapHorizontal ? 0 : 1
        let width = things.first!.count + widthAdjustment
        let height = things.count + 1

        self.init(width: width, height: height,
                  startPositions: startPositions, endPositions: endPositions, things: things, wrapHorizontal: wrapHorizontal)
    }

    init(width: Int, height: Int, startPositions: [Position], endPositions: [Position], things: [[Thing]], wrapHorizontal: Bool) {
        self.width = width
        self.height = height
        self.startPositions = startPositions
        self.endPositions = Set<Position>(endPositions)
        self.things = things
        self.xWrapping = wrapHorizontal

        var segments = [[Set<Segment>]]()

        for y in 0 ..< height {
            var row = [Set<Segment>]()

            for x in 0 ..< width {
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

        var triangles = [Triangle]()
        let thingHeight = things.count
        let thingWidth = things.first!.count

        for y in 0 ..< thingHeight {
            for x in 0 ..< thingWidth {
                if case .triangle(let count) = things[y][x] {
                    triangles.append(Triangle(requiredSegmentCount: count, position: Position(x, y)))
                }
            }
        }

        self.thingHeight = thingHeight
        self.thingWidth = thingWidth
        self.caresAboutRegions = FlattenCollection(things).contains { $0.caresAboutRegions }
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

    func thingPosition(fromPosition position: Position, moving move: Move) -> Position? {
        return makePosition(fromPosition: position, move: move) { x, y in
            return positionAt(x, y, useThingPosition: true)
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

    func positionAt(_ x: Int, _ y: Int, useThingPosition: Bool = false) -> Position? {
        let effectiveWidth = useThingPosition ? thingWidth : width
        let effectiveHeight = useThingPosition ? thingHeight : height

        let xRange = xWrapping && !useThingPosition ? (-1 ..< effectiveWidth) : 0 ..< effectiveWidth
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

    func possibleAdjacentThingPositions(fromThingPosition p: Position) -> [Position] {
        return Move.allMoves.flatMap {
            thingPosition(fromPosition: p, moving: $0)
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
