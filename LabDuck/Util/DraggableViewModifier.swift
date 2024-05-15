//
//  DraggableViewModifier.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct DraggableViewModifier: ViewModifier {//바인딩으로 전달. false면 반영 ture면 반영 안하기.
    @Binding var offset: CGPoint
    //@Binding var zoomstate: Bool

    //드래그된 뷰의 위치를 저장.

    func body(content: Content) -> some View {
        content.gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    print(value)
                    self.offset.x += value.location.x - value.startLocation.x
                    self.offset.y += value.location.y - value.startLocation.y
                })
            .offset(x: offset.x, y: offset.y)
    }
    

}
//제스처가 zoom drag제스처 2개가 중복으로 됨. -> 드래그가 진행되고 있기 때문에 줌이 안먹힘. 줌 중에는 마우스 이펙트 안먹게 하기
