//
//  View+draggable.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

extension View {
    func draggable(offset: Binding<CGPoint>) -> some View {
        return modifier(DraggableViewModifier(offset: offset))
        //offset을 이용하여 드래그의 변화에 따라 뷰를 이동시키고, gesture를 이용하여 드래그 제스처를 처리.
        //DragGesture는 드래그 이벤트를 처리하기 위한 제스처이며, onChanged 클로저에서는 드래그 중에 발생하는 변화를 처리하고, onEnded 클로저에서는 드래그 종료 이벤트를 처리
    }
}
