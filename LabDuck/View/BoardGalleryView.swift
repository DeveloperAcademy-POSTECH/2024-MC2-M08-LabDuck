import SwiftUI
import AppKit

struct BoardGallery: View {
    @Environment(\.openWindow) private var openWindow
    
    @State var boards: [KPBoard] = [.mockData2, .mockData, .mockData, .mockData, .mockData, .mockData, .mockData]
    
    @State private var showAlert = false
    @State private var selectedBoard: KPBoard?
    @State private var editingBoardID: UUID?
    
    @State var showFileChooser = false
    
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
                        VStack {
                            BoardView(board: $board, isEditing: Binding(
                                get: { editingBoardID == board.id },
                                set: { isEditing in
                                    if !isEditing {
                                        editingBoardID = nil
                                    } else {
                                        editingBoardID = board.id
                                    }
                                }
                            ))
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
                                    editingBoardID = board.id
                                }) {
                                    Text("이름 바꾸기")
                                }
                                Button(action: {
                                    duplicateBoard(board: board)
                                }) {
                                    Text("파일 복제하기")
                                }
                                Button(action: {
                                    selectedBoard = board
                                    showAlert = true
                                }) {
                                    Text("파일 삭제하기")
                                }
                            }))
                            
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 40)
        }
        .frame(minWidth: 800, minHeight: 600)
        .sheet(isPresented: $showAlert) {
            
            VStack(spacing: 20) {
                Text("\n")
                Text("파일 삭제")
                    .font(.title3)
                    .bold()
                
                Text("이 파일을 삭제하시겠습니까?")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 12))
                
                HStack {
                    Button(action: {
                        showAlert = false
                    }) {
                        Text("취소")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }.buttonStyle(PlainButtonStyle())
                    
                    
                    Button(action: {
                        if let boardToDelete = selectedBoard
                        {
                            deleteBoard(board: boardToDelete)
                        }
                        showAlert = false
                    }) {
                        Text("삭제")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }.buttonStyle(PlainButtonStyle())
                    
                }
                .padding()
            }
            .padding()
            .frame(width: 280, height: 160)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 20)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        self.addBoard(.emptyData)
                    }, label: {
                        Text("새 보드")
                    })
                    CSVImportButton()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .fileImporter(isPresented: $showFileChooser, allowedContentTypes: [.init(filenameExtension: "csv")!]) { result in
            switch result {
            case .success(let file):
                print(file)
                let gotAccess = file.startAccessingSecurityScopedResource()
                if !gotAccess { return }
                do {
                    let contents = try String(contentsOf: file, encoding: .utf8)
                    print(contents)
                    let dictionaryData = try CSVConvertManager.csvStringToDictionary(contents)
                    let parsedNodes = dictionaryData.map { dictionary in
                        CSVConvertManager.dictionaryToKPNode(dictionary)
                    }
                    var newBoard = KPBoard.emptyData
                    newBoard.addNodes(parsedNodes)
                    dump("newBoard : \(newBoard)")
                    self.addBoard(newBoard)
                } catch {
                    print(error.localizedDescription)
                }
                file.stopAccessingSecurityScopedResource()
            case .failure(let failure):
                print(failure)
            }
        }
    }

    @ViewBuilder
    private func CSVImportButton() -> some View {
        Button(action: {
            showFileChooser.toggle()
        }, label: {
            Text("CSV에서 가져오기")
        })
    }
    
    func duplicateBoard(board: KPBoard) {
        let newBoard = KPBoard(title: board.title, nodes: board.nodes, edges: board.edges,
                               texts: board.texts, modifiedDate: Date(), viewType: board.viewType)
        boards.append(newBoard)
    }
    
    func deleteBoard(board: KPBoard) {
        if let index = boards.firstIndex(where: { $0.id == board.id }) {
            boards.remove(at: index)
        }
    }
}

extension BoardGallery {
    private func addBoard(_ board: KPBoard) {
        self.boards.append(board)
    }
}

#Preview {
    BoardGallery()
}
