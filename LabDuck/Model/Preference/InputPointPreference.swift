//
//  InputPointPreference.swift
//  LabDuck
//
//  Created by 정종인 on 5/14/24.
//

import SwiftUI

struct InputPointPreferenceKey: PreferenceKey {
    static var defaultValue = [InputPointPreference]()

    static func reduce(value: inout [InputPointPreference], nextValue: () -> [InputPointPreference]) {
        value.append(contentsOf: nextValue())
    }
}

struct InputPointPreference {
    let inputID: KPInputPoint.ID
    let bounds: Anchor<CGRect>
}
