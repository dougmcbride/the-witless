//  The Witless
//  Copyright (c) 2016 The Sneaky Frog. All rights reserved.

//let things: [[Thing]] = [
//        [.Square(.Blue), .Square(.White), .Square(.White), .Empty, .Square(.Yellow), ],
//        [.Square(.Blue), .Empty, .Square(.Purple), .Empty, .Square(.Yellow), ],
//        [.Square(.Blue), .Empty, .Square(.Purple), .Empty, .Square(.Yellow), ],
//        [.Empty, .Empty, .Empty, .Square(.White), .Square(.White), ],
//
//]

let things = Thing.parseStars("YYYY/YYBR/BBBR/RRRR")

let startingBoard = Board(start: Position(0, 4), end: Position(4, 0),
                          things: things)

let solutionBoards = startingBoard.successfulBoards()
print("Found \(solutionBoards.count) possible solutions")

if let solution = solutionBoards.first {
    ASCIIRenderer().drawBoard(solution)
}

