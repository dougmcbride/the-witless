//  The Witless
//  Copyright (c) 2016 The Sneaky Frog. All rights reserved.

let boardThings: [[Thing]] = [
        [.Star(.Black),   .Empty,          .Empty,          .Square(.Black)],
        [.Square(.White), .Square(.White), .Star(.Black),   .Empty],
        [.Square(.Black), .Empty,          .Square(.White), .Empty],
        [.Empty,          .Square(.Black), .Square(.White), .Star(.Black)]
 ]

// This is shorthand for the above
//let things = Thing.parse("EEEEE/WBEEE/BEWBB/EEEEE/WBEEE")
let things = try Thing.parse("EEEEEE/222222/EEEEEE/111111/EEEEEE/222222")

let startingBoard = Board(start: RawPosition(3, 6), end: RawPosition(3, 0), things: things, wrapHorizontal: true)
//let startingBoard = Board(width: 6, height: 6,
//                          startPositions: [Position(0, 5)],
//                          endPositions: [Position(5, 0), Position(5, 5)],
//                          path: Path(),
//                          things: things)

let solutionBoards = startingBoard.successfulBoards()
print("Found \(solutionBoards.count) possible solutions")

for board in  solutionBoards {
    ASCIIRenderer().drawBoard(board)
}

