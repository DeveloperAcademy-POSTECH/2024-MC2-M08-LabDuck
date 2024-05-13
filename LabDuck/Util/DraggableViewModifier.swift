//
//  DraggableViewModifier.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct DraggableViewModifier: ViewModifier {
    @Binding var offset: CGPoint

    func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    self.offset.x += value.location.x - value.startLocation.x
                    self.offset.y += value.location.y - value.startLocation.y
                })
            .offset(x: offset.x, y: offset.y)
    }
}
