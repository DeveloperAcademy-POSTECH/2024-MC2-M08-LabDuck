//
//  BoardGalleryUseCase.swift
//  LabDuck
//
//  Created by 정종인 on 5/22/24.
//

import Foundation

enum BoardGalleryErrors: Error {
    case error
}

protocol BoardGalleryUseCase {
    func readData() async -> Result<KPBoardGallery, BoardGalleryErrors>
    func saveData(_ boardGallery: KPBoardGallery) async -> Result<Void, BoardGalleryErrors>
}

final class DefaultBoardGalleryUseCase: BoardGalleryUseCase {
    let fileManageUseCase: FileManageUseCase
    let codingUseCase: CodingUseCase
    init(
        fileManageUseCase: FileManageUseCase,
        codingUseCase: CodingUseCase
    ) {
        self.fileManageUseCase = fileManageUseCase
        self.codingUseCase = codingUseCase
    }

    func readData() async -> Result<KPBoardGallery, BoardGalleryErrors> {
        guard case .success(let boardGalleryPath) = fileManageUseCase.getBoardGalleryPath() else {
            return .failure(.error)
        }

        guard case .success(let isExist) = fileManageUseCase.isExist(boardGalleryPath) else {
            return .failure(.error)
        }

        if !isExist {
            await self.saveDefaultData(boardGalleryPath)
        }

        guard case .success(let data) = await fileManageUseCase.readFile(boardGalleryPath) else {
            return .failure(.error)
        }

        guard case .success(let dto) = codingUseCase.decode(KPBoardGalleryDTO.self, from: data) else {
            return .failure(.error)
        }

        return .success(toVO(dto))
    }

    func saveData(_ boardGallery: KPBoardGallery) async -> Result<Void, BoardGalleryErrors> {
        let dto = toDTO(boardGallery)

        guard case .success(let data) = codingUseCase.encode(dto) else {
            return .failure(.error)
        }

        guard case .success(let boardGalleryPath) = fileManageUseCase.getBoardGalleryPath() else {
            return .failure(.error)
        }

        guard case .success = await fileManageUseCase.writeFile(boardGalleryPath, contents: data) else {
            return .failure(.error)
        }

        return .success(())
    }

    private func saveDefaultData(_ path: URL) async {
        guard case .success(let data) = codingUseCase.encode(KPBoardGalleryDTO.emptyData) else {
            return
        }
        _ = await fileManageUseCase.writeFile(path, contents: data)
    }

    private func toDTO(_ boardGallery: KPBoardGallery) -> KPBoardGalleryDTO {
        KPBoardGalleryDTO(
            version: boardGallery.version,
            boardsURLString: boardGallery.boardsURLString
        )
    }

    private func toVO(_ boardGalleryDTO: KPBoardGalleryDTO) -> KPBoardGallery {
        KPBoardGallery(
            version: boardGalleryDTO.version ?? "0.0.1",
            boardsURLString: boardGalleryDTO.boardsURLString ?? []
        )
    }
}
