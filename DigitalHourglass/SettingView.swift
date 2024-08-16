//
//  SettingView.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/07.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var colorSettings: EnvironmentVariables

    @Binding var timerDuration: Int
    let onMatrixSizeChange: () -> Void
    let onTimerDurationChange: () -> Void
    let buttonSize: CGFloat = 100

    var body: some View {
        ScrollView{
            Text("\(String(timerDuration)) 秒計")
                .font(.title)
                .padding()

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

            HStack {
                Text("0")
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                ForEach(Array(stride(from: 10, through: 500, by: 10)), id: \.self) { value in
                    if value % 100 == 0 {
                        Text("\(value)")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            // +- ボタンの追加
            HStack {
                Button(action: {
                    if timerDuration > 10 {
                        timerDuration -= 10
                        onTimerDurationChange()
                    }
                }) {
                    // font size 100
                    Text("-")
                        .font(.system(size: buttonSize * 0.5))
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(buttonSize / 2)
                }
                .padding()

                Button(action: {
                    if timerDuration < 500 {
                        timerDuration += 10
                        onTimerDurationChange()
                    }
                }) {
                    Text("+")
                        .font(.system(size: buttonSize * 0.5))
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(buttonSize / 2)
                }
                .padding()
            }

            ColorPicker("Background", selection: $colorSettings.backgroundColor)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            ColorPicker("Upper Glass", selection: $colorSettings.matrix1Color)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            ColorPicker("Lower Glass", selection: $colorSettings.matrix2Color)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            ColorPicker("Glass Glass", selection: $colorSettings.glassColor)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            // 色の初期化ボタンの追加
            Button(action: {
                resetColors()
            }) {
                Text("Reset Colors")
                    .font(.system(size: 20))
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // toggle button
            Toggle(isOn: $colorSettings.isCircleSand) {
                Text("Circle Sand")
            }
            .padding()

            // toggle button
            Toggle(isOn: $colorSettings.frameExist) {
                Text("Cell Frame")
            }
            .padding()

            Spacer()
        }
        .navigationTitle("Settings")
    }

    // 色を初期状態に戻すメソッド
    private func resetColors() {
        colorSettings.matrix1Color = .yellow
        colorSettings.matrix2Color = .green
        colorSettings.backgroundColor = .white
        colorSettings.glassColor = .gray
    }
}

