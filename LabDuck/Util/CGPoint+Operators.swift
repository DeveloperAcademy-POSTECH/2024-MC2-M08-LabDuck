//
//  CGPoint+Operators.swift
//  LabDuck
//
//  Created by 정종인 on 5/14/24.
//

import Foundation

extension CGPoint {
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func / (lhs: Self, rhs: CGFloat) -> Self {
        Self(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}
