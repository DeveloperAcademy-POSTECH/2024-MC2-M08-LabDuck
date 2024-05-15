//
//  CGSize+Operators.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }//두개의 cgsize 받아서 각 구조체의 너비와 높이를 더한 새로운 cgsize 반환
    static func += (lhs: inout Self, rhs: Self) {
        lhs = Self(width: lhs.width + rhs.width, height: lhs.height + rhs.height)//두 CGSize 값을 더하고 첫 번째 값에 결과를 할당
    }
}
