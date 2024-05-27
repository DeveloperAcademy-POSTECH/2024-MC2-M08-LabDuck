import SwiftUI

struct EditSheetView: View {
    @EnvironmentObject var document: KPBoardDocument
    @Environment(\.undoManager) var undoManager
    var node: KPNode
    @Binding var isSheet: Bool
    @Binding var selection: Set<KPNode.ID>
    @State private var relatedNodes: [KPNode] = []
    @State private var isEditingForTag: Bool = false
    let findNodes: (KPNode) -> [KPNode]

    @State private var tempNodeTitle: String = ""
    @State private var tempNodeNote: String = ""
    @State private var tempNodeURL: String = ""

    @State private var showAlert: Bool = false

    @State private var totalHeight: CGFloat = .zero
    @State private var isHovered = false

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
            tempNodeTitle = self.node.unwrappedTitle
            tempNodeNote = self.node.unwrappedNote
            tempNodeURL = self.tempNodeURL
        }
        
        colorSelectionView
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            
            Button(action: {
                //print("테이블")
                showAlert = true
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
        .confirmationDialog("정말 삭제하시겠습니까?", isPresented: $showAlert, titleVisibility: .visible) {
                       Button("네", role: .none)
                       {   print("yes")
                           document.removeNode(node.id, undoManager: undoManager, animation: .default)
                       }
                       Button("아니오", role: .cancel){}
                   }.dialogSeverity(.critical)
    }
    
    private var titleSection: some View {
        Section(header: sectionHeader("Title")) {
            styledTextEditor(
                text: $tempNodeTitle,
                lineLimit: 3,
                fontSize: 15,
                height: 84
            )
            .onAppear {
                tempNodeTitle = node.unwrappedTitle
            }
            .onChange(of: tempNodeTitle) { _, newValue in
                document.updateNode(node.id, title: newValue, undoManager: undoManager)
            }
        }
    }
    
    private var noteSection: some View {
        Section(header: sectionHeader("Note")) {
            styledTextEditor(
                text: $tempNodeNote,
                lineLimit: 10,
                fontSize: 13,
                height: 100
            )
            .onAppear {
                tempNodeNote = node.unwrappedNote
            }
            .onChange(of: tempNodeNote) { _, newValue in
                document.updateNode(node.id, note: newValue, undoManager: undoManager)
            }
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
                TagPopupView(isEditingForTag: $isEditingForTag, node: node)
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
                    TagsView(totalHeight: $totalHeight, isEditingForTag: $isEditingForTag, tagIDs: node.tags)
                        .frame(height: totalHeight)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                        .environmentObject(document)
                        .onTapGesture {
                            isEditingForTag.toggle()
                        }
                }
            }
        }
    }
    
    private var urlSection: some View {
        Section(header: sectionHeader("URL")) {
            styledTextEditor(
                text: $tempNodeURL,
                lineLimit: 2,
                fontSize: 13,
                height: 40
            )
            .onAppear {
                tempNodeURL = node.unwrappedURL
            }
            .onChange(of: tempNodeURL) { _, newValue in
                document.updateNode(node.id, url: newValue, undoManager: undoManager)
            }
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

    private var colorSelectionView: some View {
        HStack(alignment: .center) {
            ForEach(KPColorTheme.allCases, id: \.self) { colorTheme in
                Button(action: {
                    document.updateNode(node.id, colorTheme: colorTheme, undoManager: undoManager)
                }) {
                    ZStack {
                        Rectangle()
                            .fill(colorTheme.backgroundColor)
                            .frame(width: 16, height: 16)
                            .cornerRadius(3)
                            .padding(3)
                        if colorTheme == .default {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(.black.opacity(0.2), lineWidth: 1)
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
            .autocorrectionDisabled()
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(6)
            .font(Font.custom("SF Pro", size: fontSize))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
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
            .background(isHovered ? Color(hex: 0xE0E0E0) : Color(hex: 0xFBFBFB))
            .cornerRadius(6)
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.black.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(BorderlessButtonStyle())
        .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension EditSheetView: Equatable {
    static func == (lhs: EditSheetView, rhs: EditSheetView) -> Bool {
        lhs.node == rhs.node
    }
}
