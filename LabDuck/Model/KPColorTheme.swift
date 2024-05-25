//
//  KPColorTheme.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

enum KPColorTheme: Int, CaseIterable, Hashable, Codable {
    case `default`
    case red
    case orange
    case yellow
    case green
    case blue
    case lavender
    case purple

    var backgroundColor: Color {
        switch self {
        case .default:
            return Color.white
        case .red:
            return Color(hex: 0xFFC4C1)
        case .orange:
            return Color(hex: 0xFFDFB2)
        case .yellow:
            return Color(hex: 0xFFF0B2)
        case .green:
            return Color(hex: 0xBEF0C6)
        case .blue:
            return Color(hex: 0xB2D7FF)
        case .lavender:
            return Color(hex: 0xE7CBF5)
        case .purple:
            return Color(hex: 0xCDCCF3)
        }
    }
    var foregroundColor: Color {
        switch self {
        case .default, .red, .orange, .yellow, .green, .blue, .lavender, .purple:
            return Color.black
        }
    }
}
