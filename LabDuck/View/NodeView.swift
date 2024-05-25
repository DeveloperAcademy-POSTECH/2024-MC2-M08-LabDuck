//
//  NodeView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct NodeView: View {
    @Binding var node: KPNode
    //    @Binding var inputPoints: KPInputPoint
    @State private var dragLocation: CGPoint?
    @State private var currentOutputPoint: KPOutputPoint.ID?
    @State private var isEditingForTitle: Bool = false
    @State private var isEditingForNote: Bool = false
    @State private var isEditingForLink: Bool = false
    @State private var isEditingForTag: Bool = false
    @State private var isEditing: Bool = false
    @State private var hovered: Bool = false
    @State private var hoveredForClosingTagView: Bool = false
    
    @State private var isScrollDisabled: Bool = false
    
    @State private var textViewHeight: CGFloat = 20
    
    //    @Binding var backgroundColor: KPColorTheme
    //------
    @State private var textForTags: String = ""
    @State private var previewTag: KPTag?
    @State private var tags: [KPTag] = []
    //------
    @Binding var clickingOutput: Bool
    @Environment(\.searchText) private var searchText
    
    var judgeConnection: (_ outputID: KPOutputPoint.ID, _ dragLocation: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)?
    var addEdge: (_ edge: KPEdge) -> ()
    
    
    var updatePreviewEdge: (_ sourceID: KPOutputPoint.ID, _ dragPoint: CGPoint?) -> ()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(),spacing:7), count: 4)
    
    @State private var selectedButtonIndex: Int? = nil
    
    var body: some View {
        HStack {
            
            //인풋 포인트 관리
            
            VStack(spacing: 20){
                ForEach(node.inputPoints) { inputPoint in
                    
                    InputPointView(inputPoint: inputPoint).opacity(inputPoint.isLinked ? 1.0 : (clickingOutput ? 0.2 : 0.0))
                }
            }
            ZStack{
                VStack(spacing: 0){
                    VStack(alignment: .leading, spacing: 10) {
                        //컬러 고르기
                        if isEditing{
                            HStack(spacing:6) {
                                ForEach(KPColorTheme.allCases, id: \.self) { colorTheme in
                                    Button(action: {
                                        node.colorTheme = colorTheme
                                        //                                        selectedButtonIndex = index
                                    }) {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(colorTheme.backgroundColor)
                                                .strokeBorder(.blue.opacity(node.colorTheme == colorTheme ? 1 : 0), lineWidth: 1)
                                                .frame(width: 16, height: 16)
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .resizable()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/.opacity(node.colorTheme == colorTheme ? 1 : 0))
                                            
                                        }
                                    }.buttonStyle(BorderlessButtonStyle())
                                }
                                Spacer()
                                Button{
                                    isEditing.toggle()
                                }label:{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(.gray.opacity(self.hovered ? 0.1: 0.0))
                                            .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
                                            .frame(width: 22, height:22)
                                        
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.gray)
                                            .onHover { hover in
                                                print("Mouse hover: \(hover)")
                                                self.hovered = hover
                                            }
                                    }
                                }.buttonStyle(BorderlessButtonStyle())
                                
                            }
                            .frame(width: 200, height: 20)
                            .background(Color.clear)
                        }
                        //제목
                        if isEditing{
                            TextEditor(text: $node.unwrappedTitle)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.black)
                                .font(.system(size: 17, weight: .bold))
                                .frame(width:200, height: 50)
                        } else {
                            ZStack{
                                HighlightText(fullText: node.unwrappedTitle, searchText: searchText)
                                    .foregroundColor(.black)
                                    .font(.system(size:17, weight: .bold))
                                    .frame(width: 200,height: 40)
                                
                                Button{
                                    isEditing.toggle()
                                }label:{
                                    Image(systemName: "square.and.pencil")
                                        .foregroundColor(.gray)
                                        .opacity(self.hovered ? 1.0 : 0.3)
                                        .onHover { hover in
                                            print("Mouse hover: \(hover)")
                                            self.hovered = hover
                                        }
                                }.buttonStyle(BorderlessButtonStyle()).offset(x:100, y:-20)
                            }
                        }
                        //노트
                        if isEditing{
                            if isEditingForNote||(node.unwrappedNote.isEmpty == false) {
                                
                                TextEditor(text: $node.unwrappedNote)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .border(Color.clear, width: 0)
                                    .foregroundColor(.black)
                                    .font(.system(size: 13))
                                    .frame(width: 200, height: 70)
                            }else{
                                Button{
                                    isEditingForNote.toggle()
                                }label:{
                                    HStack{
                                        Image(systemName: "note.text").foregroundColor(.gray)
                                        Text("노드 작성").foregroundColor(.gray)
                                        Spacer()
                                        
                                    }.buttonStyle(BorderlessButtonStyle()).frame(width: 200)
                                }.buttonStyle(BorderlessButtonStyle())
                            }
                        } else {
                            HighlightText(fullText: node.unwrappedNote, searchText: searchText)
                                .foregroundColor(.black)
                                .font(.system(size: 13, weight: .regular))
                                .frame(width:200,height: 50)
                        }
                        Divider().background(.gray)
                        
                        //링크
                        if isEditing{
                            if isEditingForLink||(node.unwrappedURL.isEmpty == false) {
                                TextEditor(text: $node.unwrappedURL)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .border(Color.clear, width: 0)
                                    .foregroundColor(.blue)
                                    .underline()
                                    .font(.system(size: 13))
                                    .frame(width: 200, height: 30)
                            }else{
                                Button{
                                    isEditingForLink.toggle()
                                }label:{
                                    HStack{
                                        Image(systemName: "note.text").foregroundColor(.gray)
                                        Text("링크 추가").foregroundColor(.gray)
                                        Spacer()
                                        
                                    }.buttonStyle(BorderlessButtonStyle()).frame(width: 200)
                                }.buttonStyle(BorderlessButtonStyle())
                            }
                                         
                        } else {
                            Group {
                                if let url = URL(string: node.unwrappedURL) {
                                    Link(destination: url) {
                                        HighlightText(fullText: node.unwrappedURL, searchText: searchText)
                                            .foregroundColor(.blue)
                                            .underline()
                                            .font(.system(size: 13, weight: .regular))
                                    }
                                }
                            }
                            .frame(width: 200, height: 20)
                        }
                    }
                    .padding(20)
                    .background(node.colorTheme.backgroundColor)
                    .frame(width: 250)
                    
                    //태그
                    if isEditing{
                        HStack{
                            Button{
                                isEditingForTag.toggle()
                            }label:{
                                
                                HStack{
                                    Image(systemName: "tag").foregroundColor(.gray)
                                    Text("태그 추가").foregroundColor(.gray)
                                }
                            }
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
                        }.padding(10)
                            .frame(width: 250, height: 50)
                            .background(.gray.opacity(0.3))
                    }else{
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
                        }.scrollDisabled(true)
                            .padding(10)
                            .frame(width: 250, height: 50)
                            .background(.gray.opacity(0.3))
                        
                    }
                }
                .background(.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.25), radius: 1.5, x: 0, y: 0)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
                .opacity((searchText == "" || nodeContainsSearchText()) ? 1 : 0.3)
                
                
                //태그 팝업창
                if isEditingForTag {
                    TagPopupView(isEditingForTag: $isEditingForTag, node: $node)
                        .transition(.scale)
                        .zIndex(1)
                }
            }
            
            //아웃풋 포인트
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

extension NodeView: Equatable {
    static func == (lhs: NodeView, rhs: NodeView) -> Bool {
        lhs.node == rhs.node
    }
}

#Preview {
    NodeView(node: .constant(.mockData), clickingOutput: .constant(false), judgeConnection: { _, _ in (UUID(), UUID()) }, addEdge: { _ in }, updatePreviewEdge: { _, _ in })
}
