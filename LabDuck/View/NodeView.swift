//
//  NodeView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI
import Combine

struct NodeView: View {
    @Binding var node: KPNode
    @State private var dragLocation: CGPoint?
    @State private var currentOutputPoint: KPOutputPoint.ID?
    //@State private var isHovering = false
   // @Binding var isHovering: Bool // 바인딩으로 전달 받음

    var judgeConnection: (_ outputID: KPOutputPoint.ID, _ dragLocation: CGPoint) -> (KPOutputPoint.ID, KPInputPoint.ID)?
    var addEdge: (_ edge: KPEdge) -> ()
    var updatePreviewEdge: (_ sourceID: KPOutputPoint.ID, _ dragPoint: CGPoint?) -> ()

    
    //ObservableObject 클래스 정의
    class HoverState: ObservableObject {
        @Published var isHover: Bool = false
    }
    
    //HoverState 사용
    @ObservedObject var hoverState: HoverState
    
    var body: some View {
        HStack {
            VStack {
                ForEach(node.inputPoints) { inputPoint in
                    InputPointView(inputPoint: inputPoint)
                }
            }.onHover { 
                hovering in
                self.hoverState.isHover = hovering //마우스가 닿아있으면 true
                //isHovering = true
                //print(isHovering)
                print("11111111111111")
            }
            //.background(isHovering ? Color.blue : Color.red)
            VStack {
                Text("asdf")
                Text(node.unwrappedTitle)
                TextField("title", text: $node.unwrappedTitle)
                if let dragLocation {
                    Text("\(dragLocation.y.rounded()), \(dragLocation.x.rounded())")
                }
            }.onHover {
                hovering in
                self.hoverState.isHover = hovering //마우스가 닿아있으면 true
//                isHovering = true
//                print(isHovering)
                print("222222222222222")
            }
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
                                            print("Connection 찾기 성공")
                                            addEdge(KPEdge(sourceID: outputID, sinkID: inputID))
                                        } else {
                                            print("Connection 찾기 실패")
                                        }
                                    }
                                    dragLocation = nil
                                    updatePreviewEdge(outputPoint.id, dragLocation)
                                }
                        )
                }
            }.onHover {
                hovering in
                self.hoverState.isHover = hovering //마우스가 닿아있으면 true
//                isHovering = true
//                print(isHovering)
                print("33333333333333")
            }
        }
        .padding()
        .background(Color.pink)
        .border(Color.black, width: 2.0)
        .frame(maxWidth: 250, maxHeight: 50)
        .draggable(offset: $node.position)
        .onHover {
            hovering in
            self.hoverState.isHover = hovering //마우스가 닿아있으면 true
//            isHovering = true
//            print(isHovering)
            print("4444444444444444")
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
//    NodeView(node: .constant(.mockData), judgeConnection: { _, _ in (UUID(), UUID()) }, addEdge: { _ in }, updatePreviewEdge: { _, _ in })
//}
