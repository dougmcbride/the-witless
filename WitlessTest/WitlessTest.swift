//  Copyright © 2016 The Sneaky Frog. All rights reserved.

import Quick
import Nimble

func containMoves(startPosition: Position, movesString: String) -> NonNilMatcherFunc<[Board]> {
    return NonNilMatcherFunc {
        (boards, failureMessage) in
        failureMessage.postfixMessage = "contain path with moves <\(movesString)>"
        guard let boards_:[Board] = try! boards.evaluate() else {
            return false
        }
        return boards_.map{$0.path}.contains{$0 == Path(startPosition: startPosition, movesString: movesString, width: boards_.first!.width)}
    }
}

func beMoves(startPosition: Position, moves: [String]) -> NonNilMatcherFunc<[Board]> {
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

class SquareSpec: QuickSpec {
    override func spec() {
        /*
        describe("A simple square board") {
            it("has two solutions") {
                let startPosition = Position(0, 0)
                let board = Board(start: startPosition, end: Position(1, 1), things: [[.Empty]])
                let solutions = board.successfulBoards()
                expect(solutions).to(beMoves(startPosition, moves: ["RD", "DR"]))
            }
        }

        describe("a simple black/white square board") {
            it("has two solutions") {
                let startPosition = Position(0, 0)
                let board = Board(start: startPosition, end: Position(2, 0), things: [[.Square(.Black), .Square(.White)]])
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
                let board = Board(start: Position(0, 3), end: Position(0, 0), things: things)
                it("can't be solved") {
                    expect(board.successfulBoards()).to(beEmpty())
                }
            }
        }
        */

        describe("a 2x1 board with horizontal wrapping") {
            it("has four solutions") {
                let startPosition = Position(0, 1)
                let board = Board(start: startPosition, end: Position(1, 0), things: [[.Empty, .Empty]], wrapHorizontal: true)
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
