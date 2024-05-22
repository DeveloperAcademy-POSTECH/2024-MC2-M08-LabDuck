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
    func readStorageData() -> Result<KPBoardGallery, BoardGalleryErrors>
    func saveData() -> Result<Void, BoardGalleryErrors>
}

final class DefaultBoardGalleryUseCase: BoardGalleryUseCase {
    let boardGalleryRepository: BoardGalleryRepository
    init(boardGalleryRepository: BoardGalleryRepository) {
        self.boardGalleryRepository = boardGalleryRepository
    }
    func readStorageData() -> Result<KPBoardGallery, BoardGalleryErrors> {
        let urlString = self.boardGalleryRepository.getBoardGallery()
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            return .failure(.error)
        }
    }

    func saveData() -> Result<Void, BoardGalleryErrors> {
        boardGalleryRepository.set
    }
}
