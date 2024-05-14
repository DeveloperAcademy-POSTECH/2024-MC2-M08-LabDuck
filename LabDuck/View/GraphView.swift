//
//  GraphView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct GraphView: View {
    @State private var nodes: [KPNode] = .mockData
    @State private var inputPoints: [(KPInputPoint.ID, CGRect)] = []
    @State private var outputPoints: [(KPOutputPoint.ID, CGRect)] = []
    var body: some View {
        ZStack {
            ForEach($nodes) { node in
                NodeView(
                    node: node,
                    judgeConnection: self.judgeConnection(outputID:dragLocation:),
                    connectEdge: self.connectEdge(outputID:inputID:)
                )
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

    private func readPreferenceValues(from values: [InputPointPreference], in proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.inputPoints = values.map({ preference in
                (preference.inputID, proxy[preference.bounds])
            })
            print(inputPoints)
        }
        return Rectangle()
            .fill(Color.clear)
    }

    private func readPreferenceValues(from values: [OutputPointPreference], in proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.outputPoints = values.map({ preference in
                (preference.outputID, proxy[preference.bounds])
            })
            print(outputPoints)
        }
        return Rectangle()
            .fill(Color.clear)
    }

    private func judgeConnection(
        outputID: KPOutputPoint.ID,
        dragLocation: CGPoint
    ) -> (KPOutputPoint.ID, KPInputPoint.ID)? {
        guard let outputItem = self.outputPoints.first(where: { id, _ in
            id == outputID
        }) else { return nil }

        let calculatedPoint = outputItem.1.origin + dragLocation

        guard let inputItem = self.inputPoints.first(where: { _, rect in
            CGRectContainsPoint(rect, calculatedPoint)
        }) else { return nil }

        return (outputItem.0, inputItem.0)
    }

    private func connectEdge(
        outputID: KPOutputPoint.ID,
        inputID: KPInputPoint.ID
    ) {
        self.nodes.forEach { node in
            node.outputPoints.forEach { outputPoint in
                if outputPoint.id == outputID {
                    print("outputPoint 정보 : \(outputPoint.name ?? "")")
                    if let ownerNodeID = outputPoint.ownerNode {
                        self.nodes.forEach { node in
                            if node.id == ownerNodeID {
                                print("<- 그의 부모는 \(node.title ?? "") 입니다.")
                            }
                        }
                    }
                }
            }
            node.inputPoints.forEach { inputPoint in
                if inputPoint.id == inputID {
                    print("inputPoint 정보 : \(inputPoint.name ?? "")")
                    if let ownerNodeID = inputPoint.ownerNode {
                        self.nodes.forEach { node in
                            if node.id == ownerNodeID {
                                print("<- 그의 부모는 \(node.title ?? "") 입니다.")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    GraphView()
}
