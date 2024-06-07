//
//  SettingView.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/07.
//

import SwiftUI

struct SettingsView: View {
    @Binding var matrixSize: Int
    @Binding var timerInterval: Double
    let onMatrixSizeChange: () -> Void
    let onTimerIntervalChange: () -> Void

    var body: some View {
        VStack {
            // 新しいText要素を追加
            Text("\(String(format: "%.1f", timerInterval * Double(matrixSize) * Double(matrixSize) / 60)) 分くらいで落ちるはず")
                .font(.title)

            Text("砂の数: \(matrixSize * matrixSize)")
                .padding()
            Slider(value: Binding(
                get: { Double(matrixSize) },
                set: { newValue in
                    matrixSize = Int(newValue)
                    onMatrixSizeChange()
                }
            ), in: 5...25, step: 1)
            .padding()

            Text("砂1粒の落ちる速さ： \(String(format: "%.1f", timerInterval))")
                .padding()

            Slider(value: $timerInterval, in: 0.01...1.0, step: 0.01) {
                Text("Timer Interval: \(String(format: "%.1f", timerInterval)) seconds")
            }
            .padding()
            .onChange(of: timerInterval) { _ in
                onTimerIntervalChange()
            }
        }
        .navigationTitle("Settings")
    }
}
