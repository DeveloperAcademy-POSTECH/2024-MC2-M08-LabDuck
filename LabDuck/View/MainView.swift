//
//  MainView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI
import Combine

struct MainView: View {
    @State private var zoom = 1.0
    @GestureState private var gestureZoom = 1.0
    @State private var dragOffset = CGSize.zero
    @GestureState private var gestureDrag = CGSize.zero
    
    //@Binding private var zoomstate : Bool

    @State var subs = Set<AnyCancellable>() // Cancel onDisappear
    var body: some View {
        GeometryReader { proxy in
            GraphView()
                .scaleEffect(zoom * gestureZoom)
                .offset(dragOffset + gestureDrag)
        }
        .background(Color.gray)
        .gesture(
            MagnifyGesture()// 업데이트가 되고 있는 상태. zoom하고 있는 상태를 ture로 바꾸고, end가 되면 false로 바꿔주기.
                .updating($gestureZoom) { value, gestureState, _ in
//                    print(value.magnification)
                    if value.magnification > 0 {
                        gestureState = value.magnification
                    }
                    //zoomstate = true
                }
                .onEnded { value in
                    if value.magnification > 0 {
                        zoom *= value.magnification
                    }
                    //zoomstate = false
                }
        )
        .gesture(
            DragGesture()
                .updating($gestureDrag) { value, gestureState, _ in
                    gestureState = value.translation
                }
                .onEnded { value in
                    dragOffset += value.translation
                }
        )
        .onAppear {
            trackScrollWheel()
        }
    }

    private func trackScrollWheel() {
        NSApp.publisher(for: \.currentEvent)
            .filter { event in event?.type == .scrollWheel }
            .sink { (event: NSEvent?) in
                if let event {
                    self.dragOffset.width += event.deltaX
                    self.dragOffset.height += event.deltaY
                }
            }
            .store(in: &subs)
    }
}

#Preview {
    MainView()
}
