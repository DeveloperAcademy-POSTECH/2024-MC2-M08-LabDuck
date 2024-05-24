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

struct KPBoardDocument: FileDocument, Codable, Hashable {
    var board: KPBoard
    var url: URL?
    var fileName: String? {
        self.url?.deletingPathExtension().lastPathComponent
    }

    static var readableContentTypes: [UTType] { [.kpBoardDocument] }

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

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(board)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}
