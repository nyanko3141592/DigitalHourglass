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
    var matrix1: [[Int]] = createZeroMatrix(size: 10, fillInt: 1)
    var matrix2: [[Int]] = createZeroMatrix(size: 10, fillInt: 2)


    var body: some View {
        VStack {
            MatrixView(matrix: combineMatrices(matrix1, matrix2))
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

struct MatrixView: View {
    let matrix: [[Int]]
    let sandSize: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<matrix.count, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<matrix[row].count, id: \.self) { column in
                        Text("")
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

struct ContentView: View {
    var body: some View {
        VStack {
            // ここに他のコンテンツを追加できます
        }
    }
}

#Preview {
    SandClockView()
}
