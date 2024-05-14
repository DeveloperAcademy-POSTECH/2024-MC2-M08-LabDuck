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
    var judgeConnection: (_ outputID: KPOutputPoint.ID, _ dragLocation: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)?
    var addEdge: (_ edge: KPEdge) -> ()

    var body: some View {
        HStack {
            VStack {
                ForEach(node.inputPoints) { inputPoint in
                    InputPointView(inputPoint: inputPoint)
                }
            }
            VStack {
                Text("asdf")
                Text(node.unwrappedTitle)
                TextField("title", text: $node.unwrappedTitle)
                if let dragLocation {
                    Text("\(dragLocation.y.rounded()), \(dragLocation.x.rounded())")
                }
            }
            VStack {
                ForEach(node.outputPoints) { outputPoint in
                    OutputPointView(outputPoint: outputPoint)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragLocation = value.location
                                    currentOutputPoint = outputPoint.id
                                }
                                .onEnded { value in
                                    dragLocation = value.location
                                    currentOutputPoint = outputPoint.id
                                    print(dragLocation!)
                                    if let dragLocation {
                                        if let (outputID, inputID) = self.judgeConnection(with: dragLocation) {
                                            print("Connection 찾기 성공")
                                            addEdge(KPEdge(sourceID: outputID, sinkID: inputID))
                                        } else {
                                            print("Connection 찾기 실패")
                                        }
                                    }
                                }
                        )
                }
            }
        }
        .padding()
        .background(Color.pink)
        .border(Color.black, width: 2.0)
        .frame(maxWidth: 250, maxHeight: 50)
        .draggable(offset: $node.position)
    }

    private func judgeConnection(with location: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)? {
        if let currentOutputPoint {
            return self.judgeConnection(currentOutputPoint, location)
        } else {
            return nil
        }
    }
}

#Preview {
    NodeView(node: .constant(.mockData), judgeConnection: { _, _ in (UUID(), UUID()) }, addEdge: { _ in })
}
