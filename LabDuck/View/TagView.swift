//
//  TagView.swift
//  LabDuck
//
//  Created by Hajin on 5/23/24.
//

import SwiftUI

struct TagView: View, Identifiable {
    let id = UUID()
    let text: String
    private let backgroundColor: Color

    init(text: String) {
        self.text = text
        self.backgroundColor = Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }

    var body: some View {
        HStack {
            Text("#\(text)")
                .padding(8)
                .background(backgroundColor)
                .cornerRadius(8)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    TagView()
}
