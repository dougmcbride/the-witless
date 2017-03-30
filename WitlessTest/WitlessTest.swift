//  Copyright © 2016 The Sneaky Frog. All rights reserved.

import Quick
import Nimble

func containMoves(_ startPosition: Position, movesString: String) -> NonNilMatcherFunc<[BoardState]> {
    return NonNilMatcherFunc {
        (candidateBoards, failureMessage) -> Bool in
        failureMessage.postfixMessage = "contain path with moves <\(movesString)>"

        guard let boardStates: [BoardState] = try! candidateBoards.evaluate(), !boardStates.isEmpty else {
            return false
        }

        return boardStates.map {
            $0.path!
        }.contains {
            $0 == Path(startPosition: startPosition, movesString: movesString, board: boardStates.first!.board)
        }
    }
}

func beMoves(_ startPosition: Position, moves: [String]) -> NonNilMatcherFunc<[BoardState]> {
    return NonNilMatcherFunc {
        (candidateBoards, failureMessage) -> Bool in
        for move in moves {
            if try! containMoves(startPosition, movesString: move).doesNotMatch(candidateBoards, failureMessage: failureMessage) {
                return false
            }
        }

        failureMessage.postfixMessage = "have \(moves.count) solutions"

        guard let boards: [BoardState] = try! candidateBoards.evaluate() else {
            return false
        }

        return boards.count == moves.count
    }
}

class BoardSpec: QuickSpec {
    override func spec() {
        describe("A position at x=0") {
            describe("on a board with wrapping") {
                it("should have an effective segment from the right when moving left") {
                    let twoByThreeThings: [[Thing]] = [[.empty, .empty], [.empty, .empty], [.empty, .empty]]
                    let board = Board(start: Position(0, 0), end: Position(1, 1), things: twoByThreeThings, wrapHorizontal: true)
                    let position1 = Position(0, 0)
                    let effectivePosition1 = Position(2, 0)
                    let position2 = Position(1, 0)
                    expect(board.segment(fromPosition: position1, withMove: .left)).to(equal(Segment(effectivePosition1, position2)))
                }
            }
        }
    }
}

class PathSpec: QuickSpec {
    override func spec() {
        describe("A simple right-down path") {
            it("should have corresponding segments") {
                let twoByTwoThings: [[Thing]] = [[.empty, .empty], [.empty, .empty]]
                let board = Board(start: Position(0, 0), end: Position(1, 1), things: twoByTwoThings)
                let position1 = Position(0, 0)
                let position2 = Position(1, 0)
                let position3 = Position(1, 1)
                let path = Path(startPosition: position1, movesString: "RD", board: board)
                expect(path.segments).to(equal([Segment(position1, position2),
                                                Segment(position2, position3)]))
            }
        }

        describe("A path wrapping left") {
            it("should show a segment from the right") {
                let twoByTwoThings: [[Thing]] = [[.empty, .empty], [.empty, .empty]]
                let board = Board(start: Position(0, 0), end: Position(1, 1), things: twoByTwoThings, wrapHorizontal: true)
                let position1 = Position(2, 0)
                let position2 = Position(1, 0)
                let position3 = Position(1, 1)
                let path = Path(startPosition: position1, movesString: "LD", board: board)
                expect(path.segments).to(equal([Segment(position1, position2),
                                                Segment(position2, position3)]))
            }
        }
    }

}

class SegmentSpec: QuickSpec {
    override func spec() {
        describe("A segment") {
            it("should be equal to another segment with reversed positions") {
                let position1 = Position(0, 0)
                let position2 = Position(1, 0)
                let segment1 = Segment(position1, position2)
                let segment2 = Segment(position2, position1)
                expect(segment1).to(equal(segment2))
                expect(Set([segment1]).intersection(Set([segment2]))).toNot(beEmpty())

                let set1 = Set([
                                       Segment(Position(0, 1), Position(0, 2)),
                                       Segment(Position(0, 2), Position(1, 2)),
                                       Segment(Position(1, 1), Position(0, 1)),
                                       Segment(Position(1, 1), Position(1, 2)),
                               ])

                let set2 = Set([
                                       Segment(Position(0, 2), Position(0, 1)),
                                       Segment(Position(1, 0), Position(1, 1)),
                                       Segment(Position(1, 0), Position(0, 0)),
                                       Segment(Position(1, 1), Position(0, 1)),
                               ])

                expect(set1.intersection(set2).count).to(equal(2))
            }
        }
    }
}

class ThingSpec: QuickSpec {
    override func spec() {
        super.spec()
        describe("an unknown symbol") {
            it("should cause a parsing exception") {
                expect {
                    try Thing.parse("J")
                }.to(throwError())
            }
        }
    }
}

class SolutionSpec: QuickSpec {
    func checkSolutions(for board: Board, are moves: [String]) {
        expect(board.findSuccessfulBoardStates()).to(beMoves(board.startPositions.first!, moves: moves))
    }

    override func spec() {
        describe("A 1x1 square board") {
            it("has two solutions") {
                self.checkSolutions(for: Board(startCorner: .upperLeft, endCorner: .lowerRight, things: [[.empty]]),
                                    are: ["RD", "DR"])
            }
        }

        describe("a simple black/white square board") {
            it("has two solutions") {
                self.checkSolutions(for: Board(startCorner: .upperLeft, endCorner: .upperRight, things: [[.square(.black), .square(.white)]]),
                                    are: ["RDRU", "DRUR"])
            }
        }

        describe("a three-star board") {
            it("can't be solved") {
                self.checkSolutions(for: Board(startCorner: .upperLeft, endCorner: .upperRight, things: [[.star(.black), .star(.black), .star(.black)]]),
                                    are: [])
            }
        }

        describe("a 2x2 star board") {
            it("has four solutions") {
                self.checkSolutions(for: Board(startCorner: .lowerLeft, endCorner: .upperRight, things: [[.star(.purple), .star(.purple)],
                                                                                                         [.star(.purple), .star(.purple)]]),
                                    are: ["UURDDRUU", "URRU", "RUUR", "RRULLURR"])
            }
        }

        describe("a BWB/BWB/BWB board without wrapping") {
            it("can't be solved") {

                self.checkSolutions(for: Board(startCorner: .lowerLeft, endCorner: .upperLeft, things: try! Thing.parse("BWB/BWB/BWB")),
                                    are: [])
            }
        }

        describe("a 2x1 board with horizontal wrapping") {
            it("has four solutions") {
                self.checkSolutions(for: Board(start: Position(0, 1), end: Position(1, 0), things: [[.empty, .empty]], wrapHorizontal: true),
                                    are: ["UR", "RU", "LU", "UL"])
            }
        }

        describe("a triangle puzzle") {
            describe("without wrapping") {
                it("has one solution") {
                    self.checkSolutions(for: Board(startCorner: .lowerLeft, endCorner: .upperRight, things: [[.empty, .triangle(1)]]),
                                        are: ["URR"])
                }

                it("has two solutions") {
                    self.checkSolutions(for: Board(startCorner: .lowerLeft, endCorner: .upperRight, things: [[.empty, .triangle(2)]]),
                                        are: ["RRU", "RUR"])
                }
            }

            describe("with wrapping") {
                it("has three solutions") {
                    self.checkSolutions(for: Board(start: Position(0, 2), end: .zero, things: [[.empty, .empty], [.triangle(2), .empty]], wrapHorizontal: true),
                                        are: ["URUL", "RUUL", "LULU"])
                }
            }
        }
    }
}
