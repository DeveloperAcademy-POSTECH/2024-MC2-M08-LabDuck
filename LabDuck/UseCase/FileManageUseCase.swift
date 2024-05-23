//
//  FileManageUseCase.swift
//  LabDuck
//
//  Created by 정종인 on 5/22/24.
//

import Foundation

enum FileManageErrors: Error {
    case invalidURL
    case cannotAccess
    case invalidData
    case writeFailed
}

protocol FileManageUseCase {
    func getBoardGalleryPath() -> Result<URL, FileManageErrors>
    func isExist(_ path: URL) -> Result<Bool, Never>
    func readFile(_ url: URL) async -> Result<Data, FileManageErrors>
    func writeFile(_ url: URL, contents: Data) async -> Result<Void, FileManageErrors>
}

final class LocalFileManageUseCase: FileManageUseCase {
    let fileManager = FileManager.default

    func getBoardGalleryPath() -> Result<URL, FileManageErrors> {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.cannotAccess)
        }
        print("documentDirectory : ", documentDirectory)
        let boardGalleryFileURLString = documentDirectory.appendingPathComponent("BoardGallery")
        return .success(boardGalleryFileURLString)
    }

    func isExist(_ path: URL) -> Result<Bool, Never> {
        if fileManager.fileExists(atPath: path.path()) {
            return .success(true)
        } else {
            return .success(false)
        }
    }

    func readFile(_ url: URL) async -> Result<Data, FileManageErrors> {
        do {
            let data = try Data(contentsOf: url)
            return .success(data)
        } catch {
            print(error.localizedDescription)
        }
        return .failure(.cannotAccess)
    }

    func writeFile(_ url: URL, contents: Data) async -> Result<Void, FileManageErrors> {
        if fileManager.createFile(atPath: url.path(), contents: contents) {
            return .success(())
        } else {
            return .failure(.writeFailed)
        }
    }
}

final class TestFileManageUseCase: FileManageUseCase {
    let fileManager = FileManager.default
    func getBoardGalleryPath() -> Result<URL, FileManageErrors> {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.cannotAccess)
        }
        print("documentDirectory : ", documentDirectory)
        let boardGalleryFileURLString = documentDirectory.appendingPathComponent("BoardGallery")
        return .success(boardGalleryFileURLString)
    }

    func isExist(_ path: URL) -> Result<Bool, Never> {
        if fileManager.fileExists(atPath: path.path()) {
            return .success(true)
        } else {
            return .success(false)
        }
    }

    func readFile(_ url: URL) async -> Result<Data, FileManageErrors> {
        return .success("".data(using: .utf8)!)
    }
    
    func writeFile(_ url: URL, contents: Data) async -> Result<Void, FileManageErrors> {
        return .success(())
    }
}
