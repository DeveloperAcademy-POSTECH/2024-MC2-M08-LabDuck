//
//  DraggableViewModifier.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct DraggableViewModifier: ViewModifier {
    @Binding var offset: CGPoint
    @GestureState private var gestureOffset: CGSize = .zero
    var onEnded: ((_ offset: CGPoint) -> Void)? = nil
    func body(content: Content) -> some View {
        content
            .offset(x: offset.x + gestureOffset.width, y: offset.y + gestureOffset.height)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($gestureOffset) { value, gestureState, _ in
                        gestureState = value.translation
                    }
                    .onEnded { value in
                        onEnded?(
                            CGPoint(
                                x: self.offset.x + value.translation.width,
                                y: self.offset.y + value.translation.height
                            )
                        )
                    }
            )
    }
}
