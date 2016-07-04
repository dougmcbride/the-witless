# The Witless

A brute-force puzzle solver for a subset of puzzles in [The Witness](https://en.wikipedia.org/wiki/The_Witness_(2016_video_game)).

```
let g: [[Thing]] = [
        [.Star(.Black),   .Empty,          .Empty,          .Square(.Black)],
        [.Square(.White), .Square(.White), .Star(.Black),   .Empty],
        [.Square(.Black), .Empty,          .Square(.White), .Empty],
        [.Empty,          .Square(.Black), .Square(.White), .Star(.Black)]
 ]

// This is shorthand for the above
let things = Thing.parse("bEEB/WWbE/BEWE/EBWb")

let startingBoard = Board(start: Position(2, 4), end: Position(4, 0),
                          things: things)

let solutionBoards = startingBoard.successfulBoards()
print("Found \(solutionBoards.count) possible solutions")

if let solution = solutionBoards.first {
    ASCIIRenderer().drawBoard(solution)
}
```

```
Found 22 possible solutions
___________________
|................#|
|.*B*.........[B]#|
|#################|
|#[W].[W].*B*.....|
|#####............|
|.[B]#....[W].....|
|....#####........|
|.....[B]#[W].*B*.|
|........#........|
-------------------
```
