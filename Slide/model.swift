//
//  model.swift
//  Slide
//
//  Created by Skylar Luo on 11/21/21.
//

import Combine
import Foundation
import CoreImage

struct SeededGenerator: RandomNumberGenerator {
    let seed: UInt64
    var curr: UInt64
    init(seed: UInt64 = 0) {
        self.seed = seed
        curr = seed
    }
    
    mutating func next() -> UInt64  {
        curr = (103 &+ curr) &* 65537
        curr = (103 &+ curr) &* 65537
        curr = (103 &+ curr) &* 65537
        return curr
    }
}


struct Tile: Equatable, Identifiable {

    var id : Int
    var lastRow : Int
    var lastCol : Int
    init(id: Int, lastRow: Int, lastCol: Int) {

        self.id = id
        self.lastRow = lastRow
        self.lastCol = lastCol
    }
}


enum Direction {
    case left
    case right
    case up
    case down
}

var id = 1



class Slides: ObservableObject {
    
    @Published var board: [[Tile?]] = Array(repeating: Array(repeating: nil, count: 4), count: 4)
    
    @Published var isDone: Bool = false
    @Published var isSolved: Bool = false
    @Published var recordedSlide: [(Int, Int, Direction)] = []
        
    var seededGenerator = SeededGenerator(seed: UInt64(Int.random(in:1...1000)))
    
    var missingPiece: Tile? = nil
    
    init() {
        for i in 0...3 {
            for j in 0...3 {
                board[i][j] = Tile(id: id, lastRow: i, lastCol: j);
                id += 1;
            }
        }
        
        let r = Int.random(in: 0...3, using: &seededGenerator)
        let c = Int.random(in: 0...3, using: &seededGenerator)
        
        missingPiece = board[r][c]
        
        board[r][c] = nil;
        
        //scramble(times: 1000)
    }
    
    
    func newGame() {
        id = 1
        for i in 0...3 {
            for j in 0...3 {
                board[i][j] = Tile(id: id, lastRow: i, lastCol: j);
                id += 1;
            }
        }
        
        let r = Int.random(in: 0...3, using: &seededGenerator)
        let c = Int.random(in: 0...3, using: &seededGenerator)
        
        missingPiece = board[r][c]
        
        board[r][c] = nil
        
        isDone = false
        recordedSlide = []
        
    }
    
    
    
    
    func shift(t: Tile?, dir: Direction) -> Bool {
        let boardCopy = board;
        
        if t != nil {
            let r = t!.lastRow
            let c = t!.lastCol
            
            switch dir {
                case Direction.left:
                    if c > 0 {
                        for i in 0...c-1 {
                            if board[r][i] == nil {
                                for j in i...c-1 {
                                    board[r][j] = board[r][j+1];
                                    board[r][j]!.lastCol -= 1;
                                }
                            }
                        }
                    }
                case Direction.right:
                    if c < 3 {
                        for i in 0...(3 - c - 1) {
                            if board[r][3 - i] == nil {
                                for j in i...3-c-1 {
                                    board[r][3 - j] = board[r][3 - j - 1];
                                    board[r][3 - j]!.lastCol += 1;
                                }
                            }
                        }
                    }
                case Direction.up:
                    if r > 0 {
                        for i in 0...r-1 {
                            if board[i][c] == nil {
                                for j in i...r-1 {
                                    board[j][c] = board[j+1][c];
                                    board[j][c]!.lastRow -= 1;
                                }
                            }
                        }
                    }
                case Direction.down:
                    if r < 3 {
                        for i in 0...(3 - r - 1) {
                            if board[3-i][c] == nil {
                                for j in i...3-r-1 {
                                    board[3-j][c] = board[3-j-1][c];
                                    board[3-j][c]!.lastRow += 1;
                                }
                            }
                        }
                    }
            }
            
            if boardCopy != board {
                board[r][c] = nil
                return true
            } else {
                return false
            }
        } else {
            return false
        }
        
        
    }
    
    func findMissingTile() -> (Int, Int) {
        for i in 0...3 {
            for j in 0...3 {
                if board[i][j] == nil {
                    return (i,j)
                }
            }
        }
        return (-1,-1)
    }
    
    func findMovableTile() -> [(Int, Int)] {
        var output: [(Int, Int)] = []
        let (r,c) = findMissingTile()
        
        for i in 0...3 {
            if board[i][c] != nil {
                output.append((i,c))
            }
            
            if board[r][i] != nil {
                output.append((r,i))
            }
        }
        return output
    }
    
    func shiftMovableTile(r: Int, c: Int, mr: Int, mc: Int) {
        if r == mr {
            
            if mc < c {
                shift(t: board[r][c], dir: Direction.left)
                recordedSlide.append((mr,mc,Direction.right))
            } else if mc > c {
                shift(t: board[r][c], dir: Direction.right)
                recordedSlide.append((mr,mc,Direction.left))
            }
        } else if c == mc {
            
            if  mr < r {
                shift(t: board[r][c], dir: Direction.up)
                recordedSlide.append((mr,mc,Direction.down))
            } else if mr > r {
                shift(t: board[r][c], dir: Direction.down)
                recordedSlide.append((mr,mc,Direction.up))
            }
        }
    }
    
    func scramble(times: Int) {
        
        for _ in 1...times {
            let (mr,mc) = findMissingTile()
            let movableTiles = findMovableTile()
            let randMoveTile = Int.random(in: 0...5, using: &seededGenerator)
            let (r,c) = movableTiles[randMoveTile]
            shiftMovableTile(r: r, c: c, mr: mr, mc: mc)
            
        }
    }
    
    
    func isGameDone() {
        var correctId = 1
        
        
        
        for r in board {
            for c in r {
                if (c != nil && c!.id == correctId) || c == nil {
                    correctId += 1
                } else {
                    isDone = false
                    return
                }
            }
        }
        
        isDone = true
    }
    
    
    func board2array() -> [Tile] {
        var tile: [Tile] = []
        for r in board {
            for t in r where t != nil {
                tile.append(t!)
            }
        }
        return tile
    }
    
    
    
}
