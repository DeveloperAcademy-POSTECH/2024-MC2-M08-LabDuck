////
////  BoardGalleryRepository.swift
////  LabDuck
////
////  Created by 정종인 on 5/22/24.
////
//
//import Foundation
//
//protocol BoardGalleryRepository {
//    func getBoardGallery(from boardGalleryURLString: String) async -> Result<KPBoardGalleryDTO, BoardGalleryErrors>
//    func setBoardGallery(_ boardGallery: KPBoardGalleryDTO, to boardGalleryURLString: String) async -> Result<Void, BoardGalleryErrors>
//}
//
//final class LocalBoardGalleryRepository: BoardGalleryRepository {
//    private var fileManageUseCase: FileManageUseCase
//    private var codingUseCase: CodingUseCase
//
//    init(fileManageUseCase: FileManageUseCase, codingUseCase: CodingUseCase) {
//        self.fileManageUseCase = fileManageUseCase
//        self.codingUseCase = codingUseCase
//    }
//
//    func getBoardGallery(from boardGalleryURLString: String) async -> Result<KPBoardGalleryDTO, BoardGalleryErrors> {
//        let readFileResult = await fileManageUseCase.readFile(boardGalleryURLString)
//        guard case .success(let data) = readFileResult else {
//            return .failure(.error)
//        }
//
//        guard case .success(let boardGallery) = codingUseCase.decode(KPBoardGalleryDTO.self, from: data) else {
//            return .failure(.error)
//        }
//
//        return .success(boardGallery)
//    }
//
//    func setBoardGallery(_ boardGallery: KPBoardGalleryDTO, to boardGalleryURLString: String) async -> Result<Void, BoardGalleryErrors> {
//        guard case .success(let data) = codingUseCase.encode(boardGallery) else {
//            return .failure(.error)
//        }
//        guard case .success = await fileManageUseCase.writeFile(boardGalleryURLString, contents: data) else {
//            return .failure(.error)
//        }
//        return .success(())
//    }
//}
