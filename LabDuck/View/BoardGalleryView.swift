import SwiftUI
import AppKit

struct KPBoardPreview: Identifiable {
    var id: UUID
    var url: URL
    var title: String
    var modifiedDate: Date
}

struct BoardGalleryView: View {
    @Environment(\.newDocument) private var newDocument

    @State private var previews: [KPBoardPreview] = []

    @State private var showAlert = false
    @State private var selectedBoard: KPBoardPreview?
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
                    ForEach($previews) { preview in
                        VStack {
                            BoardPreviewView(preview: preview, isEditing: Binding(
                                get: { editingBoardID == preview.id },
                                set: { isEditing in
                                    if !isEditing {
                                        editingBoardID = nil
                                    } else {
                                        editingBoardID = preview.id
                                    }
                                }
                            ))
                                .onTapGesture(count: 2) {
                                    Task {
                                        await openDocumentOnMainThread(preview.url.wrappedValue)
                                    }
                                }
                                .contextMenu(ContextMenu(menuItems: {
                                    Button(action: {
                                        Task {
                                            await openDocumentOnMainThread(preview.url.wrappedValue)
                                        }
                                    }) {
                                        Text("파일 보기")
                                    }
                                    Button(action: {
                                        editingBoardID = preview.id
                                    }) {
                                        Text("이름 바꾸기")
                                    }
                                    Button(action: {
//                                        duplicateBoard(board: preview.board)
                                    }) {
                                        Text("파일 복제하기")
                                    }
                                    Button(action: {
//                                        selectedBoard = preview.board
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("파일 삭제하기"),
                  message: Text("정말 삭제하시겠습니까?"),
                  primaryButton: .default(Text("네")) {
                    if let boardToDelete = selectedBoard {
//                        deleteBoard(board: boardToDelete)
                    }
                },
                  secondaryButton: .cancel(Text("아니오")))
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        newDocument { KPBoardDocument() }
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
                    let newBoardDocument = KPBoardDocument()
                    newBoardDocument.board = newBoard
                    newDocument { newBoardDocument }
                } catch {
                    print(error.localizedDescription)
                }
                file.stopAccessingSecurityScopedResource()
            case .failure(let failure):
                print(failure)
            }
        }
        .onAppear {
            loadRecentDocuments()
        }
        .onReceive(NotificationCenter.default.publisher(for: .documentsChanged)) { _ in
            print("documents changed!")
            loadRecentDocuments()
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
//        let newBoard = KPBoard(title: board.title, nodes: board.nodes, edges: board.edges,
//                               texts: board.texts, modifiedDate: Date(), viewType: board.viewType)
//        boards.append(newBoard)
    }

    func deleteBoard(board: KPBoard) {
//        if let index = boards.firstIndex(where: { $0.id == board.id }) {
//            boards.remove(at: index)
//        }
    }
}

extension BoardGalleryView {
    private func loadRecentDocuments() {
        let urls = Array(UserDefaultsCenter.shared.loadDocuments())
        print(urls)
        let previews = urls.compactMap { url in
            do {
                let document = try documentFromFileURL(url)
                let fileName = url.deletingPathExtension().lastPathComponent
                return KPBoardPreview(id: document.board.id, url: url, title: fileName, modifiedDate: document.board.modifiedDate)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        self.previews = previews.sorted { $0.modifiedDate > $1.modifiedDate }
    }

    func documentFromFileURL(_ url: URL) throws -> KPBoardDocument {
        guard url.isFileURL else {
            throw CocoaError(.fileReadInvalidFileName)
        }

        let data = try Data(contentsOf: url)

        let board = try JSONDecoder().decode(KPBoard.self, from: data)

        let document = KPBoardDocument()
        document.board = board

        return document
    }

    @MainActor
    private func openDocumentOnMainThread(_ url: URL) async {
        print(url)
        do {
            try await NSDocumentController.shared.openDocument(withContentsOf: url, display: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    BoardGalleryView()
}
