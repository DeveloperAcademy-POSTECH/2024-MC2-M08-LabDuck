import SwiftUI

struct BoardView: View {
    @State var boards: [KPBoard] = [.mockData, .mockData, .mockData, .mockData, .mockData, .mockData, .mockData]
    
    let columns = [
        GridItem(.adaptive(minimum: 240, maximum: .infinity), spacing: 20) // 각 열의 최소 및 최대 너비를 설정하여 줄바꿈되도록 합니다.
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("All files")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 40)
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach($boards, id: \.id) { $board in
                        DetailBoardView(detailboard: $board)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            
        }
        .background(Color.white)
    }
}

#Preview {
    BoardView()
}
