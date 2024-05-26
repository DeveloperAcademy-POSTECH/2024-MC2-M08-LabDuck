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
        "URL" : \KPNode.url,
    ]

    static private func writableKeyPath<V>(from label: String, type: V.Type) -> WritableKeyPath<KPNode, V>? {
        guard let keyPath = keyMapping[label] else { return nil }
        return keyPath as? WritableKeyPath<KPNode, V>
    }

    static func addNodeToKPBoard(_ board: KPBoard, _ contents: [String: String]) -> KPBoard {
        var board = board
        var node = KPNode()
        contents.forEach { key, value in
            if let writableKeyPath = writableKeyPath(from: key, type: String.self) {
                node[keyPath: writableKeyPath] = value
            } else if let writableKeyPath = writableKeyPath(from: key, type: [KPTag].self) {
                let values = value.components(separatedBy: ",")
                values.forEach { name in
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
        dump(node)
        board.addNode(node)
        return board
    }
}
