// Copyright © 2017 The Sneaky Frog
// See LICENSE.txt for licensing information

import Foundation

//let boardCells: [[Cell]] = [
//        [.Star(.Black),   .Empty,          .Empty,          .Square(.Black)],
//        [.Square(.White), .Square(.White), .Star(.Black),   .Empty],
//        [.Square(.Black), .Empty,          .Square(.White), .Empty],
//        [.Empty,          .Square(.Black), .Square(.White), .Star(.Black)]
// ]

// This is shorthand for the above
//let cells = try Cell.parse("EEEEE/WBEEE/BEWBB/EEEEE/WBEEE")
//let cells = try Cell.parse("PPWE/EEEE/GWWG/GEWW")
//let cells = try Cell.parse("EEEE/EEEE/EEEE")
//let cells = try Cell.parse(readLine(strippingNewline: true)!)
//let cells = try Cell.parse("pp/pp")
//let cells = try Cell.parse("bEEB/WWbE/BEWE/EBWb")

//var board = Board(startCorner: .lowerLeft, endCorner: .upperRight, cells: cells)

// The tough cylinder puzzle in the Secret Caverns
let cells = try Cell.parse("EEEEEE/222222/EEEEEE/111111/EEEEEE/222222")
var board = Board(start: Position(3, 6), end: Position(3, 0), cells: cells, wrapHorizontal: true)

let processInfo = ProcessInfo.processInfo
board.solutionStrategy = .first

let startTime = processInfo.systemUptime
let solutionStates = board.findSuccessfulBoardStates()
let timeInterval = processInfo.systemUptime - startTime

if solutionStates.isEmpty {
    print("Found no solutions, took \(timeInterval) seconds to search")
} else {
    switch board.solutionStrategy {
        case .all:
            print("Found \(solutionStates.count) possible solutions in \(timeInterval) seconds")
        case .first:
            print("Found a solution in \(timeInterval) seconds")
        case .shortestPath:
            print("Found shortest path in \(timeInterval) seconds")
    }
}

for solution in solutionStates {
    ASCIIRenderer().draw(boardState: solution)
    print(solution.path!.movesString)
//    let keystrokes = solution.path!.wasdMovesString + "W"

//    let task = Process()
//    task.launchPath = "/usr/bin/pbcopy"

//    let pipe = Pipe()
//    task.standardInput = pipe
//    task.launch()

//    let handle = pipe.fileHandleForWriting
//    handle.write(keystrokes.data(using: .utf8)!)
//    handle.closeFile()
}

