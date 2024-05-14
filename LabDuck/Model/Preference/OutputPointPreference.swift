//
//  OutputPointPreference.swift
//  LabDuck
//
//  Created by 정종인 on 5/14/24.
//

import SwiftUI

struct OutputPointPreferenceKey: PreferenceKey {
    static var defaultValue = [OutputPointPreference]()

    static func reduce(value: inout [OutputPointPreference], nextValue: () -> [OutputPointPreference]) {
        value.append(contentsOf: nextValue())
    }
}

struct OutputPointPreference {
    let outputID: KPOutputPoint.ID
    let bounds: Anchor<CGRect>
}
