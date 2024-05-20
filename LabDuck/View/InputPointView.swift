//
//  InputPointView.swift
//  LabDuck
//
//  Created by 정종인 on 5/14/24.
//

import SwiftUI

struct InputPointView: View {
    var inputPoint: KPInputPoint
    var body: some View {
        Image(systemName: "arrow.right.circle.fill")
            .imageScale(.large)
            .anchorPreference(
                key: InputPointPreferenceKey.self,
                value: .bounds
            ) {
                [InputPointPreference(inputID: inputPoint.id, bounds: $0)]
            }
    }
}

#Preview {
    InputPointView(inputPoint: .mockData)
}
