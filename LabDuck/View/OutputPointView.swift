//
//  OutputPointView.swift
//  LabDuck
//
//  Created by 정종인 on 5/14/24.
//

import SwiftUI

struct OutputPointView: View {
    var outputPoint: KPOutputPoint
    var body: some View {
        Image(systemName: "arrow.right.circle.fill")
            .imageScale(.large)
            .anchorPreference(
                key: OutputPointPreferenceKey.self,
                value: .bounds
            ) {
                [OutputPointPreference(outputID: outputPoint.id, bounds: $0)]
            }
    }
}

#Preview {
    OutputPointView(outputPoint: .mockData)
}
