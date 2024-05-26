//
//  NodeView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI
import Combine

struct NodeView: View {
    @EnvironmentObject var document: KPBoardDocument
    @Environment(\.undoManager) var undoManager

    var node: KPNode
    @State private var tempNodeTitle: String = ""
    @State private var tempNodeNote: String = ""
    @State private var tempNodeURL: String = ""

    @State private var dragLocation: CGPoint?
    @State private var currentOutputPoint: KPOutputPoint.ID?
    @State private var isEditingForTitle: Bool = false
    @State private var isEditingForNote: Bool = false
    @State private var isEditingForLink: Bool = false
    @State private var isEditingForTag: Bool = false
    @State private var isEditing: Bool = false
    @State private var hovered: Bool = false
    @State private var trashcanHovered: Bool = false
    @State private var hoveredForClosingTagView: Bool = false

    @State private var textForTags: String = ""
    @State private var previewTag: KPTag?

    @Binding var clickingOutput: Bool
    @Environment(\.searchText) private var searchText
    
    
    @State private var selectedAction = "normal"

    var judgeConnection: (_ outputID: KPOutputPoint.ID, _ dragLocation: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)?
    
    var updatePreviewEdge: (_ sourceID: KPOutputPoint.ID, _ dragPoint: CGPoint?) -> ()

    var body: some View {
        HStack {
            InputPointsView()

            ZStack {
                VStack(spacing: 0) {
                    VStack(alignment: .center, spacing: 10) {
                        if isEditing {
                            SelectColorView()
                        }
                        TitleTextField()
                        NoteTextEditor()

                        Divider().background(.gray)
                        
                        LinkTextField()
                    }
                    .padding(20)
                    .background(node.colorTheme.backgroundColor)

                    TagsView()
                        .background(.white)
                }
                .cornerRadius(10)

                .opacity((searchText == "" || nodeContainsSearchText()) ? 1 : 0.3)
                //태그 팝업창
//                if isEditingForTag {
//                    TagPopupView(isEditingForTag: $isEditingForTag, node: $node)
//                        .transition(.scale)
//                        .zIndex(1)
//                }
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 8) {
                    Spacer()
                    Picker("", selection: $selectedAction) {
                        Button {
                            selectedAction = "Edit"
                        } label: {
                            Label("Edit", systemImage: isEditing ? "checkmark" : "square.and.pencil")
                                .labelStyle(.iconOnly)
                                .frame(width: 15, height: 15)
                        }
                        .tag("Edit")
                        
                        Button {
                            selectedAction = "Delete"
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .labelStyle(.iconOnly)
                                .frame(width: 15, height: 15)
                        }
                        .tag("Delete")
                    }

                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedAction) { newValue in
                        switch newValue {
                        case "Edit":
                            print("edit버튼")
                            isEditing.toggle()
                            selectedAction = "normal"
                            break
                        case "Delete":
                            print("delete버튼")
                            document.removeNode(node.id, undoManager: undoManager, animation: .default)
                            break
                        default:
                            break
                        }
                    }
//                    .foregroundColor(.gray)
                    .frame(width: 100)
                    .scaleEffect(0.6)
                    .background(.white.opacity(self.hovered ? 0.1 : 0.0))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                }
            }
            .frame(minWidth: 50, maxWidth: node.size.width, minHeight: 50, maxHeight: .infinity)
            .shadow(color: .black.opacity(0.25), radius: 1.5, x: 0, y: 0)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)

            OutputPointsView()
        }
        .onChange(of: isEditing) { oldValue, newValue in
            if oldValue && !newValue {
                var newNode = node
                newNode.title = tempNodeTitle
                newNode.note = tempNodeNote
                newNode.url = tempNodeURL
                document.updateNode(node: newNode, undoManager: undoManager)
            }
        }
        .onChange(of: self.tempNodeTitle) { _, newValue in
            if abs(self.node.unwrappedTitle.count - newValue.count) > 2 {
                document.updateNode(node.id, title: newValue, undoManager: undoManager)
            }
        }
        .onChange(of: self.tempNodeNote) { oldValue, newValue in
            if abs(self.node.unwrappedNote.count - newValue.count) > 2 {
                document.updateNode(node.id, note: newValue, undoManager: undoManager)
            }
        }
        .onChange(of: self.tempNodeURL) { oldValue, newValue in
            if abs(self.node.unwrappedURL.count - newValue.count) > 2 {
                document.updateNode(node.id, url: newValue, undoManager: undoManager)
            }
        }
    }
    
    //입력한 텍스트(textForTags)가 nil이 아닐 경우 프리뷰로 값 저장함.
    private func addPreviewTag() {
        guard !textForTags.isEmpty else { return }
        let newTagForPreview = KPTag(id: UUID(), name: textForTags, colorTheme: KPTagColor.blue)
        previewTag = newTagForPreview
    }
    
    //KPNode에 새 태그 정보 추가
//    private func createTag() {
//        guard let previewTag = previewTag else { return }
//        node.tags.append(previewTag)
//        self.previewTag = nil
//        self.textForTags = ""
//    }
    
    private func judgeConnection(with location: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)? {
        if let currentOutputPoint {
            return self.judgeConnection(currentOutputPoint, location)
        } else {
            return nil
        }
    }
    
    // MARK: - search&higlight
    func HighlightText(fullText: String, searchText: String) -> Text {
        guard !searchText.isEmpty else {
            return Text(fullText)
        }
        
        let lowercasedFullText = fullText.lowercased()
        let lowercasedSearchText = searchText.lowercased()
        
        let parts = lowercasedFullText.components(separatedBy: lowercasedSearchText)
        
        var result = Text("")
        
        var lastIndex = fullText.startIndex
        
        for (index, part) in parts.enumerated() {
            if index > 0 {
                if let range = fullText.range(of: searchText, options: .caseInsensitive, range: lastIndex..<fullText.endIndex) {
                    result = result + Text(fullText[range]).bold().foregroundColor(.red)
                    lastIndex = range.upperBound
                }
            }
            if let range = lowercasedFullText.range(of: part, range: lastIndex..<lowercasedFullText.endIndex) {
                result = result + Text(fullText[range])
                lastIndex = range.upperBound
            }
        }
        
        return result
    }
    
    // MARK: - 노드의 상태 관리
    private func nodeContainsSearchText() -> Bool {
        let lowercasedSearchText = searchText.lowercased()
        let titleContains = node.unwrappedTitle.lowercased().contains(lowercasedSearchText)
        let noteContains = node.unwrappedNote.lowercased().contains(lowercasedSearchText)
        let urlContains = node.unwrappedURL.lowercased().contains(lowercasedSearchText)
        let tagsContain = node.tags.contains { ("#" + $0.name).lowercased().contains(lowercasedSearchText) }
        
        return titleContains || noteContains || urlContains || tagsContain
    }
}

// MARK: - Components
extension NodeView {
    @ViewBuilder
    private func SelectColorView() -> some View {
        HStack(spacing: 6) {
            ForEach(KPColorTheme.allCases, id: \.self) { colorTheme in
                Button {
                    document.updateNode(node.id, colorTheme: colorTheme, undoManager: undoManager)
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.blue.opacity(node.colorTheme == colorTheme ? 1 : 0))
                }
                .background(colorTheme.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .buttonStyle(.borderless)
            }
            Spacer()
        }
        .background(Color.clear)
    }

    private func TitleTextField() -> some View {
        @ViewBuilder var TextView: some View {
            if !isEditing {
                HighlightText(fullText: node.unwrappedTitle, searchText: searchText)
            } else {
                TextField("title", text: $tempNodeTitle, axis: .vertical)
                    .onAppear {
                        tempNodeTitle = self.node.unwrappedTitle
                    }
            }
        }
        return TextView
            .foregroundColor(.black)
            .font(.title)
            .bold()
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
    }

    private func NoteTextEditor() -> some View {
        @ViewBuilder var TextView: some View {
            if !isEditing {
                HighlightText(fullText: node.unwrappedNote, searchText: searchText)
            } else {
                TextField("note", text: $tempNodeNote, axis: .vertical)
                    .onAppear {
                        tempNodeNote = self.node.unwrappedNote
                    }
            }
        }
        @ViewBuilder var ResultView: some View {
            if isEditingForNote || !node.unwrappedNote.isEmpty {
                TextView
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
            } else {
                Button {
                    isEditingForNote.toggle()
                } label: {
                    HStack {
                        Image(systemName: "note.text").foregroundColor(.gray)
                        Text("노트 작성").foregroundColor(.gray)
                        Spacer()
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        return ResultView
    }

    private func LinkTextField() -> some View {
        @ViewBuilder var TextView: some View {
            if !isEditing {
                if let url = URL(string: node.unwrappedURL) {
                    Link(destination: url) {
                        HighlightText(fullText: node.unwrappedURL, searchText: searchText)
                            .foregroundColor(.blue)
                            .underline()
                            .font(.system(size: 13, weight: .regular))
                    }
                }
            } else {
                TextField("link", text: $tempNodeURL, axis: .vertical)
                    .onAppear {
                        tempNodeURL = self.node.unwrappedURL
                    }
            }
        }
        @ViewBuilder var ResultView: some View {
            if isEditingForLink||(node.unwrappedURL.isEmpty == false) {
                TextView
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.blue)
                    .underline()
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
            } else {
                Button{
                    isEditingForLink.toggle()
                }label:{
                    HStack{
                        Image(systemName: "note.text").foregroundColor(.gray)
                        Text("링크 추가").foregroundColor(.gray)
                        Spacer()

                    }
                    .buttonStyle(.borderless)
                }
                .buttonStyle(.borderless)
            }
        }
        return ResultView
    }

    @ViewBuilder
    private func TagsView() -> some View {
        //태그

        if isEditing {
            HStack{
                Button {
                    isEditingForTag.toggle()
                } label: {
                    HStack{
                        Image(systemName: "tag").foregroundColor(.gray)
                        Text("태그 추가").foregroundColor(.gray)
                    }
                }
                ScrollView(.horizontal) {
                    HStack{
                        ForEach(node.tags) { tag in
                            HighlightText(fullText: "#\(tag.name)", searchText: searchText)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .cornerRadius(10)

                        }
                        Spacer()
                    }
                }
            }
            .padding(10)
            .background(.gray.opacity(0.3))
        } else {
            ScrollView(.horizontal){
                HStack{
                    ForEach(node.tags){ tag in
                        HighlightText(fullText: "#\(tag.name)", searchText: searchText)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            .background(Color.blue)
                            .cornerRadius(10)

                    }
                    Spacer()
                }
            }
            .scrollDisabled(true)
            .padding(10)
            .background(.gray.opacity(0.3))
        }
    }

    @ViewBuilder
    private func InputPointsView() -> some View {
        //인풋 포인트
        VStack(spacing: 20){
            ForEach(node.inputPoints) { inputPoint in
                InputPointView(inputPoint: inputPoint).opacity(inputPoint.isLinked ? 1.0 : (clickingOutput ? 0.2 : 0.0))
            }
        }
    }

    @ViewBuilder
    private func OutputPointsView() -> some View {
        VStack(spacing: 20){
            ForEach(node.outputPoints) { outputPoint in
                OutputPointView(outputPoint: outputPoint)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragLocation = value.location
                                currentOutputPoint = outputPoint.id
                                updatePreviewEdge(outputPoint.id, dragLocation)

                                clickingOutput = true
                            }
                            .onEnded { value in
                                if let dragLocation {
                                    if let (outputID, inputID) = self.judgeConnection(with: dragLocation) {
                                        self.document.addEdge(edge: KPEdge(sourceID: outputID, sinkID: inputID), undoManager: undoManager)

                                    }
                                }
                                clickingOutput = false
                                dragLocation = nil
                                updatePreviewEdge(outputPoint.id, dragLocation)

                            }
                    )
            }
        }
    }
}

extension NodeView: Equatable {
    static func == (lhs: NodeView, rhs: NodeView) -> Bool {
        lhs.node == rhs.node
    }
}

#Preview {
    NodeView(node: .mockData2, clickingOutput: .constant(false), judgeConnection: { _, _ in (UUID(), UUID()) }, updatePreviewEdge: { _, _ in })
}
