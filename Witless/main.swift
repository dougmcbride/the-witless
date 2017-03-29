//  The Witless
//  Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

//let boardThings: [[Thing]] = [
//        [.Star(.Black),   .Empty,          .Empty,          .Square(.Black)],
//        [.Square(.White), .Square(.White), .Star(.Black),   .Empty],
//        [.Square(.Black), .Empty,          .Square(.White), .Empty],
//        [.Empty,          .Square(.Black), .Square(.White), .Star(.Black)]
// ]

// This is shorthand for the above
//let things = try Thing.parse("EEEEE/WBEEE/BEWBB/EEEEE/WBEEE")
//let things = try Thing.parse("EEEEEE/222222/EEEEEE/111111/EEEEEE/222222")
//let things = try Thing.parse("PPWE/EEEE/EWWG/GEWW")
let things = try Thing.parse(readLine(strippingNewline: true)!)

//let startingBoard = Board(start: RawPosition(3, 6), end: RawPosition(3, 0), things: things, wrapHorizontal: true)
//let startingBoard = Board(rawStartPositions: [RawPosition(0, 5)],
//                          rawEndPositions: [RawPosition(5, 0), RawPosition(5, 5)],
//                          things: boardThings,
//                          wrapHorizontal: false)

//let things = try Thing.parse("bEEB/WWbE/BEWE/EBWb")

let board = Board(start: Position(0, things.count), end: Position(things.count, 0), things: things)

let solutionStates = board.successfulBoardStates()
print("Found \(solutionStates.count) possible solutions")

if let solution = solutionStates.first {
    ASCIIRenderer().draw(boardState: solution)
    print(solution.path!.movesString)
    let keystrokes = solution.path!.wasdMovesString + "W"

    let task = Process()
    task.launchPath = "/usr/bin/pbcopy"

    let pipe = Pipe()
    task.standardInput = pipe
    task.launch()

    let handle = pipe.fileHandleForWriting
    handle.write(keystrokes.data(using: .utf8)!)
    handle.closeFile()
}

