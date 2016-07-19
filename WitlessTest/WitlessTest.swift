//  Copyright © 2016 The Sneaky Frog. All rights reserved.

import Quick
import Nimble

func containMoves(startRawPosition: RawPosition, movesString: String) -> NonNilMatcherFunc<[Board]> {
    return NonNilMatcherFunc {
        (boards, failureMessage) in
        failureMessage.postfixMessage = "contain path with moves <\(movesString)>"
        guard let boards_:[Board] = try! boards.evaluate() where !boards_.isEmpty else {
            return false
        }
        let startPosition = boards_.first!.position(startRawPosition.x, startRawPosition.y)
        return boards_.map{$0.path}.contains{$0 == Path(startPosition: startPosition, movesString: movesString)}
    }
}

func beMoves(startPosition: RawPosition, moves: [String]) -> NonNilMatcherFunc<[Board]> {
    return NonNilMatcherFunc {
        (boards, failureMessage) in
        for move in moves {
            if try! containMoves(startPosition, movesString: move).doesNotMatch(boards, failureMessage: failureMessage) {
                return false
            }
        }
        failureMessage.postfixMessage = "have \(moves.count) solutions"
        guard let boards_:[Board] = try! boards.evaluate() else {
            return false
        }
        return boards_.count == moves.count
    }
}

class PositionSpec: QuickSpec {
    override func spec() {
        describe("A position at x=0") {
            it("should have an effective segment from the right when moving left") {
                let position1 = Position(0, 0, width: 2, height: 3, xWrapping: true)
                let effectivePosition1 = Position(2, 0, width: 2, height: 3, xWrapping: true)
                let position2 = Position(1, 0, width: 2, height: 3, xWrapping: true)
                expect(position1.effectiveSegmentForMove(.Left)).to(equal(Segment(from: effectivePosition1,
                                                                                  to: position2)))

            }
        }
    }
}

class PathSpec: QuickSpec {
    override func spec() {
        describe("A simple right-down path") {
            it("should have corresponding segments") {
                let position1 = Position(0, 0, width: 2, height: 2, xWrapping: false)
                let position2 = Position(1, 0, width: 2, height: 2, xWrapping: false)
                let position3 = Position(1, 1, width: 2, height: 2, xWrapping: false)
                let path = Path(startPosition: position1, movesString: "RD")
                expect(path.segments).to(equal([Segment(from: position1, to: position2),
                                                Segment(from: position2, to: position3)]))
            }
        }

        describe("A path wrapping left") {
            it("should show a segment from the right") {
                let position1 = Position(2, 0, width: 2, height: 2, xWrapping: true)
                let position2 = Position(1, 0, width: 2, height: 2, xWrapping: true)
                let position3 = Position(1, 1, width: 2, height: 2, xWrapping: true)
                let path = Path(startPosition: position1, movesString: "LD")
                expect(path.segments).to(equal([Segment(from: position1, to: position2),
                                                Segment(from: position2, to: position3)]))
            }
        }
    }
}

class SquareSpec: QuickSpec {
    override func spec() {
        describe("A simple square board") {
            it("has two solutions") {
                let startPosition = RawPosition(0, 0)
                let board = Board(start: startPosition, end: RawPosition(1, 1), things: [[.Empty]])
                let solutions = board.successfulBoards()
                expect(solutions).to(beMoves(startPosition, moves: ["RD", "DR"]))
            }
        }

        describe("a simple black/white square board") {
            it("has two solutions") {
                let startPosition = RawPosition(0, 0)
                let board = Board(start: startPosition, end: RawPosition(2, 0), things: [[.Square(.Black), .Square(.White)]])
                let solutions = board.successfulBoards()
                expect(solutions).to(beMoves(startPosition, moves: ["RDRU", "DRUR"]))
            }
        }

        describe("an unknown symbol") {
            it("should cause a parsing exception") {
                expect {try Thing.parse("J")}.to(throwError())
            }
        }

        describe("a BWB/BWB/BWB board") {
            let things = try! Thing.parse("BWB/BWB/BWB")

            context("without wrapping") {
                let board = Board(start: RawPosition(0, 3), end: RawPosition(0, 0), things: things)
                it("can't be solved") {
                    expect(board.successfulBoards()).to(beEmpty())
                }
            }
        }

        describe("a 2x1 board with horizontal wrapping") {
            it("has four solutions") {
                let startPosition = RawPosition(0, 1)
                let board = Board(start: startPosition, end: RawPosition(1, 0),
                                  things: [[.Empty, .Empty]], wrapHorizontal: true)
                let successfulBoards = board.successfulBoards()
                expect(successfulBoards).to(beMoves(startPosition, moves: ["UR", "RU", "LU", "UL"]))

                let renderer = ASCIIRenderer()
                for solution in successfulBoards {
                    renderer.drawBoard(solution)
                    print(solution.path.moves)
                }
            }
        }
    }
}
