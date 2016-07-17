//  The Witless
//  Copyright (c) 2016 The Sneaky Frog. All rights reserved.

let boardThings: [[Thing]] = [
        [.Star(.Black),   .Empty,          .Empty,          .Square(.Black)],
        [.Square(.White), .Square(.White), .Star(.Black),   .Empty],
        [.Square(.Black), .Empty,          .Square(.White), .Empty],
        [.Empty,          .Square(.Black), .Square(.White), .Star(.Black)]
 ]

// This is shorthand for the above
let things = try Thing.parse("bEEB/WWbE/BEWE/EBWb")

let startingBoard = Board(start: Position(2, 4), end: Position(4, 0),
                          things: things)

let solutionBoards = startingBoard.successfulBoards()
print("Found \(solutionBoards.count) possible solutions")

if let solution = solutionBoards.first {
    ASCIIRenderer().drawBoard(solution)
}

