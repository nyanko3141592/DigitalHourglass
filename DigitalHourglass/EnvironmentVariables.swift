//
//  ColorSettings.swift
//  DigitalHourglass
//
//  Created by 高橋直希 on 2024/06/08.
//

import SwiftUI

class EnvironmentVariables: ObservableObject {
    // Color
    @Published var matrix1Color: Color = .yellow
    @Published var matrix2Color: Color = .green
    @Published var backgroundColor: Color = .white
    @Published var glassColor: Color = .gray
    // Shape
    @Published var isCircleSand: Bool = false
    @Published var frameExist: Bool = true
}
