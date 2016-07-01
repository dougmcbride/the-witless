# The Witless

Starting a brute-force puzzle solver for [The Witness](https://en.wikipedia.org/wiki/The_Witness_(2016_video_game)).

```
let things = Thing.parseStars("YYYY/YYBR/BBBR/RRRR")

let startingBoard = Board(start: Position(0, 4), end: Position(4, 0),
                          things: things)

let solutionBoards = startingBoard.successfulBoards()
print("Found \(solutionBoards.count) possible solutions")

if let solution = solutionBoards.first {
    ASCIIRenderer().drawBoard(solution)
}
```

```
Found 5 possible solutions
___________________
|....#####.......#|
|.*Y*#*Y*#*Y*.*Y*#|
|....#...#####...#|
|.*Y*#*Y*.*B*#*R*#|
|....#####...#...#|
|.*B*.*B*#*B*#*R*#|
|........#...#####|
|.*R*.*R*#*R*.*R*.|
|#########........|
-------------------
```
