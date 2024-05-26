import SwiftUI

struct EditSheetView: View {
    @Binding var node: KPNode
    @Binding var board: KPBoard
    @Binding var isSheet: Bool
    @Binding var selection: Set<KPNode.ID>
    @State private var relatedNodes: [KPNode] = []
    @State private var isEditingForTag: Bool = false
    let findNodes: (KPNode) -> [KPNode]
//    @Binding var uniqueTags: [KPTag]
    
    var body: some View {
        VStack {
            headerView
            
            ScrollView {
                VStack(alignment: .leading) {
                    titleSection
                    noteSection
                    if !relatedNodes.isEmpty {
                        relatedInfoSection
                    }
                    tagsAndUrlSections
                    Spacer()
                }
            }
        }
        .padding(32)
        .background(node.colorTheme.backgroundColor)
        .onAppear {
            relatedNodes = findNodes(node)
        }
        .onChange(of: node.id) { _, _ in
            relatedNodes = findNodes(node)
        }
        
        colorSelectionView
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            
            Button(action: {
                //삭제 기능을 추가해요
            }) {
                Image(systemName: "trash")
                    .frame(width: 20, height: 20)
            }
            
            Button(action: {
                isSheet = false
            }) {
                Image(systemName: "xmark")
                    .frame(width: 20, height: 20)
            }
        }
        .padding(4)
        .background(node.colorTheme.backgroundColor)
    }
    
    private var titleSection: some View {
        Section(header: sectionHeader("Title")) {
            styledTextEditor(
                text: $node.unwrappedTitle,
                lineLimit: 3,
                fontSize: 15,
                height: 84
            )
        }
    }
    
    private var noteSection: some View {
        Section(header: sectionHeader("Note")) {
            styledTextEditor(
                text: $node.unwrappedNote,
                lineLimit: 10,
                fontSize: 13,
                height: 100
            )
        }
    }
    
    private var relatedInfoSection: some View {
        Section(header: sectionHeader("Related Informations")) {
            VStack {
                ForEach(relatedNodes) { relatedNode in
                    relatedNodeButton(relatedNode)
                }
            }
        }
    }
    
    private var tagsAndUrlSections: some View {
        ZStack {
            VStack(alignment: .leading) {
                tagsSection
                urlSection
                Spacer()
            }
            if isEditingForTag {
                TagPopupView(isEditingForTag: $isEditingForTag, node: $node)
                    .transition(.slide)
                    .zIndex(1)
            }
        }
    }
    
    private var tagsSection: some View {
        Section(header: sectionHeader("Tags")) {
            ZStack {
                if node.tags.isEmpty {
                    addTagButton
                } else {
                    tagsScrollView
                }
            }
        }
    }
    
    private var urlSection: some View {
        Section(header: sectionHeader("URL")) {
            styledTextEditor(
                text: $node.unwrappedURL,
                lineLimit: 2,
                fontSize: 13,
                height: 40
            )
        }
    }
    
    private var addTagButton: some View {
        Button(action: {
            isEditingForTag.toggle()
        }) {
            HStack {
                Image(systemName: "tag")
                    .frame(width: 16, height: 16)
                Text("태그 추가")
                    .font(Font.custom("SF Pro", size: 13))
                    .foregroundColor(Color(hex: 0x808080))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(6)
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.black.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var tagsScrollView: some View {
        HStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(node.tags, id: \.id) { tag in
                        Button(action: {
                            isEditingForTag.toggle()
                        }) {
                            HStack {
                                Text("#\(tag.name)")
                                    .font(
                                        Font.custom("SF Pro", size: 13)
                                            .weight(.semibold)
                                    )
                                    .foregroundColor(.white)
                            }
                            .padding(6)
                            .background(tag.colorTheme.backgroundColor)
                            .cornerRadius(6)
                            .frame(height: 40)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 40)
        .background(Color.white)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.black.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var colorSelectionView: some View {
        HStack(alignment: .center) {
            ForEach(KPColorTheme.allCases, id: \.self) { colorTheme in
                Button(action: {
                    node.colorTheme = colorTheme
                }) {
                    ZStack {
                        Rectangle()
                            .fill(colorTheme.backgroundColor)
                            .frame(width: 16, height: 16)
                            .cornerRadius(3)
                            .padding(3)
                        if colorTheme == .default {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(.black.opacity(0.1), lineWidth: 1)
                                .frame(width: 16, height: 16)
                                .padding(3)
                        }
                        if colorTheme == node.colorTheme {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(.blue, lineWidth: 1)
                                .frame(width: 16, height: 16)
                                .padding(3)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.blue)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            Spacer()
        }
        .padding(32)
        .frame(height: 86)
        .background(Color.white)
    }
    
    private func styledTextEditor(text: Binding<String>, lineLimit: Int, fontSize: CGFloat, height: CGFloat) -> some View {
        TextEditor(text: text)
            .lineLimit(lineLimit)
            .scrollContentBackground(.hidden)
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(6)
            .font(Font.custom("SF Pro", size: fontSize))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
    }
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(Font.custom("SF Pro", size: 13))
            .foregroundStyle(.secondary)
            .padding(.top, 16)
    }
    
    private func relatedNodeButton(_ relatedNode: KPNode) -> some View {
        Button(action: {
            selection.removeAll()
            selection.insert(relatedNode.id)
        }) {
            HStack {
                ZStack {
                    Rectangle()
                        .cornerRadius(3)
                        .frame(width: 14, height: 14)
                        .foregroundColor(relatedNode.colorTheme.backgroundColor)
                    if relatedNode.colorTheme == KPColorTheme.default {
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(.black.opacity(0.1), lineWidth: 1)
                            .frame(width: 14, height: 14)
                    }
                }
                Text(relatedNode.unwrappedTitle)
                    .foregroundColor(.black.opacity(0.85))
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: 0xFBFBFB))
            .cornerRadius(6)
            .frame(height: 40)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
