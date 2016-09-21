//  The Witless
//  Copyright (c) 2016 The Sneaky Frog. All rights reserved.

//let boardThings: [[Thing]] = [
//        [.Star(.Black),   .Empty,          .Empty,          .Square(.Black)],
//        [.Square(.White), .Square(.White), .Star(.Black),   .Empty],
//        [.Square(.Black), .Empty,          .Square(.White), .Empty],
//        [.Empty,          .Square(.Black), .Square(.White), .Star(.Black)]
// ]

// This is shorthand for the above
//let things = try Thing.parse("EEEEE/WBEEE/BEWBB/EEEEE/WBEEE")
//let things = try Thing.parse("EEEEEE/222222/EEEEEE/111111/EEEEEE/222222")
let things = try Thing.parse("PPWE/EEEE/EWWG/GEWW")

//let startingBoard = Board(start: RawPosition(3, 6), end: RawPosition(3, 0), things: things, wrapHorizontal: true)
//let startingBoard = Board(rawStartPositions: [RawPosition(0, 5)],
//                          rawEndPositions: [RawPosition(5, 0), RawPosition(5, 5)],
//                          things: boardThings,
//                          wrapHorizontal: false)

//let things = try Thing.parse("bEEB/WWbE/BEWE/EBWb")

let startingBoard = Board(start: RawPosition(0, 4), end: RawPosition(4, 0),
                          things: things)

let solutionBoards = startingBoard.successfulBoards()
print("Found \(solutionBoards.count) possible solutions")

for board in  solutionBoards {
    ASCIIRenderer().drawBoard(board)
}

