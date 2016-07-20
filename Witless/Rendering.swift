// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

protocol Renderer {
    func drawBoard(board: Board)
}

func *(string: String, times: Int) -> String {
    return String(count: times, repeatedValue: Character(string))
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
                    case .Triangle(let number):
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

    private func printColumnSeparator(board: Board, row: Int, column: Int) {
        if board.path!.segments.contains({ segment in
            if !(segment.from.x == column + 1 && segment.to.x == column + 1) {
                return false
            }
            return ((segment.from.y == row && segment.to.y == row + 1) || (segment.to.y == row && segment.from.y == row + 1))
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

        for segment in board.path!.segments where segment.from.y == row && segment.to.y == row {
            let startIndex = line.startIndex.advancedBy(1 + min(segment.to.x, segment.from.x) * 4)
            let endIndex = startIndex.advancedBy(hMarker.characters.count)
            line.replaceRange(startIndex ..< endIndex, with: hMarker)
        }

        for position in board.path!.positions where position.y == row {
            let startIndex = line.startIndex.advancedBy(1 + position.x * 4)
            let endIndex = startIndex.advancedBy(vMarker.characters.count)
            line.replaceRange(startIndex ..< endIndex, with: vMarker)
        }

        print(line)
    }
}

