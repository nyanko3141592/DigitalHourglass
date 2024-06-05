//
//  ContentView.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/05.
//

import SwiftUI

struct SandClockView: View {
    let size: Int = 10
    // 1 : あり
    // 2 : なし
    // 0 : 枠ナシ
    @State var matrix: [[Int]] = combineMatrices(createZeroMatrix(size: 10, fillInt: 1), createZeroMatrix(size: 10, fillInt: 2))

    var body: some View {
        VStack {
            Spacer()
            MatrixView(matrix:matrix)
            Spacer()
            Button(action: {
                // calc next matrix
                matrix = nextMatrix(matrix: matrix, nextMove: (1, 1))
            }) {
                Text("Next")
            }
        }
    }
}


// 指定されたサイズの0で埋められた正方行列を生成する関数
func createZeroMatrix(size: Int, fillInt: Int = 0) -> [[Int]] {
    return Array(repeating: Array(repeating: fillInt, count: size), count: size)
}

// 2つの2次元配列を指定の形で結合する関数
func combineMatrices(_ matrix1: [[Int]], _ matrix2: [[Int]]) -> [[Int]] {
    guard matrix1.count == matrix2.count, matrix1.first?.count == matrix2.first?.count else {
        fatalError("Matrices must be of the same size")
    }

    let size = matrix1.count
    var combinedMatrix = createZeroMatrix(size: size * 2)

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

func nextMatrix(matrix: [[Int]], nextMove: (Int, Int)) -> [[Int]] {
    let size = matrix.count
    var nextMatrix = matrix

    for row in stride(from: size - 1, through: 0, by: -1) {
        for col in stride(from: size - 1, through: 0, by: -1) {
            if matrix[row][col] != 1 {
                continue
            }
            // 真下に移動
            // 次の位置を計算
            let nextPos = (row + nextMove.0, col + nextMove.1)
            if nextPos.0 < 0 || nextPos.0 >= size || nextPos.1 < 0 || nextPos.1 >= size {
                // 次の位置が範囲外かどうかをチェック
                continue
            } else if matrix[nextPos.0][nextPos.1] == 2 {
                // 次の位置が空の場合
                nextMatrix[row][col] = 2
                nextMatrix[nextPos.0][nextPos.1] = 1
                continue
            }

        }
    }

    // 下の行が空いていたら移動
    return nextMatrix
}

struct MatrixView: View {
    let matrix: [[Int]]
    let sandSize: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<matrix.count, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<matrix[row].count, id: \.self) { column in
                        Text("\(matrix[row][column])")
                            .frame(width: sandSize, height: sandSize)
                            .border(matrix[row][column] != 0 ? Color.black : Color.clear, width: 1)
                            .background(matrix[row][column] != 1 ? Color.clear : Color.yellow)
                    }
                }
            }
        }
        .padding(0) // 余白を0に設定
        .rotationEffect(.degrees(45))
    }
}

#Preview {
    SandClockView()
}
