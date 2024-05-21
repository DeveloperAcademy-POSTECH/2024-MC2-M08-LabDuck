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
    @State private var isGraphView: Bool = true
    @State private var isTableView: Bool = false
    @State private var searchText: String = ""
    
    //@Binding private var zoomstate : Bool
    //@State private var zoomstate: Bool
    @State var subs = Set<AnyCancellable>() // Cancel onDisappear
    
    var body: some View {
        HStack {
            if isGraphView {
                GeometryReader { proxy in
                    GraphView()
                        .scaleEffect(zoom * gestureZoom)
                        .offset(dragOffset + gestureDrag)
                        .searchable(text: $searchText)
                }
                .background(Color.gray)
                .gesture(
                    MagnifyGesture()// 업데이트가 되고 있는 상태. zoom하고 있는 상태를 ture로 바꾸고, end가 되면 false로 바꿔주기.
                        .updating($gestureZoom) { value, gestureState, _ in
                            //                    print(value.magnification)
                            if value.magnification > 0 {
                                gestureState = value.magnification
                            }
                        }
                        .onEnded { value in
                            if value.magnification > 0 {
                                zoom *= value.magnification
                            }
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
            } else {
                TableView()
            }
        }
        // MARK: - 툴바 코드
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {}, label: {
                    Image(systemName: "chevron.backward")
                })
            }
            
            ToolbarItem(placement: .principal) {
                Toggle(isOn: Binding(
                    get: { self.isGraphView },
                    set: { newValue in
                        self.isGraphView = newValue
                        if newValue {
                            self.isTableView = false
                        }
                    })) {
                        Image(systemName: "point.bottomleft.filled.forward.to.point.topright.scurvepath")
                        Text("Graph View")
                    }
            }
            
            ToolbarItem(placement: .principal) {
                Toggle(isOn: Binding(
                    get: { self.isTableView },
                    set: { newValue in
                        self.isTableView = newValue
                        if newValue {
                            self.isGraphView = false
                        }
                    })) {
                        Image(systemName: "tablecells")
                        Text("Table View")
                    }
            }
            
            ToolbarItem {
                Spacer()
            }
            
            if isGraphView {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // 그래프 뷰에서 텍스트 박스 추가 기능 필요
                    }, label: {
                        Image(systemName: "character.textbox")
                    })
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    // 그래프 & 테이블 뷰에서 노드 추가 기능 필요
                }, label: {
                    Image(systemName: "plus.rectangle")
                })
            }
        }
        .navigationTitle("Untitled")    //보드의 이름 나타내는 기능 추가 필요
        .toolbarBackground(Color(hex: 0xEAEAEA))
    }
    
    private func trackScrollWheel() {
        NSApp.publisher(for: \.currentEvent)
            .filter { event in event?.type == .scrollWheel }
            .sink { (event: NSEvent?) in
                if let event {
                    self.dragOffset.width += ( event.deltaX ) * 3.5
                    self.dragOffset.height += ( event.deltaY ) * 3.5
                }
            }
            .store(in: &subs)
    }
}

#Preview {
    MainView()
}
