import SwiftUI
import AppKit

struct BoardGallery: View {
    @Environment(\.openWindow) private var openWindow

    @State var boards: [KPBoard] = [.mockData2, .mockData, .mockData, .mockData, .mockData, .mockData, .mockData]
    
    @State private var showAlert = false
    @State private var selectedBoard: KPBoard?

    let columns = [
        GridItem(.adaptive(minimum: 240), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("All files")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 40)
                LazyVGrid(columns: columns) {
                    ForEach($boards, id: \.id) { $board in
                        BoardView(board: $board)
                            .onTapGesture(count: 1) {
                                openWindow(id: "main")
                            }
                            .contextMenu(ContextMenu(menuItems: {
                                Button(action: {
                                    openWindow(id: "main")
                                }) {
                                    Text("파일 보기")
                                }
                                Button(action: {
                                }) {
                                    Text("이름 바꾸기")
                                }
                                Button(action: {
                                    DuplicateBoard(board: board)
                                }) {
                                    Text("파일 복제하기")
                                }
                                Button(action: {
                                    selectedBoard = board
                                    showAlert = true
                                }) {
                                    Text("파일 삭제하기")
                                }
                            })).alert(isPresented: $showAlert) {
                                Alert(title: Text("파일 삭제하기"),
                                      message: Text("정말 삭제하시겠습니까?"),
                                      primaryButton: .default(Text("네")){
                                    if let boardToDelete = selectedBoard {
                                        DeleteBoard(board: boardToDelete)
                                    }
                                },
                                    secondaryButton: .cancel(Text("아니오")))
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 40)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
    
    func DuplicateBoard(board: KPBoard) {
        let newBoard = KPBoard(title: board.title, nodes: board.nodes, edges: board.edges, 
                               texts: board.texts, modifiedDate: board.modifiedDate, viewType: board.viewType)
        boards.append(newBoard)
    }
    
    func DeleteBoard(board: KPBoard) {
        if let index = boards.firstIndex(where: { $0.id == board.id }) {
            boards.remove(at: index)
        }
    }
}

#Preview {
    BoardGallery()
}
