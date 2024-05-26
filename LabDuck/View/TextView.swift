//
//  TextView.swift
//  LabDuck
//
//  Created by Park Sang Wook on 5/25/24.
//

import SwiftUI

struct TextView: View {
    @EnvironmentObject var document: KPBoardDocument
    @Environment(\.undoManager) var undoManager
    var text: KPText
    @State private var isEditing: Bool = false
    @State private var tempText: String = ""

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
                        TextField("type anything...", text: $tempText, onCommit: {
                            self.isEditing = false
                            var newText = self.text
                            newText.text = tempText
                            document.updateText(newText, undoManager: undoManager, animation: nil)
                        })
                            .border(Color.blue.opacity(0.6))
                            .frame(width: 200, height: 50)
                        
                        Button(action: {
                            document.deleteText(self.text.id, undoManager: undoManager)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .offset(x: 10, y: 8)
                    }
                }
            } else {
                Text(text.unwrappedText.isEmpty ? "type anything..." : text.unwrappedText)
                    .onTapGesture(count: 1) {
                        self.isEditing = true
                    }
            }
        }
        .onAppear {
            self.tempText = self.text.unwrappedText
        }
    }
}

extension TextView: Equatable {
    static func == (lhs: TextView, rhs: TextView) -> Bool {
        lhs.text == rhs.text
    }
}

#Preview {
    TextView(text: .mockData)
}
