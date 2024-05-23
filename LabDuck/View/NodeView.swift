//
//  NodeView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct NodeView: View {
    @Binding var node: KPNode
    @State private var dragLocation: CGPoint?
    @State private var currentOutputPoint: KPOutputPoint.ID?
    @State private var isEditing: Bool = false
    var judgeConnection: (_ outputID: KPOutputPoint.ID, _ dragLocation: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)?
    var addEdge: (_ edge: KPEdge) -> ()
    var updatePreviewEdge: (_ sourceID: KPOutputPoint.ID, _ dragPoint: CGPoint?) -> ()

    var body: some View {
        HStack {
            VStack {
                ForEach(node.inputPoints) { inputPoint in
                    InputPointView(inputPoint: inputPoint)
                }
            }
            VStack(spacing: 0){
                VStack(alignment: .leading, spacing: 10) {
                    //제목
                    if isEditing {
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
                    }

                    //노트
                    if isEditing {
                        TextEditor(text: $node.unwrappedNote)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .border(Color.clear, width: 0)
                            .foregroundColor(.black)
                            .font(.system(size: 13))
                            .frame(width: 200, height: 70)
                    } else {
                        Text(node.unwrappedNote)
                            .foregroundColor(.black)
                            .font(.system(size: 13, weight: .regular))
                            .frame(width:200,height: 50)
                    }

                    Divider().background(.gray)

                    if isEditing {
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
                        Button {
                            node.tags.append(.mockData)
                        } label: {
                            Text("+")
                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .background(Color.gray).opacity(0.8)
                                .cornerRadius(10)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }

                }
                .padding(20)
                .background(.gray)
                .frame(width: 250, height: 50)

            }
            .background()
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.25), radius: 1.5, x: 0, y: 0)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
            VStack {
                ForEach(node.outputPoints) { outputPoint in
                    OutputPointView(outputPoint: outputPoint)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragLocation = value.location
                                    currentOutputPoint = outputPoint.id
                                    updatePreviewEdge(outputPoint.id, dragLocation)
                                }
                                .onEnded { value in
                                    if let dragLocation {
                                        if let (outputID, inputID) = self.judgeConnection(with: dragLocation) {
                                            addEdge(KPEdge(sourceID: outputID, sinkID: inputID))
                                        }
                                    }
                                    dragLocation = nil
                                    updatePreviewEdge(outputPoint.id, dragLocation)
                                }
                        )
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

extension NodeView: Equatable {
    static func == (lhs: NodeView, rhs: NodeView) -> Bool {
        lhs.node == rhs.node
    }
}

#Preview {
    NodeView(node: .constant(.mockData), judgeConnection: { _, _ in (UUID(), UUID()) }, addEdge: { _ in }, updatePreviewEdge: { _, _ in })
}
