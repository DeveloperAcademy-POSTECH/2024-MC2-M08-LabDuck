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
    
    @State private var textViewHeight: CGFloat = 20
    
//    @Binding var backgroundColor: KPColorTheme
    
    @State private var textForTags: String = ""
    @State private var previewTag: TagView?
    @State private var tags: [TagView] = []
    
    @Binding var clickingOutput: Bool
    
    var judgeConnection: (_ outputID: KPOutputPoint.ID, _ dragLocation: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)?
    var addEdge: (_ edge: KPEdge) -> ()
    

    var updatePreviewEdge: (_ sourceID: KPOutputPoint.ID, _ dragPoint: CGPoint?) -> ()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(),spacing:7), count: 4)

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
                        HStack(spacing: 4){
                            Rectangle().foregroundColor(.pink).frame(width: 16, height: 16).cornerRadius(3)
                            Rectangle().foregroundColor(.pink).frame(width: 16, height: 16).cornerRadius(3)
                            Rectangle().foregroundColor(.pink).frame(width: 16, height: 16).cornerRadius(3)
                            Rectangle().foregroundColor(.pink).frame(width: 16, height: 16).cornerRadius(3)
                            Rectangle().foregroundColor(.pink).frame(width: 16, height: 16).cornerRadius(3)
                            Rectangle().foregroundColor(.pink).frame(width: 16, height: 16).cornerRadius(3)
                            Rectangle().foregroundColor(.pink).frame(width: 16, height: 16).cornerRadius(3)
                            Rectangle().foregroundColor(.pink).frame(width: 16, height: 16).cornerRadius(3)
                            Spacer()
                        }.frame(width: 200, height: 20)
                    }
                    
                    
                    
                    //제목
                    
                    if isEditing{
                            TextEditor(text: $node.unwrappedTitle)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.black)
                                .font(.system(size: 17, weight: .bold))
                                .frame(width:200)
                        
//                        TextEditor(text: $node.unwrappedTitle)
//                                        .frame(height: max(textViewHeight, 20)) // 최소 높이 설정
//                                        .background(GeometryReader { geometry -> Color in
//                                            DispatchQueue.main.async {
//                                                // 내용에 따라 높이 업데이트
//                                                let size = geometry.size
//                                                if size.height != self.textViewHeight {
//                                                    self.textViewHeight = size.height
//                                                }
//                                            }
//                                            return Color.clear
//                                        })
//                                        .frame(width: 200) // 고정 가로 길이 설정
//                                        .padding()
//                                        .border(Color.gray)
//                        
                    } else {
                        Text(node.unwrappedTitle)
                            .foregroundColor(.black)
                            .font(.system(size:17, weight: .bold))
                            .frame(width: 200,height: 40)
                    }
                    
                    
                    
                    //노트
                    
                    if isEditing{
                        
                        if isEditingForNote {
                            TextEditor(text: $node.unwrappedNote)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .border(Color.clear, width: 0)
                                .foregroundColor(.black)
                                .font(.system(size: 13))
                                .frame(width: 200)
                        }else{
                            Button{
                                isEditingForNote.toggle()
                            }label:{
                                HStack{
                                    Image(systemName: "note.text").foregroundColor(.gray)
                                    Text("노드 작성").foregroundColor(.gray)
                                    Spacer()
                                    
                                }.buttonStyle(BorderlessButtonStyle()).frame(width: 200)
                            }
                        }
                        
                    } else {
                        Text(node.unwrappedNote)
                            .foregroundColor(.black)
                            .font(.system(size: 13, weight: .regular))
                            .frame(width:200,height: 50)
                    }
                    
                    Divider().background(.gray)
                    
                    
                    //링크
                    
                    if isEditing{
                        if isEditingForLink {
                            TextEditor(text: $node.unwrappedURL)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .border(Color.clear, width: 0)
                                .foregroundColor(.blue)
                                .underline()
                                .font(.system(size: 13))
                                .frame(width: 200)
                        }else{
                            Button{
                                isEditingForLink.toggle()
                            }label:{
                                HStack{
                                    Image(systemName: "note.text").foregroundColor(.gray)
                                    Text("링크 추가").foregroundColor(.gray)
                                    Spacer()
                                    
                                }.buttonStyle(BorderlessButtonStyle()).frame(width: 200)
                            }
                        }
                        
                        
                    } else {
                        Group {
                            if let url = URL(string: node.unwrappedURL) {
                                Link(destination: url) {
                                    Text("\(node.unwrappedURL)")
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
                .background(.white)
                .frame(width: 250)
                
                
                //태그
                
                
                HStack{
                    
                    //태그 추가 버튼
                    //                        Button {
                    //                            node.tags.append(.mockData)
                    //                        } label: {
                    //                            Text("+")
                    //                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    //                                .background(Color.gray).opacity(0.8)
                    //                                .cornerRadius(10)
                    //                        }
                    //                                                .buttonStyle(BorderlessButtonStyle())
                    if isEditing{
//                        if isEditingForTag{
//                            TextEditor(text:$textForTags)
//                                .padding()
//                                .frame(height: 100)
//                                .border(Color.gray)
//                                .onChange(of: textForTags) { newText in
//                                    handleTextChange(newText)
//                                }
//                        }else{
                            
                            Button{
                                isEditingForTag.toggle()
                            }label:{
                                HStack{
                                    Image(systemName: "tag").foregroundColor(.gray)
                                    Text("태그 추가").foregroundColor(.gray)
                                }
                            }
                            Spacer()
//                        }
                    }else{
                        ForEach(node.tags){ tag in
                            Text("#\(tag.name)")
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .background(Color.blue)
                                .cornerRadius(10)
                            
                        }
                        Spacer()
                    }
                    
                }.padding(10)
                    .frame(width: 250, height: 50)
                    .background(.gray.opacity(0.3))
                
                
                
            }
            .background(.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.25), radius: 1.5, x: 0, y: 0)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
                
                
                //편집 버튼
                if isEditing{
                    Button{
                        isEditing.toggle()
                    }label:{
                        Image(systemName: "checkmark")
                            .foregroundColor(.gray)
                            .opacity(self.hovered ? 1.0 : 0.3)
                            .onHover { hover in
                                print("Mouse hover: \(hover)")
                                self.hovered = hover
                            }
                    }.buttonStyle(BorderlessButtonStyle()).offset(x:100,y:-100)
                }else{
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
                    }.buttonStyle(BorderlessButtonStyle()).offset(x:100,y:-100)
                }
                
                
                //태그 팝업창
                if isEditingForTag {
                    VStack (alignment:.leading){
                                   TextField("Enter text", text: $textForTags, onCommit: {
                                       addPreviewTag()
                                   }).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .padding()

                                   if let previewTag = previewTag {
                                       previewTag
                                           .padding(.top, 5)
                                       Button{
                                           createTag()
                                           
                                       }label: {
                                           Text("생성").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                       }
                                       .padding(.top, 5)
                                   }
                                   Divider().padding()

                                   VStack(alignment: .leading, spacing: 10) {
                                       ForEach(tags) { tag in
                                           tag
                                       }
                                   }
                                   .padding()
                               }
                               .frame(width:200)
                               .padding()
                               .background(Color.white)
                               .cornerRadius(10)
                               .shadow(radius: 10)
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
    
    private func addPreviewTag() {
        guard !textForTags.isEmpty else { return }
        let newTag = TagView(text: textForTags)
        previewTag = newTag
    }

    private func createTag() {
        guard let previewTag = previewTag else { return }
        tags.append(previewTag)
//        node.tags.append(previewTag)
        self.previewTag = nil
        self.textForTags = ""
    }


    // 텍스트 변경을 처리하는 함수
    private func handleTextChange(_ newText: String) {
        if newText.last == " " {
            let tag = newText.trimmingCharacters(in: .whitespaces)
            if !tag.isEmpty {
                node.tags.append(.mockData)
            }
            textForTags = ""
        }
    }
    

    
    private func judgeConnection(with location: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)? {
        if let currentOutputPoint {
            return self.judgeConnection(currentOutputPoint, location)
        } else {
            return nil
        }
    }
}


//#Preview {
//    NodeView(node: .constant(.mockData), clickingOutput: <#Binding<Bool>#>, isEditingForTitle: isEditingForTitle, judgeConnection: { _, _ in (UUID(), UUID()) }, addEdge: { _ in }, updatePreviewEdge: { _, _ in })
//}
