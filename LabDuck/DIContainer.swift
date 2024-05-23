//
//  DIContainer.swift
//  LabDuck
//
//  Created by 정종인 on 5/22/24.
//

import Foundation

final class AppDIContainer {
    public func makeBoardDIContainer() -> BoardDIContainer {
        return BoardDIContainer()
    }

    public func makeBoardGalleryDIContainer() -> BoardGalleryDIContainer {
        return BoardGalleryDIContainer()
    }
}

final class BoardGalleryDIContainer {
    public func makeFileManageUseCase() -> FileManageUseCase {
        return LocalFileManageUseCase()
    }

    public func makeCodingUseCase() -> CodingUseCase {
        return JSONCodingUseCase()
    }

    public func makeBoardGalleryUseCase() -> BoardGalleryUseCase {
        return DefaultBoardGalleryUseCase(
            fileManageUseCase: makeFileManageUseCase(),
            codingUseCase: makeCodingUseCase()
        )
    }
}

final class BoardDIContainer {

}

final class TestDIContainer {
    public func makeFileManageUseCase() -> FileManageUseCase {
        return TestFileManageUseCase()
    }

    public func makeCodingUseCase() -> CodingUseCase {
        return JSONCodingUseCase()
    }

    public func makeBoardGalleryUseCase() -> BoardGalleryUseCase {
        return DefaultBoardGalleryUseCase(
            fileManageUseCase: makeFileManageUseCase(),
            codingUseCase: makeCodingUseCase()
        )
    }
}
