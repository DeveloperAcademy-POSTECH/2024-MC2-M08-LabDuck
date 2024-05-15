//
//  KPEdge.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

struct KPEdge: Identifiable {
    var id: UUID
    var sourceID: KPOutputPoint.ID // OutputPoint의 id
    var sinkID: KPInputPoint.ID // InputPoint의 id

    init(sourceID: KPOutputPoint.ID, sinkID: KPInputPoint.ID) {
        self.id = UUID()
        self.sourceID = sourceID
        self.sinkID = sinkID
    }
}
