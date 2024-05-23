//
//  TagPOPUP.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/23/24.
//

import SwiftUI

struct TagPopupView: View {
    @Binding var isEditingForTag: Bool
    @Binding var node: KPNode
    @State private var hoveredForClosingTagView: Bool = false
    @State private var textForTags: String = ""
    @State private var previewTag: KPTag?
    
    var body: some View {
        VStack (alignment:.leading){
            HStack{
                Spacer()
                Button{
                    isEditingForTag = false
                }label: {
                    Image(systemName: "xmark.circle").foregroundColor(.gray)
                        .opacity(self.hoveredForClosingTagView ? 1.0 : 0.3)
                        .onHover { hover in
                            print("Mouse hover: \(hover)")
                            self.hoveredForClosingTagView = hover
                        }
                }.buttonStyle(BorderlessButtonStyle())
            }
            
            TextField("Enter text", text: $textForTags, onCommit: {
                addPreviewTag()
            }).foregroundColor(.blue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if previewTag != nil {
                Text("#\(textForTags)")
                    .padding(8)
                    .background(.gray)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Button{
                    createTag()
                }label: {
                    Text("생성").foregroundColor(.blue)
                }
                .padding(.top, 5)
            }
            
            Divider().padding()
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(node.tags) { tag in
                    Text("#\(tag.name)")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .frame(width:200)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
    
    private func addPreviewTag() {
        guard !textForTags.isEmpty else { return }
        let newTagForPreview = KPTag(id: UUID(), name: textForTags, colorTheme: KPTagColor.blue)
        previewTag = newTagForPreview
    }
    
    private func createTag() {
        guard let previewTag = previewTag else { return }
        node.tags.append(previewTag)
        self.previewTag = nil
        self.textForTags = ""
    }
}
