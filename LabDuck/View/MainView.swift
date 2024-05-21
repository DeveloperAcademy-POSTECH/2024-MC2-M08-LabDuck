//
//  MainView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI
import Combine

struct MainView: View {
    @State private var board: KPBoard = .mockData
    // MARK: - Zoom
    @State private var zoom = 5.0
    @State private var updatingZoom: Double = 1.0

    private var scaleValue: Double {
        if zoom * updatingZoom < 1 {
            return 1
        } else if zoom * updatingZoom > 10 {
            return 10
        } else {
            return zoom * updatingZoom
        }
    }

    // MARK: - Drag
    @State private var dragOffset = CGSize.zero
    @State private var updatingOffset = CGSize.zero

    private var offsetValue: CGSize {
        self.dragOffset + self.updatingOffset
    }

    @State private var subs = Set<AnyCancellable>()

    // MARK: - Search
    @State private var searchText: String = ""

    // MARK: - Gestures
    private func magnifyGesture(_ width: Double, _ height: Double) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                updatingZoom = value.magnification
                if zoom * updatingZoom != scaleValue {
                    zoom = scaleValue
                    updatingZoom = 1.0
                    return
                }
                let currentWidth = width / (zoom * value.magnification)
                let currentHeight = height / (zoom * value.magnification)
                let magnificationDelta = value.magnification - 1.0 // 0 이상 : 확대, 0 이하 : 축소
                self.updatingOffset = CGSize(
                    width: (0.5 - value.startAnchor.x) * currentWidth * magnificationDelta,
                    height: (0.5 - value.startAnchor.y) * currentHeight * magnificationDelta
                )
            }
            .onEnded { value in
                self.zoom = scaleValue
                self.updatingZoom = 1.0
                self.dragOffset = offsetValue
                self.updatingOffset = .zero
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                self.updatingOffset = value.translation
            }
            .onEnded { value in
                dragOffset += value.translation
                updatingOffset = .zero
            }
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            if board.viewType == .graph {
                GraphView(board: $board)
                    .offset(offsetValue)
                    .scaleEffect(scaleValue, anchor: .center)
                    .searchable(text: $searchText)
                    .gesture(magnifyGesture(proxy.size.width, proxy.size.height))
                    .gesture(dragGesture)
                    .onAppear {
                        trackScrollWheel()
                    }
            } else {
                TableView(board: $board)
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
                Picker("View", selection: $board.viewType) {
                    ForEach(KPBoard.BoardViewType.allCases, id: \.self) { view in
                        Text(view.rawValue).tag(view)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }

            ToolbarItem {
                Spacer()
            }
            if board.viewType == .graph {
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

    // MARK: - TrackScrollWheel
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
