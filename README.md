# The Witless

Starting a puzzle solver for [The Witness](https://en.wikipedia.org/wiki/The_Witness_(2016_video_game)).

```
let things: [[Thing]] = [
        [.BlackStar,   .Empty,       .Empty,       .BlackSquare],
        [.WhiteSquare, .WhiteSquare, .BlackStar,   .Empty],
        [.BlackSquare, .Empty,       .WhiteSquare, .Empty],
        [.Empty      , .BlackSquare, .WhiteSquare, .BlackStar],
]

let board = Board(width: 5, height: 5, start: Position(2, 4), end: Position(4, 0), things: things)

let boards = successfulBoards(board)
print("Found \(boards.count) possible solutions")

if let solution = boards.first {
    ASCIIRenderer().drawBoard(solution)
}
```

```
Found 22 possible solutions
___________________
|................#|
|.[*].........[B]#|
|#################|
|#[W].[W].[*].....|
|#####............|
|.[B]#....[W].....|
|....#####........|
|.....[B]#[W].[*].|
|........#........|
-------------------
```
