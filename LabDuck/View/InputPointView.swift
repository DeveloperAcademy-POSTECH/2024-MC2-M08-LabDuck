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
        Circle()
            .fill(Color.green)
            .frame(width: 20, height: 20)
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
