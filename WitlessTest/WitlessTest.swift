//  Copyright © 2016 The Sneaky Frog. All rights reserved.

import Quick
import Nimble

class SquareSpec: QuickSpec {
    override func spec() {
        describe("A simple square board") {
            it("has two solutions") {
                let board = Board(start: Position(0,0), end: Position(1,1), things: [[.Empty]])
                let solutions = board.successfulBoards()
                expect(solutions).to(haveCount(2))
            }
        }

        describe("a simple black/white square board") {
            it("has two solutions") {
                let board = Board(start: Position(0,0), end: Position(2,0), things: [[.Square(.Black), .Square(.White)]])
                let solutions = board.successfulBoards()
                expect(solutions).to(haveCount(2))
            }
        }

        describe("an unknown symbol") {
            it("should cause a parsing exception") {
                expect {try Thing.parse("J")}.to(throwError())
            }
        }

        describe("a BBB/WWW/BBB board") {
            let things = try! Thing.parse("BWB/BWB/BWB")

            context("without wrapping") {
                let board = Board(start: Position(0,2), end: Position(0,0), things: things)
                it("can't be solved") {
                    expect(board.successfulBoards()).to(beEmpty())

                }
            }

//            context("with horizontal wrapping") {
//                let board = Board(start: Position(0,2), end: Position(0,0), things: things, )
//
//                it("is solvable") {
//                    expec
//                }
//            }
        }
    }
}
