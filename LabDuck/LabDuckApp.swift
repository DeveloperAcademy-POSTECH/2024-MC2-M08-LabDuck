//
//  LabDuckApp.swift
//  LabDuck
//
//  Created by 정종인 on 5/10/24.
//

import SwiftUI

@main
struct LabDuckApp: App {
    let boardGalleryManager = KPBoardGalleryManager()
    let boardManager = KPBoardManager()
    var body: some Scene {
        WindowGroup {
            BoardGalleryView()
        }

        WindowGroup("메인 뷰", id: "main") {
            MainView()
        }
    }
}
