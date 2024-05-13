//
//  KPColorTheme.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

enum KPColorTheme {
    case `default`
    case cyan

    var backgroundColor: Color {
        switch self {
        case .default:
            return Color.white
        case .cyan:
            return Color.blue
        }
    }
    var foregroundColor: Color {
        switch self {
        case .default:
            return Color.black
        case .cyan:
            return Color.black
        }
    }
}
