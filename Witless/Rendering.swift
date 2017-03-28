// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

protocol Renderer {
    func drawBoard(_ board: BoardState)
}

func *(string: String, times: Int) -> String {
    return String(repeating: string, count: times)
}

struct ASCIIRenderer: Renderer {
    func drawBoard(_ board: BoardState) {
        let width = totalWidthOfBoard(board)
        print("_" * width)

        for y in 0 ..< board.thingHeight {
            printPathRow(y, board: board)
            print("|", terminator: "")
            printColumnSeparator(board, row: y, column: -1)
            for x in 0 ..< board.thingWidth {
                let square: String
                switch board.things[y][x] {
                    case .empty:
                        square = "   "
                    case .square(let color):
                        square = "[\(color.rawValue)]"
                    case .star(let color):
                        square = "*\(color.rawValue)*"
                    case .triangle(let number):
                        square = "^\(number)^"
                }

                print(square, terminator: "")
                printColumnSeparator(board, row: y, column: x)
            }
            print("|")
        }

        printPathRow(board.thingHeight, board: board)
        print("-" * width)
    }

    private func printColumnSeparator(_ board: BoardState, row: Int, column: Int) {
        if board.path!.segments.contains(Segment(board.positionAt(column + 1, row)!,
                                                 board.positionAt(column + 1, row + 1)!)) {
            print("█", terminator: "")
        } else {
            print(" ", terminator: "")
        }
    }

    private func totalWidthOfBoard(_ board: BoardState) -> Int {
        return board.thingWidth * 3 + 4 + board.thingWidth - 1
    }

    private func printPathRow(_ row: Int, board: BoardState) {
        var line = "|" + " " * (totalWidthOfBoard(board) - 2) + "|"
        let vMarker = "█"
        let hMarker = "█" * 5

        for segment in board.path!.segments where segment.row == row {
            let startIndex = line.characters.index(line.startIndex, offsetBy: 1 + segment.minX * 4)
            let endIndex = line.characters.index(startIndex, offsetBy: hMarker.characters.count)
            line.replaceSubrange(startIndex ..< endIndex, with: hMarker)
        }

        for position in board.path!.positions where position.y == row {
            let startIndex = line.characters.index(line.startIndex, offsetBy: 1 + position.x * 4)
            let endIndex = line.characters.index(startIndex, offsetBy: vMarker.characters.count)
            line.replaceSubrange(startIndex ..< endIndex, with: vMarker)
        }

        print(line)
    }
}

