//
//  ContentView.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/05.
//

import SwiftUI

enum Direction {
    case upLeft, up, upRight, left, right, downLeft, down, downRight

    var move: (Int, Int) {
        switch self {
        case .upLeft:
            return (0, -1)
        case .up:
            return (-1, -1)
        case .upRight:
            return (-1, 0)
        case .left:
            return (1, -1)
        case .right:
            return (-1, 1)
        case .downLeft:
            return (1, 0)
        case .down:
            return (1, 1)
        case .downRight:
            return (0, 1)
        }
    }
}

struct SandClockView: View {
    // 1 : あり
    // 2 : なし
    // 0 : 枠ナシ
    @State var matrix: [[Int]] = combineMatrices(createZeroMatrix(size: 10, fillInt: 1), createZeroMatrix(size: 10, fillInt: 2))
    @State var timer: Timer?
    @State var direction: Direction = .down

    var body: some View {
        VStack {
            Spacer()
            MatrixView(matrix:matrix)
            Spacer()
            HStack{
                Button(action: {
                    // calc next matrix
                    direction = .upLeft
                }) {
                    Text("↖️")
                }
                Button(action: {
                    // calc next matrix
                    direction = .up
                }) {
                    Text("⬆️")
                }
                Button(action: {
                    direction = .upRight
                                }) {
                    Text("↗️")
                }
            }
            HStack{
                Button(action: {
                    // calc next matrix
                    direction = .left
                }) {
                    Text("⬅️")
                }
                Button(action: {
                    // calc next matrix
                    direction = .right}
                ){
                    Text("➡️")
                }
            }
            HStack{
                Button(action: {
                    // calc next matrix
                    direction = .downLeft
                }) {
                    Text("↙️")
                }
                Button(action: {
                    direction = .down
                }) {
                    Text("⬇️")
                }
                Button(action: {
                    // calc next matrix
                    direction = .downRight
                }) {
                    Text("↘️")
                }
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onAppear() {
            startTimer()
        }
    }

    func startTimer() {
        stopTimer() // Stop any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            matrix = nextMatrix(matrix: matrix, nextMove: direction.move)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
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
    let verticalMove: (Int, Int) = (nextMove.1, -nextMove.0)

    print("nextMove: \(nextMove)")

    var correctPoss: [(Int, Int)] = []
    for row in (0..<size).reversed() {
        for col in (0..<size).reversed() {
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
        nextPosRow.append(contentsOf: adjacentPos[0...2])

        // 隣接から一つ下の水平面を取得
        for i in 0..<2 {
            for j in 0..<2 {
                if i == 0 && j == 0 {
                    continue
                }
                let a = (nextPosRow[i].0 + verticalMove.0, nextPosRow[i].1 + verticalMove.1)
                if a == nextPosRow[j]{
                    print("a: \(a)")
                    for k in 0...size{
                        nextPosRow.append((a.0 + k * verticalMove.0, a.1 + k * verticalMove.1))
                        nextPosRow.append((a.0 - k * verticalMove.0, a.1 - k * verticalMove.1))
                    }
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
        print("nextPosRow: \(nextPosRow)")
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

    for row in stride(from: size - 1, through: 0, by: -1) {
        for col in stride(from: size - 1, through: 0, by: -1) {


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

#Preview {
    SandClockView()
}
