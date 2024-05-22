//
//  MainViewPreference.swift
//  LabDuck
//
//  Created by 정종인 on 5/20/24.
//

import SwiftUI

struct MainViewPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
