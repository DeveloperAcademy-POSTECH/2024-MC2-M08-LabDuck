//
//  TagsView.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/27/24.
//

import SwiftUI

struct TagsView: View {
    @EnvironmentObject var document: KPBoardDocument
    @Binding var totalHeight: CGFloat
    @Binding var isEditingForTag: Bool
    let tagIDs: [KPTag.ID]
    let verticalSpacing: CGFloat = 4
    let horizontalSpacing: CGFloat = 4

    var sortedTags: [KPTag] {
        tagIDs.compactMap { fetchTagDetails(by: $0) }.sorted(by: { $0.name < $1.name })
    }

    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(self.sortedTags, id: \.id) { tag in
                    Button(action: {
                        isEditingForTag.toggle()
                    }) {
                        HStack {
                            Text("#\(tag.name)")
                                .font(Font.custom("SF Pro", size: 13).weight(.semibold))
                                .foregroundColor(.white)
                        }
                        .padding(6)
                        .background(tag.colorTheme.backgroundColor)
                        .cornerRadius(6)
                        .frame(height: 40)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .alignmentGuide(.leading) { viewDimensions in
                        if abs(width - viewDimensions.width) > geometry.size.width {
                            width = 0
                            height -= viewDimensions.height
                            height -= verticalSpacing
                        }
                        let result = width
                        if tag == sortedTags.last {
                            width = 0
                        } else {
                            width -= viewDimensions.width
                            width -= horizontalSpacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if tag == sortedTags.last {
                            height = 0
                        }
                        return result
                    }
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                }
            )
        }
        .onPreferenceChange(HeightPreferenceKey.self) { totalHeight = $0 }
    }

    func fetchTagDetails(by id: UUID) -> KPTag? {
        return document.board.allTags.first(where: { $0.id == id })
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
