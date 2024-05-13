//
//  GraphView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct GraphView: View {
    @State private var nodes: [KPNode] = .mockData
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach($nodes) { node in
                    NodeView(node: node)
                }
            }
        }
    }
}

#Preview {
    GraphView()
}
