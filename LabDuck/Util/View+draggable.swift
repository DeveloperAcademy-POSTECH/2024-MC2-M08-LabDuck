//
//  View+draggable.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

extension View {
    func draggable(offset: Binding<CGPoint>) -> some View {
        return modifier(DraggableViewModifier(offset: offset, hoverState: HoverState()))
    }
}
