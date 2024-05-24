//
//  GraphView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI
import Combine

struct GraphView: View {
    @Binding var board: KPBoard
    @Binding var searchText :String

    // MARK: Edges
    @State private var inputPointRects: [KPInputPoint.ID : CGRect] = [:]
    @State private var outputPointRects: [KPOutputPoint.ID : CGRect] = [:]

    @State private var previewEdge: (CGPoint, CGPoint)? = nil
    @State private var hoveredEdgeID: KPEdge.ID? = nil
    @State private var selectedEdgeID: KPEdge.ID? = nil
    
    @State private var clickingOutput: Bool = false

//    @State var isEditingForTitle: Bool = false

    // MARK: Combine
    @State var cancellabes = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            Color.white
                .contentShape(Rectangle()) // 클릭 이벤트를 감지할 수 있도록 설정
//                .onTapGesture {
//                        isEditingForTitle.toggle()
//                }
            ForEach(board.edges) { edge in
                if let sourcePoint = outputPointRects[edge.sourceID]?.center,
                   let sinkPoint = inputPointRects[edge.sinkID]?.center {
                    PathBetween(sourcePoint, sinkPoint)
                        .stroke(hoveredEdgeID == edge.id ? .red : .black, lineWidth: 2)
                        .shadow(radius: selectedEdgeID == edge.id ? 6 : 0)
                    PathShapes(sourcePoint, sinkPoint, edge.id)
                }
            }
            ForEach(self.$board.nodes) { node in

                NodeView(
                    node: node, clickingOutput: $clickingOutput, /*isEditingForTitle: $isEditingForTitle,*/
                    searchText: $searchText, 
                    judgeConnection: self.judgeConnection(outputID:dragLocation:),
                    addEdge: self.addEdge(edge:),
                    updatePreviewEdge: self.updatePreviewEdge(from:to:)
                )
                .draggable(offset: node.position)
            }
            if let previewEdge {
                PathBetween(previewEdge.0, previewEdge.1)
                    .stroke(lineWidth: 2)
            }
        }
        .backgroundPreferenceValue(InputPointPreferenceKey.self) { values in
            GeometryReader { proxy in
                self.readPreferenceValues(from: values, in: proxy)
            }
        }
        .backgroundPreferenceValue(OutputPointPreferenceKey.self) { values in
            GeometryReader { proxy in
                self.readPreferenceValues(from: values, in: proxy)
            }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if hoveredEdgeID == nil {
                        self.selectedEdgeID = nil
                    }
                }
        )
        .onAppear {
            trackDeleteCommand {
                if let selectedEdgeID {
                    self.board.removeEdge(selectedEdgeID)
                }
                selectedEdgeID = nil
            }
        }
    }

    @ViewBuilder
    private func PathBetween(_ sourcePoint: CGPoint, _ sinkPoint: CGPoint) -> Path {
        let midPoint = (sourcePoint + sinkPoint) / 2
        let control1 = CGPoint(x: midPoint.x, y: sourcePoint.y)
        let control2 = CGPoint(x: midPoint.x, y: sinkPoint.y)
        Path { path in
            path.move(to: sourcePoint)
            path.addCurve(to: sinkPoint, control1: control1, control2: control2)
        }
    }

    @ViewBuilder
    private func PathShapes(_ sourcePoint: CGPoint, _ sinkPoint: CGPoint, _ edgeID: KPEdge.ID) -> some View {
        let pathShapeSide = 10.0 // 선을 이루는 shape들의 width, height, 간격은 모두 10.0으로 설정합니다.
        let pathShapeCount = sourcePoint.distance(from: sinkPoint) / pathShapeSide // 선의 길이에 따라 개수가 달라집니다.
        let pathShapeRange: [Double] = (0..<Int(pathShapeCount)).map { Double($0) / pathShapeCount }
        let path = PathBetween(sourcePoint, sinkPoint)
        ForEach(pathShapeRange, id: \.self) {
            if let point = path.trimmedPath(from: 0.0, to: $0).currentPoint {
                Rectangle()
                    .fill(.clear)
                    .frame(width: pathShapeSide, height: pathShapeSide)
                    .onHover { isHover in
                        if isHover {
                            self.hoveredEdgeID = edgeID
                        } else {
                            self.hoveredEdgeID = nil
                        }
                    }
                    .onTapGesture {
                        self.selectedEdgeID = edgeID
                    }
                    .position(point)
            }
        }
    }
}

//#Preview {
//    GraphView(board: .constant(.mockData), isEditingForTitle: isEditingForTitle)
//}

// MARK: - read preferences : 각 지점의 아이디와 위치를 가져오기 위한 메소드들
extension GraphView {
    private func readPreferenceValues(from values: [InputPointPreference], in proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            values.forEach { preference in
                self.inputPointRects[preference.inputID] = proxy[preference.bounds]
            }
        }
        return Rectangle()
            .fill(Color.clear)
    }

    private func readPreferenceValues(from values: [OutputPointPreference], in proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            values.forEach { preference in
                self.outputPointRects[preference.outputID] = proxy[preference.bounds]
            }
        }
        return Rectangle()
            .fill(Color.clear)
    }
}

// MARK: - Callback Defenition : 하위 뷰에서 read preferences로 읽어온 데이터를 활용하기 위해 전달하는 클로저.
extension GraphView {
    
    private func judgeConnection(
        outputID: KPOutputPoint.ID,
        dragLocation: CGPoint
    ) -> (KPOutputPoint.ID, KPInputPoint.ID)? {
        guard let outputItem = self.outputPointRects.first(where: { id, _ in
            id == outputID
        }) else { return nil }

        let calculatedPoint = outputItem.1.origin + dragLocation

        guard let inputItem = self.inputPointRects.first(where: { _, rect in
            CGRectContainsPoint(rect, calculatedPoint)
        }) else { return nil }

        return (outputItem.0, inputItem.0)
    }

    private func addEdge(
        edge: KPEdge
    ) {
        self.board.addEdge(edge)

        // MARK: 디버그용 출력 문장들, 추후 삭제 등에 이 코드가 필요할 것 같음
        self.board.nodes.forEach { node in
            
            node.outputPoints.forEach { outputPoint in
                if outputPoint.id == edge.sourceID {
                    print("outputPoint 정보 : \(outputPoint.name ?? "")")
                    if let ownerNodeID = outputPoint.ownerNode {
                        self.board.nodes.forEach { node in
                            if node.id == ownerNodeID {
                                print("<- 그의 부모는 \(node.title ?? "") 입니다.")
                            }
                        }
                    }
                }
            }
            node.inputPoints.forEach { inputPoint in
                if inputPoint.id == edge.sinkID {
                    print("inputPoint 정보 : \(inputPoint.name ?? "")")
                    
                    
                    if let ownerNodeID = inputPoint.ownerNode {
                        self.board.nodes.forEach { node in
                            if node.id == ownerNodeID {
                                
                                print("<- 그의 부모는 \(node.title ?? "") 입니다.")
                            }
                        }
                    }
                }
            }
        }
    }

    private func updatePreviewEdge(
        from sourceID: KPOutputPoint.ID,
        to dragPoint: CGPoint?
    ) {
        if let outputPointRect = outputPointRects[sourceID], let dragPoint {
            self.previewEdge = (outputPointRect.center, outputPointRect.origin + dragPoint)
        } else {
            self.previewEdge = nil
        }
    }
}



// MARK: - Delete key를 받기 위한
extension GraphView {
    private func trackDeleteCommand(_ perform: @escaping () -> ()) {
        NSApp.publisher(for: \.currentEvent)
            .filter { event in
                event?.type == .keyUp && (event?.keyCode == 51 || event?.keyCode == 117)
            }
            .sink { (event: NSEvent?) in
                perform()
            }
            .store(in: &cancellabes)
    }
}
