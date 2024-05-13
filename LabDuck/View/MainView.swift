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

    @State var subs = Set<AnyCancellable>() // Cancel onDisappear
    var body: some View {
        GeometryReader { proxy in
            GraphView()
                .scaleEffect(zoom * gestureZoom)
                .offset(dragOffset + gestureDrag)
        }
        .background(Color.gray)
        .gesture(
            MagnifyGesture()
                .updating($gestureZoom) { value, gestureState, _ in
                    gestureState = value.magnification
                }
                .onEnded { value in
                    print(zoom, gestureZoom)
                    zoom *= value.magnification
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
