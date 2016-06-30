// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

protocol Renderer {
    func drawBoard(board: Board)
}

func *(string: String, times: Int) -> String {
    var s = ""
    for _ in 0 ..< times {
        s += string
    }
    return s
}

struct ASCIIRenderer: Renderer {
    func drawBoard(board: Board) {
        let width = totalWidthOfBoard(board)
        print("_" * width)

        for y in 0 ..< board.thingHeight {
            printPathRow(y, board: board)
            print("|", terminator: "")
            printColumnSeparator(board, row: y, column: -1)
            for x in 0 ..< board.thingWidth {
                let square: String
                switch board.things[y][x] {
                    case .Empty:
                        square = "..."
                    case .Square(let color):
                        square = "[\(color.rawValue)]"
                    case .Star(let color):
                        square = "*\(color.rawValue)*"
                }

                print(square, terminator: "")
                printColumnSeparator(board, row: y, column: x)
            }
            print("|")
        }

        printPathRow(board.thingHeight, board: board)
        print("-" * width)
    }

    private func printColumnSeparator(board: Board, row: Int, column: Int) {
        if board.path.moves.contains({
            if !($0.from.x == column + 1 && $0.to.x == column + 1) {
                return false
            }
            return (($0.from.y == row && $0.to.y == row + 1) || ($0.to.y == row && $0.from.y == row + 1))
        }) {
            print("#", terminator: "")
        } else {
            print(".", terminator: "")
        }
    }

    private func totalWidthOfBoard(board: Board) -> Int {
        return board.thingWidth * 3 + 4 + board.thingWidth - 1
    }

    private func printPathRow(row: Int, board: Board) {
        var line = "|" + "." * (totalWidthOfBoard(board) - 2) + "|"
        let vMarker = "#"
        let hMarker = "#####"

        for move in board.path.moves where move.from.y == row && move.to.y == row {
            let startIndex = line.startIndex.advancedBy(1 + min(move.to.x, move.from.x) * 4)
            let endIndex = startIndex.advancedBy(hMarker.characters.count)
            line.replaceRange(startIndex ..< endIndex, with: hMarker)
        }

        for position in board.path.positions where position.y == row {
            let startIndex = line.startIndex.advancedBy(1 + position.x * 4)
            let endIndex = startIndex.advancedBy(vMarker.characters.count)
            line.replaceRange(startIndex ..< endIndex, with: vMarker)
        }

        print(line)
    }
}

