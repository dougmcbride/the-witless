//  The Witless
//  Copyright (c) 2016 The Sneaky Frog. All rights reserved.

let things: [[Thing]] = [
        [.Star(.Black),   .Empty,       .Empty,       .Square(.Black)],
        [.Square(.White), .Square(.White), .Square(.Black),   .Empty],
        [.Square(.Black), .Empty,       .Square(.White), .Empty],
        [.Empty      , .Square(.Black), .Square(.White), .Star(.Black)],
]

let startingBoard = Board(width: 5, height: 5,
                          start: Position(2, 4), end: Position(2, 0),
                          things: things)

let solutionBoards = startingBoard.successfulBoards()
print("Found \(solutionBoards.count) possible solutions")

if let solution = solutionBoards.first {
    ASCIIRenderer().drawBoard(solution)
}

