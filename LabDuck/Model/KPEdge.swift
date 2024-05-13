//
//  KPEdge.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

@Observable
class KPEdge: Identifiable {
    var id: UUID
    var sourceID: UUID // OutputPoint의 id
    var sinkID: UUID // InputPoint의 id

    init(sourceID: UUID, sinkID: UUID) {
        self.id = UUID()
        self.sourceID = sourceID
        self.sinkID = sinkID
    }
}
