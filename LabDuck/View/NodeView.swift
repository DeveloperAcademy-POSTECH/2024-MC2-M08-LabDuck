//
//  NodeView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct NodeView: View {
    @Binding var board: KPBoard
    @Binding var node: KPNode
//    @Binding var inputPoints: KPInputPoint
    @State private var dragLocation: CGPoint?
    @State private var currentOutputPoint: KPOutputPoint.ID?
    @State private var isEditingForNote: Bool = false
    @State private var isEditingForLink: Bool = false
    
    @State private var textForTags: String = ""
//    @State private var tags: [String] = []
    
    @Binding var clickingOutput: Bool
  
    @Binding var isEditingForTitle: Bool
    
    var inputPointLinking: (KPNode)
    
    var judgeConnection: (_ outputID: KPOutputPoint.ID, _ dragLocation: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)?
    var addEdge: (_ edge: KPEdge) -> ()
    

    var updatePreviewEdge: (_ sourceID: KPOutputPoint.ID, _ dragPoint: CGPoint?) -> ()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(),spacing:7), count: 4)

    var body: some View {
        HStack {
            VStack(spacing: 20){
                ForEach(node.inputPoints) { inputPoint in
                    
                    InputPointView(inputPoint: inputPoint).opacity(clickingOutput ? 1.0 : (inputPoint.isLinked ? 1.0: 0.2))
                }
            }
            VStack(spacing: 0){
                VStack(alignment: .leading, spacing: 10) {
                    //제목
                     if isEditingForTitle {
                        TextEditor(text: $node.unwrappedTitle)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(.black)
                            .font(.system(size: 17, weight: .bold))
                            .frame(width:200,height: 40)
                           
                            
                    } else {
                            Text(node.unwrappedTitle)
                                .foregroundColor(.black)
                                .font(.system(size: 17, weight: .bold))
                                .frame(width:200,height: 40)
                                .onTapGesture {
                                    isEditingForTitle.toggle()
                                }
                        
                        

                    
                    }

                    //노트
                    if isEditingForNote {
                        TextEditor(text: $node.unwrappedNote)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .border(Color.clear, width: 0)
                            .foregroundColor(.black)
                            .font(.system(size: 13))
                            .frame(width: 200, height: 50)
                    } else {
                        Text(node.unwrappedNote)
                            .foregroundColor(.black)
                            .font(.system(size: 13, weight: .regular))
                            .frame(width:200,height: 50)
                    }

                    Divider().background(.gray)

                    if isEditingForLink {
                        TextEditor(text: $node.unwrappedURL)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .border(Color.clear, width: 0)
                            .foregroundColor(.blue)
                            .underline()
                            .font(.system(size: 13))
                            .frame(width: 200, height: 20)

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
                .frame(width: 250, height: 180)

                ScrollView(.horizontal) {
                HStack{
                        
                            ForEach(node.tags){ tag in
                                Text("#\(tag.name)")
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        
                        //태그 추가 버튼
//                        Button {
//                            node.tags.append(.mockData)
//                        } label: {
//                            Text("+")
//                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
//                                .background(Color.gray).opacity(0.8)
//                                .cornerRadius(10)
//                        }
//                        .buttonStyle(BorderlessButtonStyle())
                    TextEditor(text:$textForTags) 
                        .padding()
                        .frame(height: 100)
                        .border(Color.gray)
                        .onChange(of: textForTags) { newText in
                            handleTextChange(newText)
                        }
                }
//                .padding(10)
//                    .frame(width: 250)
//                    .background(.gray.opacity(0.3))

                }
                .padding(10)
                .background(.gray.opacity(0.3))
                .frame(width: 250, height: 50)

            }
            .background(.white)
            .cornerRadius(5)
            .shadow(color: .black.opacity(0.25), radius: 1.5, x: 0, y: 0)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
            
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
//                                                inputPoint.isLinked = true
                                            
                                            
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

    
    private func inputPointLinking(matching node: KPNode){
        let sourceIDs = node.outputPoints.map{ $0.id }
        
        let matchingSinkIDs = board.edges.filter{sourceIDs.contains($0.sourceID)}.map { $0.sinkID }
        
        var linkedInputpoint = KPInputPoint(isLinked: false)
        
        board.nodes.forEach { node in
            node.inputPoints.forEach { inputPoint in
                if matchingSinkIDs.contains(inputPoint.id) {
                    linkedInputpoint.isLinked = true
                }
            }
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
//    NodeView(node: .constant(.mockData), isEditingForTitle: isEditingForTitle, judgeConnection: { _, _ in (UUID(), UUID()) }, addEdge: { _ in }, updatePreviewEdge: { _, _ in })
//}
