// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

struct Triangle {
    let number: Int
    let position: Position
}

struct Board {
    let width: Int
    let height: Int
    let startPositions: [Position]
    let endPositions: Set<Position>
    let things: [[Thing]]
    let xWrapping: Bool

    let thingWidth: Int
    let thingHeight: Int
    let caresAboutRegions: Bool
    let segments: [[Set<Segment>]]
    let triangles: [Triangle]

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
                if case .triangle(let number) = things[y][x] {
                    triangles.append(Triangle(number: number, position: Position(x, y)))
                }
            }
        }

        self.thingHeight = thingHeight
        self.thingWidth = thingWidth
        self.caresAboutRegions = things.flatMap{$0}.contains(where: { $0.caresAboutRegions })
        self.segments = segments
        self.triangles = triangles
    }

    var initialState: BoardState {
        return BoardState(board: self, path: nil)
    }

    func pathPosition(fromPosition position: Position, moving move: Move) -> Position? {
        return makePosition(fromPosition: position, move: move) { x, y in
            return positionAt(x, y)
        }
    }

    func thingPosition(fromPosition position: Position, moving move: Move) -> Position? {
        return makePosition(fromPosition: position, move: move) { x, y in
            return positionAt(x, y, useThingPosition: true)
        }
    }

    func possibleMovesFrom(_ p: Position) -> [Move] {
        return Move.allMoves.filter {
            pathPosition(fromPosition: p, moving: $0) != nil
        }
    }

    func startingPaths() -> [Path] {
        return startPositions.flatMap { p -> [Path] in
            possibleMovesFrom(p).map {
                        Path(startPosition: p, moves: [$0], board: self)
                    }
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

        return Segment(effectivePosition, self.pathPosition(fromPosition: position, moving: move)!)
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

    func segmentsBordering(position: Position) -> Set<Segment> {
        return segments[position.y][position.x]
    }

    func successfulBoardStates() -> [BoardState] {
        return initialState.successfulBoardStates()
    }
}
