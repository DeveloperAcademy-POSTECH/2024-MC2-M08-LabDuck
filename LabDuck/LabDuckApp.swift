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
        Window("Board Gallery", id: "BoardGallery") {
            BoardGalleryView()
        }
        .defaultPosition(.center)
        .defaultSize(width: 800, height: 400)
        .keyboardShortcut("1", modifiers: [.command])

        DocumentGroup(newDocument: { KPBoardDocument() }) { configuration in
            MainDocumentView(
                url: configuration.fileURL
            )
        }
    }
}
