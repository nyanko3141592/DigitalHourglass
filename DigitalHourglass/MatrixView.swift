//
//  MatrixView.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/07.
//

import SwiftUI

struct MatrixView: View {
    @EnvironmentObject var colorSettings: EnvironmentVariables

    let matrix: [[Int]]
    let sandSize: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<matrix.count, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<matrix[row].count, id: \.self) { column in
                        let cellColor: Color = {
                            let cellValue = matrix[row][column]
                            if cellValue == 2 {
                                return colorSettings.glassColor
                            }else if cellValue == 0 {
                                return Color.clear
                            } else if cellValue == 1{
                                if row > matrix.count / 2 - 1 && column > matrix.count / 2 - 1{
                                    return colorSettings.matrix1Color
                                }else{
                                    return colorSettings.matrix2Color
                                }
                            }
                            return Color.clear
                        }()

                        ZStack{
                            Rectangle()
                                .frame(width: sandSize, height: sandSize)
                                .foregroundColor(Color.clear)
                            if matrix[row][column] == 1 || matrix[row][column] == 2 {
                                Rectangle()
                                    .frame(width: sandSize, height: sandSize)
                                    .foregroundColor(colorSettings.glassColor)
                                if matrix[row][column] == 1 {
                                    if colorSettings.isCircleSand {
                                        Circle()
                                            .frame(width: sandSize, height: sandSize)
                                            .overlay(Circle().strokeBorder(Color.black, lineWidth: 1))
                                            .foregroundColor(cellColor)
                                    } else{
                                        Rectangle()
                                            .frame(width: sandSize, height: sandSize)
                                            .overlay(Rectangle().strokeBorder(Color.black, lineWidth: 1))
                                            .foregroundColor(cellColor)
                                    }

                                }
                            }
                        }

                    }
                }
            }
        }
        .padding(0) // 余白を0に設定
        .rotationEffect(.degrees(45))
    }
}
