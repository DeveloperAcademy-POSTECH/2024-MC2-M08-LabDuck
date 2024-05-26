//
//  TagPOPUP.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/23/24.
//

import SwiftUI

struct TagPopupView: View {
    @EnvironmentObject var document: KPBoardDocument
    @Environment(\.undoManager) var undoManager
    @Binding var isEditingForTag: Bool
    var node: KPNode
    @State private var hoveredForClosingTagView: Bool = false
    @State private var textForTags: String = ""
    @State private var previewTag: KPTag?

    @State private var hovered: Bool = false


    var body: some View {
        VStack (alignment:.leading,spacing: 0){
            HStack {
                ZStack(alignment: .leading) {
                    if textForTags.isEmpty {
                        Text("텍스트 입력").font(.system(size:13))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    TextField("", text: $textForTags, onCommit: {
                        addPreviewTag()
                    })
                    .padding(.horizontal)
                    .foregroundColor(.black)
                    .background(Color.clear)
                    .textFieldStyle(PlainTextFieldStyle())
                } .padding(.leading, 10)

                Button {
                    isEditingForTag = false
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.gray)
                .background(.gray.opacity(self.hovered ? 0.1 : 0.0))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onHover { hover in
                    self.hovered = hover
                }
                .padding(.trailing, 10)

            }.frame(width: 250, height: 50)
                .background(Color(hex: 0xF0F0F0))


            VStack(alignment: .leading, spacing:10){
                if previewTag != nil {
                    HStack(spacing: 20){


                        //태그 생성 버튼
                        Button {
                            createTag()
                        } label: {
                            Text("생성").foregroundColor(.black)
                        }.buttonStyle(BorderlessButtonStyle())
                            .padding(.leading, 10)
                            .padding(.top,10)
                            .padding(.bottom,10)



                        //태그 프리뷰

                        Text("#\(textForTags)")
                            .padding(8)
                            .background(previewTag!.colorTheme.backgroundColor)
                            .cornerRadius(6)
                            .foregroundColor(.white)
                            .padding(.top,10)
                            .padding(.bottom,10)


                        Spacer()

                    }.background(Color(hex: 0xF0F0F0))
                        .frame(width: 234, height: 40)
                        .cornerRadius(6)
                        .padding(10)
                }

                if !node.tags.isEmpty {
                    Text("선택된 태그").foregroundColor(.gray).font(.system(size:11)).padding(5)
                }

                //태그 뷰의 태그 출력
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(node.tags, id: \.self) { tagID in
                        if let tag = document.board.getTag(tagID) {
                            HStack {
                                Text("#\(tag.name)")
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                                    .background(tag.colorTheme.backgroundColor)
                                    .cornerRadius(6)
                                Spacer()
                                Button {
                                    let filteredTags = node.tags.filter { $0 != tagID }
                                    document.updateNode(node.id, tags: filteredTags, undoManager: undoManager)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.borderless)

                            }
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                        }
                    }
                }

                if !document.board.allTags.isEmpty{
                    Text("태그 선택").foregroundColor(.gray).font(.system(size:11)).padding(5)
                }
                // 중복 제거된 태그 표시
                ForEach(document.board.allTags) { tag in
                    HStack{
                        Text("#\(tag.name)")
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                            .background(tag.colorTheme.backgroundColor)
                            .cornerRadius(6)
                        Spacer()
                        Button{
                            document.addTag(node.id, tagID: tag.id, undoManager: undoManager)
                        }label: {
                            Image(systemName: document.board.hasTag(node.id, tag.id) ? "checkmark.seal.fill" : "plus.circle").foregroundColor(.gray)
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 8)

                }



            }
            .padding(.bottom, 7)
            .padding(.top, 7)
            .frame(width:250)
            .background(Color.white)
        }
        .cornerRadius(6)
        .shadow(radius: 10)
    }

    private func addPreviewTag() {
        guard !textForTags.isEmpty else { return }
        if !document.board.allTags.contains(where: { $0.name == textForTags }) {
            let newTagForPreview = KPTag(id: UUID(), name: textForTags, colorTheme: KPTagColor.random())
            previewTag = newTagForPreview
        }
    }

    private func createTag() {
        guard let previewTag = previewTag else { return }

        document.createTag(textForTags, undoManager: undoManager)
        var tags = document.board.getTags(node.id).map { $0.id }
        guard let createdTag = document.board.getTag(textForTags)?.id else { return }
        tags.append(createdTag)

        document.updateNode(node.id, tags: tags, undoManager: undoManager)
        self.previewTag = nil
        self.textForTags = ""
    }
//
//    private func deleteTag(_ tag: KPTag) {
//        document.deleteTag(node.id, tagID: tag.id, undoManager: undoManager, animation: .default)
//    }
//
//    private func updateUniqueTags(with tag: KPTag) {
//        let existingTagNames = uniqueTags.map { $0.name }
//        if !existingTagNames.contains(tag.name) {
//            uniqueTags.append(tag)
//        }
//    }

}

#Preview {
    TagPopupView(isEditingForTag: .constant(false), node: .mockData)
        .environmentObject(KPBoardDocument())
}
