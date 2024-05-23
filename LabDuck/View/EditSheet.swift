//
//  EditingView.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/23/24.
//

import SwiftUI

struct EditSheet: View {
    @Binding var node: KPNode
    @Binding var board: KPBoard
    @State private var relatedNodes: [KPNode] = []
    let findNodes: (KPNode) -> [KPNode]
    
    var body: some View {
        VStack {
            HStack() {
                Button(action: {
                    
                }) {
                    Image(systemName: "chevron.up")
                        .frame(width: 20, height: 20)
                }
                
                Button(action: {
                    
                }) {
                    Image(systemName: "chevron.down")
                        .frame(width: 20, height: 20)
                }
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .frame(width: 20, height: 20)
                }
                
                Button(action: {
                    
                }) {
                    Image(systemName: "trash")
                        .frame(width: 20, height: 20)
                }
                
                Button(action: {
                    
                }) {
                    Image(systemName: "xmark")
                        .frame(width: 20, height: 20)
                }
            }
            .padding(4)
            .background(node.colorTheme.backgroundColor)
            
            ScrollView() {
                VStack(alignment: .leading) {
                    Section(header: Text("Title")
                        .font(Font.custom("SF Pro", size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 16)
                    ) {
                        styledTextEditor(
                            text: $node.unwrappedTitle,
                            lineLimit: 3,
                            fontSize: 15,
                            height: 84
                        )}
                    
                    Section(header: Text("Note")
                        .font(Font.custom("SF Pro", size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 16)
                    ) {
                        styledTextEditor(
                            text: $node.unwrappedNote,
                            lineLimit: 10,
                            fontSize: 13,
                            height: 100
                        )}
                    
                    Section(header: Text("Related Informations")
                        .font(Font.custom("SF Pro", size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 16)
                    ) {
                        VStack {
                            ForEach(relatedNodes) { relatedNode in
                                HStack {
                                    Rectangle()
                                        .cornerRadius(3)
                                        .frame(width: 14, height: 14)
                                        .background(relatedNode.colorTheme.backgroundColor)
                                    Text(relatedNode.unwrappedTitle)
                                        .foregroundColor(.black.opacity(0.85))
                                        .lineLimit(1)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(hex: 0xFBFBFB))
                                .cornerRadius(6)
                                .frame(height: 40)
                            }
                        }
                    }
                    
                    Section(header: Text("Tags")
                        .font(Font.custom("SF Pro", size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 16)
                    ) {
                        
                        if node.tags.isEmpty {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "tag")
                                        .frame(width: 16, height: 16)
                                    Text("태그 추가")
                                        .font(Font.custom("SF Pro", size: 13))
                                        .foregroundColor(Color(hex: 0x808080))
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(6)
                                .frame(height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.black.opacity(0.1), lineWidth: 1)
                                    
                                )
                                
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        } else {
                            HStack {
                                //tag있을 때 추가 필요하다
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(hex: 0xFBFBFB))
                            .cornerRadius(6)
                            .frame(height: 40)
                        }
                    }
                    
                    Section(header: Text("URL")
                        .font(Font.custom("SF Pro", size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 16)
                    ) {
                        styledTextEditor(
                            text: $node.unwrappedURL,
                            lineLimit: 2,
                            fontSize: 13,
                            height: 40
                        )
                    }
                    Spacer()
                }
            }
            
        }
        .padding(32)
        .background(node.colorTheme.backgroundColor)
        .onAppear() {
            relatedNodes = findNodes(node)
        }
        .onChange(of: node.id) { _, _ in
            relatedNodes = findNodes(node)
        }
        HStack(alignment: .center) {
            Spacer()
            ForEach(KPColorTheme.allCases, id: \.self) { colorTheme in
                Button(action: {
                    node.colorTheme = colorTheme
                }) {
                    Rectangle()
                        .fill(colorTheme.backgroundColor)
                        .frame(width: 16, height: 16)
                        .cornerRadius(3)
                        .padding(3)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            Spacer()
        }
        .frame(height: 86)
        .background(Color.white)
    }
    
    func styledTextEditor(text: Binding<String>, lineLimit: Int, fontSize: CGFloat, height: CGFloat) -> some View {
        TextEditor(text: text)
            .lineLimit(lineLimit)
            .scrollContentBackground(.hidden)
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(6)
            .font(Font.custom("SF Pro", size: fontSize))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
    }
}
