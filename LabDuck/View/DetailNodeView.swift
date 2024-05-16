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
    
    //더미 데이터
    @State private var inputTag: String = "#tag1"
    @State private var title: String = "Cracking the code: Co-coding with AI in creative programming education"
    @State private var note: String = "Related work 살펴보기 좋을 듯 함. 근데 어쩌구 저쩌구 어쩌구 저쩌구 어쩌구 저쩌구 어쩌구 저쩌구 어쩌구 쩌구 저쩌구 어쩌구 저쩌구 어쩌구 저쩌구 어쩌구 저쩌구"
    @State private var link: String = "https://dl.acm.org/doi/abs/10.1145/3527927.3532801"
    
    
    @State var kptag:[KPTag] = []
//    @State var kpinputpoint:[KPInputPoint] = []
//    @State var kpoutputpoint:[KPOutputPoint] = []
    
    
    
    
    var body: some View {
        ZStack{
            VStack(spacing: 10) {
                HStack{
                    VStack{
                        
                        //나중에 input/output추가할 때 쓸 코드
                        
                        //                        ForEach(kpinputpoint) { point in
                        //                            Image(systemName: "arrow.right.circle.fill").imageScale(.large).padding(EdgeInsets(top: 20, leading: 8, bottom: 20, trailing: 8))
                        //                        }
                        //
                        //                        Button{kpinputpoint.append(KPInputPoint(id: UUID(), name: inputTag))}label: {
                        //                            Text("+")
                        //                                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                        //                                .background(Color.gray).opacity(0.8)
                        //                                .cornerRadius(20)
                        //                        }.buttonStyle(BorderlessButtonStyle())
                        //                            .background(Color.clear) // 배경을 투명하게 설정
                        //                            .overlay(Rectangle().stroke(Color.clear))
                        Image(systemName: "arrow.right.circle.fill").imageScale(.large).padding(EdgeInsets(top: 20, leading: 8, bottom: 20, trailing: 8))
                        
                        Image(systemName: "arrow.right.circle.fill").imageScale(.large).padding(EdgeInsets(top: 20, leading: 8, bottom: 20, trailing: 8))
                        
                        Image(systemName: "arrow.right.circle.fill").imageScale(.large).padding(EdgeInsets(top: 20, leading: 8, bottom: 20, trailing: 8))
                        
                    }
                    Rectangle()
                        .frame(width: 250, height: 350)
                        .foregroundColor(Color.white)
                        .overlay(
                            VStack(alignment: .leading, spacing: 10) {
                                ScrollView(.horizontal) {
                                    HStack{
                                        
                                        ForEach(kptag) { tag in
                                            Text(inputTag)
                                                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                                                .background(Color.blue)
                                                .cornerRadius(20)
                                        }
                                        
                                        
                                        //태그 추가 버튼
                                        Button{kptag.append(KPTag(id: UUID(), name: inputTag))}label: {
                                            Text("+")
                                                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                                                .background(Color.gray).opacity(0.8)
                                                .cornerRadius(20)
                                        }.buttonStyle(BorderlessButtonStyle())
                                            .background(Color.clear) // 배경을 투명하게 설정
                                            .overlay(Rectangle().stroke(Color.clear))
                                    }
                                }
                                
                                //제목
                                if isEditing {
                                    TextEditor(text: $title).scrollContentBackground(.hidden).background(Color.clear).border(Color.clear, width: 0).foregroundColor(.black).font(.system(size: 20, weight: .bold)).frame(width:200,height: 80)
                                    
                                } else {
                                    Text(title).foregroundColor(.black)
                                        .font(.system(size: 20, weight: .bold)).frame(width:200,height: 80)
                                }
                                
                                Divider().background(.gray).padding(2)
                                
                                //노트
                                Text("Note").foregroundColor(.black)
                                
                                if isEditing {
                                    TextEditor(text: $note).scrollContentBackground(.hidden).background(Color.clear).border(Color.clear, width: 0).foregroundColor(.black).font(.system(size: 13)).frame(width:200,height: 40)
                                } else {
                                    Text(note).foregroundColor(.black)
                                        .font(.system(size: 13, weight: .regular)).frame(width:200,height: 40)
                                }
                                
                                Divider().background(.gray).padding(2)
                                
                                //링크
                                Text("Link").foregroundColor(.black)
                                
                                
                                if isEditing {
                                    TextEditor(text: $link).scrollContentBackground(.hidden).background(Color.clear).border(Color.clear, width: 0).foregroundColor(.blue).underline().font(.system(size: 13))
                                        .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width:200,height: 40)
                                } else {
                                    Link(destination: URL(string: link)!, label: {
                                        Text(link).foregroundColor(.blue).underline()
                                            .font(.system(size: 13, weight: .regular))
                                    }).frame(width:200,height: 40)
                                    
                                }
                            }
                                .padding(20)
                        )
                        .cornerRadius(10)
                    VStack{
                        Image(systemName: "arrow.right.circle.fill").imageScale(.large).padding(EdgeInsets(top: 20, leading: 8, bottom: 20, trailing: 8))
                        
                    }
                }
            }.padding()
            
            //수정 버튼
            Button{isEditing.toggle()}label:{
                Image(systemName: "square.and.pencil").foregroundColor(.gray).opacity(self.hovered ? 1.0 : 0.3).onHover { hover in
                    print("Mouse hover: \(hover)")
                    self.hovered.toggle()
                }
            }.buttonStyle(BorderlessButtonStyle())
                .background(Color.clear) // 배경을 투명하게 설정
                .overlay(Rectangle().stroke(Color.clear)).offset(x:100,y:-110)
        }
        
    }
}

#Preview {
    DetailNodeView()
}
