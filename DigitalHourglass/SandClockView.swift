//
//  ContentView.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/05.
//

import SwiftUI
import CoreMotion

enum Direction {
    case upLeft, up, upRight, left, right, downLeft, down, downRight, stop

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
        case .stop:
            return (0, 0)
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
    @State var isButtonDisabled = true
    @State var inclinationSensorIsActive = true
    @State private var motionManager = CMMotionManager()
    @State private var matrixSize: Int = 10
    @State private var timerInterval: Double = 0.1
    @State private var showingSettings = false

    // 画面サイズ
    let screenSize = UIScreen.main.bounds.size

    var body: some View {
        VStack {
            let sandSize: CGFloat = {
                let width = screenSize.width / CGFloat(matrix.count / 2) / 1.5
                let height = screenSize.height / CGFloat(matrix.count) / 1.5
                return width > height ? width : height
            }()

            ZStack {
                VStack {
                    Spacer()
                    MatrixView(matrix: matrix, sandSize: sandSize)
                    Spacer()
                }
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Rectangle()
                        .frame(width: screenSize.width, height: screenSize.height)
                        .foregroundColor(.clear)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(matrixSize: $matrixSize, timerInterval: $timerInterval, onMatrixSizeChange: updateMatrix, onTimerIntervalChange: updateTimer)
                }

            }
        }
        .onDisappear {
            stopTimer()
            motionManager.stopDeviceMotionUpdates()
        }
        .onAppear {
            startTimer()
            startMonitoringDeviceMotion()
        }

    }
    private func updateMatrix() {
        matrix = combineMatrices(createZeroMatrix(size: matrixSize, fillInt: 1), createZeroMatrix(size: matrixSize, fillInt: 2))
    }

    private func updateTimer() {
        timer?.invalidate()
        startTimer()
    }

    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            matrix = nextMatrix(matrix: matrix, nextMove: direction.move)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startMonitoringDeviceMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, _) in
            guard let motion = motion, inclinationSensorIsActive else { return }
            direction = DirectionCalculator.calculate(pitch: motion.attitude.pitch, roll: motion.attitude.roll)
        }
    }

}

struct DirectionCalculator {
    static func calculate(pitch: Double, roll: Double) -> Direction {
        let threshold: Double = 0.2
        let stopThreshold: Double = 0.1

        if abs(pitch) < stopThreshold && abs(roll) < stopThreshold {
            return .stop
        } else if pitch > threshold && roll > threshold {
            return .downRight
        } else if pitch > threshold && roll < -threshold {
            return .downLeft
        } else if pitch < -threshold && roll > threshold {
            return .upRight
        } else if pitch < -threshold && roll < -threshold {
            return .upLeft
        } else if abs(pitch) > abs(roll) {
            return pitch > threshold ? .down : .up
        } else {
            return roll > threshold ? .right : .left
        }
    }
}

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

    if nextMove == (0,0){
        return matrix
    }

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

#Preview {
    SandClockView()
}
