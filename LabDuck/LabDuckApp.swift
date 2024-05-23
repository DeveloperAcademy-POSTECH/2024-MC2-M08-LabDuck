//
//  LabDuckApp.swift
//  LabDuck
//
//  Created by 정종인 on 5/10/24.
//

import SwiftUI

@main
struct LabDuckApp: App {
    private let boardGalleryDIContiner: BoardGalleryDIContainer
    private let boardDIContainer: BoardDIContainer
    init() {
        let appDIContainer = AppDIContainer()
        self.boardGalleryDIContiner = appDIContainer.makeBoardGalleryDIContainer()
        self.boardDIContainer = appDIContainer.makeBoardDIContainer()
        dump(boardGalleryDIContiner)
    }
    var body: some Scene {
        WindowGroup {
            BoardGalleryView(boardGalleryUseCase: boardGalleryDIContiner.makeBoardGalleryUseCase())
        }

        WindowGroup("메인 뷰", id: "main") {
            MainView()
        }
    }
}
