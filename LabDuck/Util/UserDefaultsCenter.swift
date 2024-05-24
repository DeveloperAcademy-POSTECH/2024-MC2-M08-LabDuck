//
//  UserDefaultsCenter.swift
//  LabDuck
//
//  Created by 정종인 on 5/24/24.
//

import Foundation

enum Keys {
    static let documents = "Documents"
}

final class UserDefaultsCenter {
    static let shared = UserDefaultsCenter()
    private let userDefault = UserDefaults.standard

    private init() {}

    public func loadDocuments() -> Set<KPBoardDocument>? {
        if let savedData = userDefault.data(forKey: Keys.documents) {
            do {
                let savedArray = try JSONDecoder().decode([KPBoardDocument].self, from: savedData)
                let savedSet = Set(savedArray.filter { $0.fileName != nil })
                print("savedSet count : ", savedSet.count)
                return savedSet
            } catch {
                print("Failed to decode KPBoardDocument array: \(error)")
                return nil
            }
        } else {
            return nil
        }
    }

    public func setDocuments(_ set: Set<KPBoardDocument>) {
        do {
            let data = try JSONEncoder().encode(Array(set))
            userDefault.set(data, forKey: Keys.documents)
        } catch {
            print("Failed to encode KPBoardDocument set: \(error)")
        }
    }

    public func setDocument(_ document: KPBoardDocument, _ url: URL?) {
        var document = document
        document.url = url
        if var savedSet = loadDocuments() {
            savedSet.insert(document)
            setDocuments(savedSet)
        } else {
            setDocuments([document])
        }
    }
}
