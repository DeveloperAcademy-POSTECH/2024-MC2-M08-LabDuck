//
//  CSVConvertManager.swift
//  LabDuck
//
//  Created by 정종인 on 5/21/24.
//

import SwiftCSV
import Foundation

class CSVConvertManager {
    private init() {}

    static func csvStringToDictionary(_ contents: String) throws -> [[String: String]] {
        let csv = try NamedCSV(string: contents)
        return csv.rows
    }

    static private let keyMapping: [String: PartialKeyPath<KPNode>] = [
        "Name": \KPNode.unwrappedTitle,
        "Tags": \KPNode.tags,
        "Text": \KPNode.unwrappedNote,
        "URL" : \KPNode.unwrappedURL,
    ]

    static private func writableKeyPath<V>(from label: String, type: V.Type) -> WritableKeyPath<KPNode, V>? {
        guard let keyPath = keyMapping[label] else { return nil }
        return keyPath as? WritableKeyPath<KPNode, V>
    }

    static func addNodeToKPBoard(_ board: KPBoard, _ contents: [String: String]) -> KPBoard {
        var board = board
        var node = KPNode()
        contents.forEach { key, value in
            print("key : \(key)")
            print("value : \(value)")
            if let writableKeyPath = writableKeyPath(from: key, type: String.self) {
                node[keyPath: writableKeyPath] = value
            } else if writableKeyPath(from: key, type: [KPTag.ID].self) != nil {
                let values = value.components(separatedBy: ",")
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { name in
                        !name.isEmpty
                    }
                    .forEach { name in
                    if let tag = board.getTag(name) {
                        node[keyPath: \.tags].append(tag.id)
                    } else {
                        let tag = board.createTag(name)
                        node[keyPath: \.tags].append(tag.id)
                    }
                }
            } else {
                print("writableKeyPath 없음")
            }
        }
        board.addNode(node)
        return board
    }
}
