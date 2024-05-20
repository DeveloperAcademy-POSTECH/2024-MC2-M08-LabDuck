//
//  LabDuckApp.swift
//  LabDuck
//
//  Created by 정종인 on 5/10/24.
//

import SwiftUI

@main
struct LabDuckApp: App {
    var body: some Scene {
        WindowGroup {
            BoardGallery()
        }

        WindowGroup("메인 뷰", id: "main") {
            MainView()
        }
    }
}
