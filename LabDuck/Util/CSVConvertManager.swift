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
        "Text": \KPNode.unwrappedNote
    ]

    static private func writableKeyPath<V>(from label: String, type: V.Type) -> WritableKeyPath<KPNode, V>? {
        guard let keyPath = keyMapping[label] else { return nil }
        return keyPath as? WritableKeyPath<KPNode, V>
    }

    static func dictionaryToKPNode(_ contents: [String: String]) -> KPNode {
        var node = KPNode()
        contents.forEach { key, value in
            if let writableKeyPath = writableKeyPath(from: key, type: String.self) {
                node[keyPath: writableKeyPath] = value
            } else if let writableKeyPath = writableKeyPath(from: key, type: [KPTag].self) {
                let values = value.components(separatedBy: ",")
                node[keyPath: \.tags] = values.toKPTags()
            } else {
                print("writableKeyPath 없음")
            }
        }
        dump(node)
        return node
    }
}
