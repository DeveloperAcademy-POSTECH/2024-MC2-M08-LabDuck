//
//  CGPoint+distance.swift
//  LabDuck
//
//  Created by 정종인 on 5/16/24.
//

import Foundation

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}
