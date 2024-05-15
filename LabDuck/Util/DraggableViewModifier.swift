//
//  DraggableViewModifier.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct DraggableViewModifier: ViewModifier {//바인딩으로 전달. iszooming false면 반영 ture면 반영 안하기.
    @Binding var offset: CGPoint
    //드래그된 뷰의 위치를 저장.

    func body(content: Content) -> some View {
        content.gesture(DragGesture(minimumDistance: 0)
                     //드래그 제스처를 추가하는 SwiftUI의 메서드. 여기서 DragGesture를 사용하여 드래그 제스처를 정의하고, onChanged 클로저 내에서 드래그가 발생할 때마다 드래그의 변화를 처리.
                .onChanged { value in
                    print(value)
                    self.offset.x += value.location.x - value.startLocation.x
                    self.offset.y += value.location.y - value.startLocation.y
                })
            .offset(x: offset.x, y: offset.y) //offset: 드래그된 뷰의 위치를 조정하기 위해 사용되는 SwiftUI의 메서드. offset(x:y:)를 사용하여 x축과 y축으로의 이동을 설정.
    }
    
//    if zoomstate = false {
//     print("반영")
//    }
//    else if zoomstate = true {
//     print("반영하지 않음")
//    }
// 이런 식으로

}
//제스처가 zoom drag제스처 2개가 중복으로 됨. -> 드래그가 진행되고 있기 때문에 줌이 안먹힘. 줌 중에는 마우스 이펙트 안먹게 하기
