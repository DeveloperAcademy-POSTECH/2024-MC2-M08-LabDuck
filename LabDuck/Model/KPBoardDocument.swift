//
//  KPBoardDocument.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let kpBoardDocument = UTType(exportedAs: "team.kapochip.LabDuck")
}

final class KPBoardDocument: ReferenceFileDocument {
    typealias Snapshot = KPBoard

    @Published var board: KPBoard

    static var readableContentTypes: [UTType] { [.kpBoardDocument] }

    func snapshot(contentType: UTType) throws -> KPBoard {
        self.board
    }

    init() {
        self.board = .emptyData
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.board = try JSONDecoder().decode(KPBoard.self, from: data)
    }

    func fileWrapper(snapshot: KPBoard, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(board)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}

extension KPBoardDocument {
    private func getIndex(_ nodeID: KPNode.ID) -> Int? {
        self.board.nodes.firstIndex { $0.id == nodeID }
    }
    private func getInputPointIndex(_ nodeIndex: Int, _ inputPointID: KPInputPoint.ID) -> Int? {
        self.board.nodes[nodeIndex].inputPoints.firstIndex { $0.id == inputPointID }
    }
}

// MARK: - 노드
extension KPBoardDocument {
    // 전체 노드 (최상위 뷰에서 이를 사용하지 않는 이유는 성능 문제가 있기 때문)
    func updateNode(node: KPNode, undoManager: UndoManager? = nil) {
        let nodeID = node.id
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index]

        guard self.board.nodes[index] != node else { return }

        self.board.nodes[index] = node

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(node: original, undoManager: undoManager)
        }
    }

    // Title
    func updateNode(_ nodeID: KPNode.ID, title: String?, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].title

        self.board.nodes[index].title = title

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, title: original, undoManager: undoManager)
        }
    }

    // Note
    func updateNode(_ nodeID: KPNode.ID, note: String?, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].note

        self.board.nodes[index].note = note

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, note: original, undoManager: undoManager)
        }
    }

    // URL
    func updateNode(_ nodeID: KPNode.ID, url: String?, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].url

        self.board.nodes[index].url = url

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, url: original, undoManager: undoManager)
        }
    }

    // URL
    func updateNode(_ nodeID: KPNode.ID, tags: [KPTag], undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].tags

        self.board.nodes[index].tags = tags

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, tags: original, undoManager: undoManager)
        }
    }

    // ColorTheme
    func updateNode(_ nodeID: KPNode.ID, colorTheme: KPColorTheme, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].colorTheme

        self.board.nodes[index].colorTheme = colorTheme

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, colorTheme: original, undoManager: undoManager)
        }
    }

    // Position
    func updateNode(_ nodeID: KPNode.ID, position: CGPoint, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].position

        self.board.nodes[index].position = position

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, position: original, undoManager: undoManager)
        }
    }

    // Size
    func updateNode(_ nodeID: KPNode.ID, size: CGSize, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].size

        self.board.nodes[index].size = size

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, size: original, undoManager: undoManager)
        }
    }

    // add InputPoint
    func addInputPoint(_ nodeID: KPNode.ID, inputPoint: KPInputPoint, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        self.board.nodes[index].inputPoints.append(inputPoint)

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.deleteInputPoint(nodeID, inputPointID: inputPoint.id, undoManager: undoManager)
        }
    }

    // delete InputPoint
    func deleteInputPoint(_ nodeID: KPNode.ID, inputPointID: KPInputPoint.ID, undoManager: UndoManager? = nil) {
        guard let nodeIndex = getIndex(nodeID) else { return }
        guard let inputPointIndex = getInputPointIndex(nodeIndex, inputPointID) else { return }

        let originalInputPoint = self.board.nodes[nodeIndex].inputPoints[inputPointIndex]

        self.board.nodes[nodeIndex].inputPoints.remove(at: inputPointIndex)

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.addInputPoint(nodeID, inputPoint: originalInputPoint, undoManager: undoManager)
        }
    }

    // add OutputPoint
    // TODO: - Edge 관련 로직 추가되어야 함
    func addOutputPoint(_ nodeID: KPNode.ID, outputPoint: KPOutputPoint, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        self.board.nodes[index].outputPoints.append(outputPoint)

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.deleteOutputPoint(nodeID, outputPointID: outputPoint.id, undoManager: undoManager)
        }
    }

    // delete OutputPoint
    // TODO: - Edge 관련 로직 추가되어야 함
    func deleteOutputPoint(_ nodeID: KPNode.ID, outputPointID: KPOutputPoint.ID, undoManager: UndoManager? = nil) {
        guard let nodeIndex = getIndex(nodeID) else { return }
        guard let outputPointIndex = getInputPointIndex(nodeIndex, outputPointID) else { return }

        let originalOutputPoint = self.board.nodes[nodeIndex].outputPoints[outputPointIndex]

        self.board.nodes[nodeIndex].outputPoints.remove(at: outputPointIndex)

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.addOutputPoint(nodeID, outputPoint: originalOutputPoint, undoManager: undoManager)
        }
    }
}
