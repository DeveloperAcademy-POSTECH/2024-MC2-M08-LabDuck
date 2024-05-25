//
//  SearchTextKey.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/26/24.
//

import SwiftUI

private struct SearchTextKey: EnvironmentKey {
    static var defaultValue: String = ""
}

extension EnvironmentValues {
    var searchText: String {
        get { self[SearchTextKey.self] }
        set { self[SearchTextKey.self] = newValue }
    }
}

extension View {
    func searchText(_ searchText: String) -> some View {
        environment(\.searchText, searchText)
    }
}
