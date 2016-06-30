// Copyright (c) 2016 The Sneaky Frog. All rights reserved.

import Foundation

struct Path {
    let positions: [Position]

    init(positions: [Position] = []) {
        self.positions = positions
    }

    var moves: [Move] {
        let length = positions.count - 1

        if length < 0 {
            return []
        }

        let prefix = positions.prefix(length)
        let suffix = positions.suffix(length)
        return zip(prefix, suffix).map {
            Move(from: $0.0, to: $0.1)
        }
    }

    func contains(position: Position) -> Bool {
        return positions.contains {
            $0 == position
        }
    }

    func add(position: Position) -> Path {
        var newPositions = positions
        newPositions.append(position)
        return Path(positions: newPositions)
    }
}