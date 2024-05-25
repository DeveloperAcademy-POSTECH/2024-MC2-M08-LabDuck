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

    @Binding var node: KPNode
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
    @State private var hoveredForClosingTagView: Bool = false

    @State private var textForTags: String = ""
    @State private var previewTag: KPTag?

    @Binding var clickingOutput: Bool
    
    var judgeConnection: (_ outputID: KPOutputPoint.ID, _ dragLocation: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)?
    var addEdge: (_ edge: KPEdge) -> ()
    
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

                //태그 팝업창
                if isEditingForTag {
                    TagPopupView(isEditingForTag: $isEditingForTag, node: $node)
                        .transition(.scale)
                        .zIndex(1)
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    isEditing.toggle()
                } label: {
                    Image(systemName: isEditing ? "checkmark" : "square.and.pencil")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.gray)
                .background(.gray.opacity(self.hovered ? 0.1 : 0.0))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onHover { hover in
                    self.hovered = hover
                }
            }
            .frame(minWidth: 50, maxWidth: node.size.width, minHeight: 50, maxHeight: .infinity)
            .shadow(color: .black.opacity(0.25), radius: 1.5, x: 0, y: 0)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)

            OutputPointsView()
        }
        .onChange(of: isEditing) { oldValue, newValue in
            if oldValue && !newValue {
                self.node.title = tempNodeTitle
                self.node.note = tempNodeNote
                self.node.url = tempNodeURL
                document.updateNode(node: self.node, undoManager: undoManager)
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
    private func createTag() {
        guard let previewTag = previewTag else { return }
        node.tags.append(previewTag)
        self.previewTag = nil
        self.textForTags = ""
    }
    
    private func judgeConnection(with location: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)? {
        if let currentOutputPoint {
            return self.judgeConnection(currentOutputPoint, location)
        } else {
            return nil
        }
    }
}

// MARK: - Components
extension NodeView {
    @ViewBuilder
    private func SelectColorView() -> some View {
        HStack(spacing: 6) {
            ForEach(KPColorTheme.allCases, id: \.self) { colorTheme in
                Button {
                    document.updateNode(node.id, colorTheme: colorTheme)
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
                Text(node.unwrappedTitle)
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
                Text(node.unwrappedNote)
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
                        Text("\(node.unwrappedURL)")
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
                    .buttonStyle(BorderlessButtonStyle())
                }
                .buttonStyle(BorderlessButtonStyle())
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
                            Text("#\(tag.name)")
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
                        Text("#\(tag.name)")
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
                                        addEdge(KPEdge(sourceID: outputID, sinkID: inputID))


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
    NodeView(node: .constant(.mockData2), clickingOutput: .constant(false), judgeConnection: { _, _ in (UUID(), UUID()) }, addEdge: { _ in }, updatePreviewEdge: { _, _ in })
}
