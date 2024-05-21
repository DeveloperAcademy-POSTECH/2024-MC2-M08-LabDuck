import SwiftUI

struct BoardGallery: View {
    @Environment(\.openWindow) private var openWindow

    @State var boards: [KPBoard] = [.mockData, .mockData, .mockData, .mockData, .mockData, .mockData, .mockData]

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
                    ForEach($boards, id: \.id) { board in
                        BoardView(board: board)
                            .onTapGesture(count: 2) {
                                openWindow(id: "main")
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            
        }
        .frame(minWidth: 800, minHeight: 600)
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
}

extension BoardGallery {
    private func addBoard(_ board: KPBoard) {
        self.boards.append(board)
    }
}

#Preview {
    BoardGallery()
}
