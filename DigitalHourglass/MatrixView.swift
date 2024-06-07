//
//  MatrixView.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/07.
//

import SwiftUI

struct MatrixView: View {
    let matrix: [[Int]]
    let sandSize: CGFloat

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

