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
    @State var matrix1: [[Int]] = MatrixUtils.create(size: 10, fill: 1)
    @State var matrix2: [[Int]] = MatrixUtils.create(size: 10, fill: 2)
    @State var matrix: [[Int]] = MatrixUtils.create(size: 20, fill: 2)
    @State var timer: Timer?
    @State var direction: Direction = .down
    @State var isButtonDisabled = true
    @State var inclinationSensorIsActive = true
    @State private var motionManager = CMMotionManager()
    @State private var matrixSize: Int = 10
    @State private var showingSettings = false
    @State private var dropCount: Int = 0
    @State var timerDuration: Int = 100
    @State var trueGravity = true

    @StateObject var colorSettings = EnvironmentVariables()
    // 画面サイズ
    let screenSize = UIScreen.main.bounds.size
    let adBannerHeight: CGFloat = 50

    var body: some View {
        VStack {
            let sandSize: CGFloat = {
                let width = screenSize.width / CGFloat(matrix.count / 2) / 1.6
                let height = (screenSize.height - adBannerHeight) / CGFloat(matrix.count) / 1.6
                return width > height ? width : height
            }()

            Rectangle()
                .frame(width: screenSize.width, height: adBannerHeight)
                .foregroundColor(.red)

            ZStack {
                VStack {
                    Spacer()
                    MatrixView(matrix: matrix, sandSize: sandSize)
                        .environmentObject(colorSettings)
                    Spacer()
                }
                VStack{
                    HStack{
                        // reverse button
                        Button(action: {
                            trueGravity.toggle()
                        }) {
                            // reverse icon
                            if trueGravity {
                                Image(systemName: "arrow.counterclockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.accentColor)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        Spacer()
                            .frame(width: screenSize.width - 100)
                       // setting button
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            // setting icon
                            Image(systemName: "gearshape.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.accentColor)
                        }
                        .sheet(isPresented: $showingSettings) {
                            SettingsView(timerDuration: $timerDuration, onMatrixSizeChange: updateMatrix, onTimerDurationChange: updateTimer)
                                .environmentObject(colorSettings)
                        }
                    }
                    .padding()
                    Spacer()
                }
                .padding()
            }
        }
        .background(colorSettings.backgroundColor)
        .onDisappear {
            stopTimer()
            motionManager.stopDeviceMotionUpdates()
        }
        .onAppear {
            startTimer()
            matrix = MatrixUtils.combine(matrix1, matrix2)
            startMonitoringDeviceMotion()
        }

    }
    private func updateMatrix() {
        matrix = MatrixUtils.combine(MatrixUtils.create(size: matrixSize, fill: 1), MatrixUtils.create(size: matrixSize, fill: 2))
    }


    private func updateTimer() {
        stopTimer()
        startTimer()
    }

    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1 / 10, repeats: true) { _ in
            // 10 dropにつき1回は結合
            if (direction.move == Direction.down.move || direction.move == Direction.up.move) && dropCount % (timerDuration / matrixSize) == 0 {
                matrix = MatrixUtils.nextMatrix(MatrixUtils.combine(matrix1, matrix2), direction.move)
                // matrix1とmatrix2を分離
                matrix1 = extractSubArray(from: matrix, startX: 0, startY: 0, size: matrixSize)
                matrix2 = extractSubArray(from: matrix, startX: matrixSize, startY: matrixSize, size: matrixSize)
                dropCount = 0
            } else {
                matrix1 = MatrixUtils.nextMatrix(matrix1, direction.move)
                matrix2 = MatrixUtils.nextMatrix(matrix2, direction.move)
                matrix = MatrixUtils.combine(matrix1, matrix2)
            }
            dropCount += 1
        }
    }

    func extractSubArray(from array: [[Int]], startX: Int, startY: Int, size: Int) -> [[Int]] {
        var subArray: [[Int]] = []
        for y in startY..<(startY + size) {
            var row: [Int] = []
            for x in startX..<(startX + size) {
                row.append(array[y][x])
            }
            subArray.append(row)
        }
        return subArray
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
            direction = DirectionCalculator.calculate(pitch: motion.attitude.pitch, roll: motion.attitude.roll, currentGravity: trueGravity)
        }
    }

}

struct DirectionCalculator {
    static func calculate(pitch: Double, roll: Double, currentGravity: Bool) -> Direction {
        let threshold: Double = 0.1
        let stopThreshold: Double = 0.1

        if abs(pitch) < stopThreshold && abs(roll) < stopThreshold {
            return .stop
        } else if pitch > threshold && roll > threshold {
            return currentGravity ? .downRight : .upLeft
        } else if pitch > threshold && roll < -threshold {
            return currentGravity ? .downLeft : .upRight
        } else if pitch < -threshold && roll > threshold {
            return currentGravity ? .upRight : .downLeft
        } else if pitch < -threshold && roll < -threshold {
            return currentGravity ? .upLeft : .downRight
        } else if abs(pitch) > abs(roll) {
            return pitch > threshold ? (currentGravity ? .down : .up) : (currentGravity ? .up : .down)
        } else {
            return roll > threshold ? (currentGravity ? .right : .left) : (currentGravity ? .left : .right)
        }
    }
}

#Preview {
    SandClockView()
}
