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
    func readFile(_ urlString: String) async -> Result<Data, FileManageErrors>
    func writeFile(_ urlString: String, contents: Data) async -> Result<Void, FileManageErrors>
}

final class LocalFileManageUseCase: FileManageUseCase {
    func readFile(_ urlString: String) async -> Result<Data, FileManageErrors> {
        guard let url = URL(string: urlString) else { return .failure(.invalidURL) }
        let gotAccess = url.startAccessingSecurityScopedResource()
        if !gotAccess { return .failure(.cannotAccess) }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        guard let fileData = try? Data(contentsOf: url) else { return .failure(.invalidData)}

        return .success(fileData)
    }
    
    func writeFile(_ urlString: String, contents: Data) async -> Result<Void, FileManageErrors> {
        guard let url = URL(string: urlString) else { return .failure(.invalidURL) }
        let gotAccess = url.startAccessingSecurityScopedResource()
        if !gotAccess { return .failure(.cannotAccess) }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            try contents.write(to: url, options: .atomic)
        } catch {
            return .failure(.writeFailed)
        }

        return .success(())
    }
}

final class TestFileManageUseCase: FileManageUseCase {
    func readFile(_ urlString: String) async -> Result<Data, FileManageErrors> {
        return .success("".data(using: .utf8)!)
    }
    
    func writeFile(_ urlString: String, contents: Data) async -> Result<Void, FileManageErrors> {
        return .success(())
    }
}
