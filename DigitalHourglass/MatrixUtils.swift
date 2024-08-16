//
//  MatrixUtils.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/07.
//

import Foundation

struct MatrixUtils {
    static func create(size: Int, fill: Int) -> [[Int]] {
        Array(repeating: Array(repeating: fill, count: size), count: size)
    }

    static func combine(_ matrix1: [[Int]], _ matrix2: [[Int]]) -> [[Int]] {
        guard matrix1.count == matrix2.count, matrix1.first?.count == matrix2.first?.count else {
            fatalError("Matrices must be of the same size")
        }

        let size = matrix1.count
        var combinedMatrix = MatrixUtils.create(size: size * 2, fill: 0)

        // matrix1を左上に配置
        for row in 0..<size {
            for col in 0..<size {
                combinedMatrix[row][col] = matrix1[row][col]
            }
        }

        // matrix2を右下に配置
        for row in 0..<size {
            for col in 0..<size {
                combinedMatrix[row + size][col + size] = matrix2[row][col]
            }
        }

        return combinedMatrix
    }

    static func nextMatrix(_ matrix: [[Int]], _ nextMove: (Int, Int)) -> [[Int]] {
        let size = matrix.count
        var nextMatrix = matrix
        let verticalMove: (Int, Int) = (nextMove.1, -nextMove.0)

        if nextMove == (0,0){
            return matrix
        }
        
        var correctPoss: [(Int, Int)] = []
        var countArray = Array((0..<size))
        if nextMove == Direction.down.move{
            countArray = countArray.reversed()
        }
        for row in  countArray{
            for col in countArray {
                if matrix[row][col] == 1 {
                    correctPoss.append((row, col))
                }
            }
        }

        for (row, col) in correctPoss{
            if matrix[row][col] != 1 {
                continue
            }
            // belowPosの行
            var nextPosRow : [(Int, Int)] = []
            var belowPos = (row + nextMove.0, col + nextMove.1)
            nextPosRow.append(belowPos)

            // belowPosと元の位置を隣接するPosを追加
            var adjacentPos: [(Int, Int)] = []
            for i in -1...1 {
                for j in -1...1 {
                    if i == 0 && j == 0 {
                        continue
                    }
                    adjacentPos.append((row + i, col + j))
                }
            }
            // belowPosに近い順に並べる
            adjacentPos.sort(by: { (a, b) -> Bool in
                let aDist = abs(a.0 - belowPos.0) + abs(a.1 - belowPos.1)
                let bDist = abs(b.0 - belowPos.0) + abs(b.1 - belowPos.1)
                return aDist < bDist
            })

            // 元の位置の隣接から真下に近いもの3つ

            nextPosRow.append(contentsOf: adjacentPos[0...2].shuffled())

            // 隣接から一つ下の水平面を取得
            for i in 0..<2 {
                for j in 0..<2 {
                    if i == 0 && j == 0 {
                        continue
                    }
                    let a = (nextPosRow[i].0 + verticalMove.0, nextPosRow[i].1 + verticalMove.1)
                    if a == nextPosRow[j]{
                        var array: [(Int, Int)] = []
                        for k in 0...size{
                            array.append((a.0 + k * verticalMove.0, a.1 + k * verticalMove.1))
                            array.append((a.0 - k * verticalMove.0, a.1 - k * verticalMove.1))
                        }
                        nextPosRow.append(contentsOf: array.shuffled())
                    }
                }
            }

            // 手動で重複を削除
            var uniqueArray : [(Int, Int)] = []
            for item in nextPosRow {
                // 重複していないかをチェック
                if !uniqueArray.contains(where: { $0 == item }) {
                    uniqueArray.append(item)
                }
            }
            nextPosRow = uniqueArray
            // 移動
            for (nextRow, nextCol) in nextPosRow {
                if nextRow < 0 || nextRow >= size || nextCol < 0 || nextCol >= size {
                    // 次の位置が範囲外かどうかをチェック
                    continue
                }
                if nextMatrix[nextRow][nextCol] == 2 {
                    // 次の位置が空の場合
                    nextMatrix[row][col] = 2
                    nextMatrix[nextRow][nextCol] = 1
                    print("sand move to \(nextRow), \(nextCol) from \(row), \(col)")
                    break
                }
            }
        }

        // 下の行が空いていたら移動
        return nextMatrix
    }

}
