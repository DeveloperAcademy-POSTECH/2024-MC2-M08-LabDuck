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
    
    private let minZoom = 0.5
    private let maxZoom = 10.0

    private var scaleValue: Double {
        if zoom * updatingZoom < minZoom {
            return minZoom
        } else if zoom * updatingZoom > maxZoom {
            return maxZoom
        } else {
            return zoom * updatingZoom
        }
    }

    // MARK: - Drag
    @State private var dragOffset = CGSize.zero
    @State private var updatingOffset = CGSize.zero

    private var offsetValue: CGSize {
        CGSize(
            width: min(max(self.dragOffset.width + self.updatingOffset.width, -1000), 1000),
            height: min(max(self.dragOffset.height + self.updatingOffset.height, -1000), 1000)
        )
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
                let newOffset = CGSize(
                    width: self.dragOffset.width + value.translation.width,
                    height: self.dragOffset.height + value.translation.height
                )
                self.dragOffset = CGSize(
                    width: min(max(newOffset.width, -1000), 1000),
                    height: min(max(newOffset.height, -1000), 1000)
                )
                self.updatingOffset = .zero
            }

    }

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            VStack{
                if board.viewType == .graph {
                    GraphView(board: $board, searchText: $searchText)
                        .background(Rectangle().frame(width: 6000, height: 5000).foregroundColor(searchText.isEmpty ? Color.white : Color.black.opacity(0.3)))
                        .offset(offsetValue)
                        .scaleEffect(scaleValue, anchor: .center)
                        .searchable(text: $searchText)
                        .gesture(magnifyGesture(proxy.size.width, proxy.size.height))
                        .gesture(dragGesture)
                        .onAppear {
                            trackScrollWheel()
                        }
                } else {
                    TableView(board: $board, searchText: $searchText)
                }
            }
            
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {}, 
                           label: {
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
                        let center = calculateCenterCoordinate(.zero)
                        board.nodes.append(KPNode(position: CGPoint(x: center.x, y: center.y)))
                    }, label: {
                        Image(systemName: "plus.rectangle")
                    })
                }
            }
            .navigationTitle("\(board.title)")
            .toolbarBackground(Color(hex: 0xEAEAEA))
        }
    }

    // MARK: - TrackScrollWheel
    private func trackScrollWheel() {
        NSApp.publisher(for: \.currentEvent)
            .filter { event in event?.type == .scrollWheel }
            .sink { (event: NSEvent?) in
                if let event {
                    self.dragOffset.width += ( event.deltaX ) * 3.5
                    self.dragOffset.height += ( event.deltaY ) * 3.5
                    self.dragOffset.width = min(max(self.dragOffset.width, -1000), 1000)
                    self.dragOffset.height = min(max(self.dragOffset.height, -1000), 1000)
                }
            }
            .store(in: &subs)
    }
    
    private func calculateCenterCoordinate(_ size: CGSize) -> CGPoint {
        let scaledWidth = size.width * scaleValue
        let scaledHeight = size.height * scaleValue
        let centerX = (scaledWidth / 2) - offsetValue.width
        let centerY = (scaledHeight / 2) - offsetValue.height
        
        return CGPoint(x: centerX , y: centerY)
    }
}

#Preview {
    MainView()
}
