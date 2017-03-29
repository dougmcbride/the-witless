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

struct BoardState {
    let board: Board
    let path: Path?

    var width: Int {
        return board.width
    }
    var height: Int {
        return board.height
    }
    var thingWidth: Int {
        return board.thingWidth
    }
    var thingHeight: Int {
        return board.thingHeight
    }

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
        guard let lastMove = path?.positions.last else {
            return false
        }

        if !board.endPositions.contains(where: { $0 == lastMove }) {
            return false
        }

        if board.careAboutRegions {
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

        if trianglesAreUnhappy() {
            return false
        }

        return true
    }

    func trianglesAreUnhappy() -> Bool {
        for y in 0 ..< thingHeight {
            for x in 0 ..< thingWidth {
                if case .triangle(let number) = board.things[y][x] {
                    let borderingSegments = board.segmentsBordering(position: Position(x, y)).intersection(path!.segments).count
                    if borderingSegments != number {
                        return true
                    }
                }
            }
        }
        return false
    }

    func trianglesAreOverwhelmed() -> Bool {
        for y in 0 ..< thingHeight {
            for x in 0 ..< thingWidth {
                if case .triangle(let number) = board.things[y][x] {
                    let borderingSegments = board.segmentsBordering(position: Position(x, y)).intersection(path!.segments)
                    if borderingSegments.count > number {
                        return true
                    }
                }
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

        for x in 0 ..< thingWidth {
            for y in 0 ..< thingHeight {
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
                $0.succeeded
            } + possibleBoards.flatMap {
                $0.successfulBoardStates()
            }
        }
    }
}
