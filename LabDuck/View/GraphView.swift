//
//  GraphView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct GraphView: View {
    @State private var board: KPBoard = .mockData
    @State private var inputPointRects: [KPInputPoint.ID : CGRect] = [:]
    @State private var outputPointRects: [KPOutputPoint.ID : CGRect] = [:]

    @State private var previewEdge: (CGPoint, CGPoint)? = nil
    var body: some View {
        ZStack {
            ForEach(board.edges) { edge in
                Path { path in
                    if let sourcePoint = outputPointRects[edge.sourceID],
                       let sinkPoint = inputPointRects[edge.sinkID] {
                        path.move(to: sourcePoint.center)
                        path.addLine(to: sinkPoint.center)
                    }
                }
                .stroke(lineWidth: 2)
            }
            ForEach(self.$board.nodes) { node in
                NodeView(
                    node: node,
                    judgeConnection: self.judgeConnection(outputID:dragLocation:),
                    addEdge: self.addEdge(edge:),
                    updatePreviewEdge: self.updatePreviewEdge(from:to:)
                )
            }
            if let previewEdge {
                Path { path in
                    path.move(to: previewEdge.0)
                    path.addLine(to: previewEdge.1)
                }
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
    }
}

#Preview {
    GraphView()
}

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
