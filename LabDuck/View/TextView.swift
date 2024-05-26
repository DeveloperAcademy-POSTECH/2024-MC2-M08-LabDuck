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
    @Environment(\.searchText) private var searchText

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
                HighlightText(fullText: text.unwrappedText.isEmpty ? "type anything..." : text.unwrappedText, searchText: searchText)
                    .onTapGesture(count: 1) {
                        self.isEditing = true
                    }
            }
        }
        .onAppear {
            self.tempText = self.text.unwrappedText
        }
    }

    func HighlightText(fullText: String, searchText: String) -> Text {
        guard !searchText.isEmpty else {
            return Text(fullText)
        }

        let ranges = rangesOfSubstring(fullText: fullText, searchText: searchText)

        var result = Text("")
        var currentIndex = fullText.startIndex

        for range in ranges {
            if range.lowerBound > currentIndex {
                let beforeMatch = fullText[currentIndex..<range.lowerBound]
                result = result + Text(beforeMatch)
            }

            let match = fullText[range]
            result = result + Text(match).bold().foregroundColor(.red)

            currentIndex = range.upperBound
        }

        if currentIndex < fullText.endIndex {
            let remainingText = fullText[currentIndex..<fullText.endIndex]
            result = result + Text(remainingText)
        }

        return result
    }

    func rangesOfSubstring(fullText: String, searchText: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchRange: Range<String.Index>?

        while let range = fullText.range(of: searchText, options: .caseInsensitive, range: searchRange ?? fullText.startIndex..<fullText.endIndex) {
            ranges.append(range)
            searchRange = range.upperBound..<fullText.endIndex
        }

        return ranges
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
