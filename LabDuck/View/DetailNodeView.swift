//
//  SwiftUIView.swift
//  LabDuck
//
//  Created by Hajin on 5/15/24.
//

import SwiftUI

//업데이트, 읽기 기능 구현!
struct DetailNodeView: View {
    
    @State var hovered: Bool = false
    @State private var isEditing: Bool = false
    
    @State private var nodes: [KPNode] = .mockData
    @State var kptag: [KPTag] = []
    
    //    @State var kpinputpoint:[KPInputPoint] = []
    //    @State var kpoutputpoint:[KPOutputPoint] = []
    
    
    
    
    var body: some View {
        ZStack{
            
            HStack(spacing: 20){
                //좌측 아웃풋 포인트
                VStack(spacing: 70){
                    NodePoint()
                    NodePoint()
                    NodePoint()
                    
                    //나중에 input/output추가할 때 쓸 코드
                    
                    //                        ForEach(kpinputpoint) { point in
                    //                            NodePoint()
                    //                        }
                    //
                    //                        Button{kpinputpoint.append(KPInputPoint(id: UUID(), name: inputTag))}label: {
                    //                            Text("+")
                    //                                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                    //                                .background(Color.gray).opacity(0.8)
                    //                                .cornerRadius(20)
                    //                        }.buttonStyle(BorderlessButtonStyle())
                    //                            .background(Color.clear) // 배경을 투명하게 설정
                    //                            .overlay(Rectangle().stroke(Color.clear)
                    
                }
                ZStack{
                    
                    Rectangle()
                        .frame(width: 250, height: 350)
                        .foregroundColor(Color.white).cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ScrollView(.horizontal) {
                            
                            
                            HStack{
                                
                                ForEach(nodes[0].tags){ tag in
                                    Text("#\(tag.name)").foregroundColor(.white)
                                            .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                                            .background(Color.blue)
                                            .cornerRadius(20)
                                    }
                                    //태그 추가 버튼
                                    Button{
                                        nodes[0].tags.append(.mockData)
                                    }label: {
                                        Text("+")
                                            .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                                            .background(Color.gray).opacity(0.8)
                                            .cornerRadius(20)
                                    }.buttonStyle(BorderlessButtonStyle())
                            }
                            
                        }
                        
                        
                        //제목
                        if isEditing {
                            
                            TextEditor(text: $nodes[0].unwrappedTitle)
                                .scrollContentBackground(.hidden).background(Color.clear).border(Color.clear, width: 0).foregroundColor(.black).font(.system(size: 20, weight: .bold)).frame(width:200,height: 80)
                            
                        } else {
                            
                            Text(nodes[0].unwrappedTitle).foregroundColor(.black)
                                .font(.system(size: 20, weight: .bold)).frame(width:200,height: 80)
                        }
                        
                        Divider().background(.gray).padding(2)
                        
                        //노트
                        Text("Note").foregroundColor(.black)
                        
                        if isEditing {
                            
                            TextEditor(text: $nodes[0].unwrappedNote)
                                .scrollContentBackground(.hidden).background(Color.clear).border(Color.clear, width: 0).foregroundColor(.black).font(.system(size: 13)).frame(width:200,height: 40)
                            
                        } else {
                            
                            Text(nodes[0].unwrappedNote).foregroundColor(.black)
                                .font(.system(size: 13, weight: .regular)).frame(width:200,height: 40)
                        }
                        
                        Divider().background(.gray).padding(2)
                        
                        //링크
                        Text("Link").foregroundColor(.black)
                        
                        
                        if isEditing {
                            TextEditor(text: $nodes[0].unwrappedURL).scrollContentBackground(.hidden).background(Color.clear).border(Color.clear, width: 0).foregroundColor(.blue).underline().font(.system(size: 13)).frame(width:200,height: 40)
                            
                        } else {
                            
                            Link(destination: URL(string: nodes[0].unwrappedURL)!, label: {
                                Text("\(nodes[0].unwrappedURL)").foregroundColor(.blue).underline()
                                    .font(.system(size: 13, weight: .regular))
                            }).frame(width:200,height: 40)
                        }
                        
                        
                        
                    }.frame(width: 200, height: 350).padding(20)
                    
                    
                }
                .cornerRadius(10)
                
                //우측 인풋 포인트
                VStack{
                    NodePoint()
                }
            }
            
            //수정 버튼
            Button{
                isEditing.toggle()
            }label:{
                Image(systemName: "square.and.pencil").foregroundColor(.gray).opacity(self.hovered ? 1.0 : 0.3).onHover { hover in
                    print("Mouse hover: \(hover)")
                    self.hovered = hover
                }
            }.buttonStyle(BorderlessButtonStyle()).offset(x:100,y:-110)
        }
    }
    @ViewBuilder
    private func NodePoint() -> some View {
        Image(systemName: "arrow.right.circle.fill")
            .imageScale(.large)
        
    }
}

#Preview {
    DetailNodeView()
}
