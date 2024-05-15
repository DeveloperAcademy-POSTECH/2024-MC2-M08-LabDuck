//
//  CGRect+center.swift
//  LabDuck
//
//  Created by 정종인 on 5/14/24.
//

import Foundation

extension CGRect {
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
}
