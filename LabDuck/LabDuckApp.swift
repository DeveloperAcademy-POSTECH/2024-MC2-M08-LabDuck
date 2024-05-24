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
        .keyboardShortcut("0", modifiers: [.command])

        DocumentGroup(newDocument: KPBoardDocument()) { configuration in
            var document: Binding<KPBoardDocument> {
                let url = configuration.fileURL
                let binding: Binding<KPBoardDocument> = configuration.$document
                binding.wrappedValue.url = url
                return binding
            }
            MainDocumentView(
                document: configuration.$document
            )
        }

//        DocumentGroup(newDocument: { KPBoardDocument() }) { configuration in
//            MainDocumentView()
//                .environment(\.documentURL, configuration.fileURL)
//        }
    }
}

private struct DocumentURLKey: EnvironmentKey {
    static let defaultValue: URL? = nil
}

extension EnvironmentValues {
    var documentURL: URL? {
        get { self[DocumentURLKey.self] }
        set { self[DocumentURLKey.self] = newValue }
    }
}
