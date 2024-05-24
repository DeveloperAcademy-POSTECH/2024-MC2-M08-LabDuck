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

    public func loadDocuments() -> Set<URL> {
        if let savedData = userDefault.data(forKey: Keys.documents) {
            do {
                let savedArray = try JSONDecoder().decode([URL].self, from: savedData)
                let savedSet = Set(savedArray)
                return savedSet
            } catch {
                print("Failed to decode KPBoardDocument array: \(error)")
                return []
            }
        } else {
            return []
        }
    }

    public func setDocument(_ url: URL?) {
        var savedSet = loadDocuments()
        if let url {
            savedSet.insert(url)
            setDocuments(savedSet)
        } else {
            setDocuments(savedSet)
        }
    }

    private func setDocuments(_ set: Set<URL>) {
        do {
            let data = try JSONEncoder().encode(Array(set))
            userDefault.set(data, forKey: Keys.documents)
        } catch {
            print("Failed to encode KPBoardDocument set: \(error)")
        }
    }
}
