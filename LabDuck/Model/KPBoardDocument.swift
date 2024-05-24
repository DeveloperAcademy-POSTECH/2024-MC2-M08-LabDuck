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
}

extension KPBoardDocument {
    func moveNode(_ nodeID: KPNode.ID, to position: CGPoint, undoManager: UndoManager? = nil) {
        guard let index = getIndex(nodeID) else { return }

        let originalPosition = self.board.nodes[index].position

        self.board.nodes[index].position = position

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.moveNode(nodeID, to: originalPosition, undoManager: undoManager)
        }
    }
}
