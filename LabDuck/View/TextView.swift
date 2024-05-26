//
//  TextView.swift
//  LabDuck
//
//  Created by Park Sang Wook on 5/25/24.
//

import SwiftUI

struct TextView: View {
    @Binding var text: KPText
    @Binding var board: KPBoard
    @State private var isEditing: Bool = false

    var body: some View {
        ZStack {
            if isEditing {
                Color.clear // Transparent background to detect taps
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.isEditing = false
                    }
                
                HStack {
                    ZStack(alignment: .topTrailing) {
                        TextField("type anything...", text: $text.unwrappedText, onCommit: {
                            self.isEditing = false
                        })
                            .border(Color.blue.opacity(0.6))
                            .frame(width: 200, height: 50)
                        
                        Button(action: {
                            board.deleteDefaultText(text.id)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .offset(x: 10, y: 8)
                    }
                }
            } else {
                Text(text.unwrappedText)
                    .onTapGesture(count: 1) {
                        self.isEditing = true
                    }
            }
        }
    }
}

#Preview {
    TextView(text: .constant(.mockData), board: .constant(.mockData))
}
