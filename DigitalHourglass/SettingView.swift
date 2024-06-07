//
//  SettingView.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/07.
//

import SwiftUI

struct SettingsView: View {
    @Binding var timerDuration: Int
    let onMatrixSizeChange: () -> Void
    let onTimerDurationChange: () -> Void

    var body: some View {
        VStack {
            // 新しいText要素を追加
            Text("\(String(timerDuration)) 秒計")
                .font(.title)

            Slider(value: Binding(
                get: { Double(timerDuration) },
                set: { newValue in
                    timerDuration = Int(newValue)
                    onTimerDurationChange()
                }
            ), in: 10...500, step: 10) {
                Text("Timer Interval: \(String(format: "%.f", timerDuration)) seconds")
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}
