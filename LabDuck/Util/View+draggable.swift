//
//  View+draggable.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

extension View {
    func draggable(offset: Binding<CGPoint>, onEnded: ((_ offset: CGPoint) -> Void)? = nil) -> some View {
        return modifier(DraggableViewModifier(offset: offset, onEnded: onEnded))
    }
    func draggable(onEnded: ((_ offset: CGPoint) -> Void)? = nil) -> some View {
        return modifier(DraggableViewModifier2(onEnded: onEnded))
    }
}
