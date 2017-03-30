// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

import Foundation

protocol Renderer {
    func draw(boardState: BoardState)
}

func *(string: String, times: Int) -> String {
    return String(repeating: string, count: times)
}

struct ASCIIRenderer: Renderer {
    func draw(boardState: BoardState) {
        let board = boardState.board
        let horizontalEdgeString = board.xWrapping ? " " : "|"

        let width = totalWidth(of: board)
        print("_" * width)

        for y in 0 ..< board.cellHeight {
            printPathRow(rowIndex: y, boardState: boardState)
            print(horizontalEdgeString, terminator: "")
            printColumnSeparator(boardState, row: y, column: -1)
            for x in 0 ..< board.cellWidth {
                let square: String

                switch board.cells[y][x] {
                    case .empty:
                        square = "   "
                    case .square(let color):
                        square = "[\(color)]"
                    case .star(let color):
                        square = "*\(color)*"
                    case .triangle(let number):
                        square = "^\(number)^"
                }

                print(square, terminator: "")

                if !(board.xWrapping && x == board.cellWidth - 1) {
                    printColumnSeparator(boardState, row: y, column: x)
                }
            }
            print(horizontalEdgeString)
        }

        printPathRow(rowIndex: board.cellHeight, boardState: boardState)
        print("-" * width)
    }

    private func printColumnSeparator(_ boardState: BoardState, row: Int, column: Int) {
        if boardState.path!.segments.contains(Segment(boardState.board.positionAt(column + 1, row)!,
                                                      boardState.board.positionAt(column + 1, row + 1)!)) {
            print("█", terminator: "")
        } else {
            print(" ", terminator: "")
        }
    }

    private func totalWidth(of board: Board) -> Int {
        return board.cellWidth * 3 + 4 + board.cellWidth - 1
    }

    private func printPathRow(rowIndex row: Int, boardState: BoardState) {
        let horizontalEdgeString = boardState.board.xWrapping ? " " : "|"
        var line = horizontalEdgeString + " " * (totalWidth(of: boardState.board) - 2) + horizontalEdgeString
        let vMarker = "█"
        let hMarker = "█" * 5

        for segment in boardState.path!.segments where segment.row == row {
            let startIndex = line.characters.index(line.startIndex, offsetBy: 1 + segment.minX * 4)
            let endIndex = line.characters.index(startIndex, offsetBy: hMarker.characters.count)
            line.replaceSubrange(startIndex ..< endIndex, with: hMarker)
        }

        for position in boardState.path!.positions where position.y == row {
            let startIndex = line.characters.index(line.startIndex, offsetBy: 1 + position.x * 4)
            let endIndex = line.characters.index(startIndex, offsetBy: vMarker.characters.count)
            line.replaceSubrange(startIndex ..< endIndex, with: vMarker)
        }

        print(line)
    }
}

