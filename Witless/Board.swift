// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

var segmentCache = [Position: Set<Segment>]()

struct Board {
    let width: Int
    let height: Int
    let startPositions: [Position]
    let endPositions: [Position]
    let things: [[Thing]]
    let xWrapping: Bool
    let careAboutRegions: Bool

    var thingWidth: Int {
        return width - (xWrapping ? 0 : 1)
    }
    var thingHeight: Int {
        return height - 1
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
        self.endPositions = endPositions
        self.things = things
        self.xWrapping = wrapHorizontal

        self.careAboutRegions =
        things.reduce([], { (a: [Thing], b: [Thing]) -> [Thing] in a + b }) // TODO flatmap
                .contains(where: { $0.caresAboutRegions })
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

    func segmentsBordering(position pos: Position) -> Set<Segment> {
        if let cachedSegments = segmentCache[pos] {
            return cachedSegments
        }

        let topSegment = Segment(Position(pos.x, pos.y), Position(pos.x + 1, pos.y))
        let bottomSegment = Segment(Position(pos.x, pos.y + 1), Position(pos.x + 1, pos.y + 1))
        let leftSegment = Segment(Position(pos.x, pos.y), Position(pos.x, pos.y + 1))

        let effectiveRightX: Int

        if pos.x == width - 1 && xWrapping {
            effectiveRightX = 0
        } else {
            effectiveRightX = pos.x + 1
        }
        let rightSegment = Segment(Position(effectiveRightX, pos.y),
                                   Position(effectiveRightX, pos.y + 1))

        let segments: Set<Segment> = [topSegment, bottomSegment, leftSegment, rightSegment]
        segmentCache[pos] = segments
        return segments
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

    func successfulBoardStates() -> [BoardState] {
        return initialState.successfulBoardStates()
    }
}
