//
//  KPBoardGallery.swift
//  LabDuck
//
//  Created by 정종인 on 5/22/24.
//

import Foundation

struct KPBoardGallery {
    var version: String
    var boardsURL: [URL]
}

extension KPBoardGallery {
    static var emptyData: KPBoardGallery {
        KPBoardGallery(version: "0.1", boardsURL: [])
    }
}

struct KPBoardPreview {
    var title: String
    var modifiedDate: Date
    var previewImage: Data?
}
