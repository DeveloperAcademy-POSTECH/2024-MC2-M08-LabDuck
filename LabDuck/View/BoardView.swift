//
//  BoardView.swift
//  LabDuck
//
//  Created by Park Sang Wook on 5/18/24.
//

import SwiftUI

struct BoardView: View {
    @Binding var board: KPBoard
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image("test")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 240, height: 150)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(board.title)
                    .font(.title3)
                    .bold()
                Text(formattedDate(from: board.modifiedDate))
                    .font(.caption)
            }
            .foregroundColor(Color.black)
            .padding([.leading, .bottom, .trailing], 12)
        }
        .frame(width: 240)
        .background(Color(red: 247/255, green: 247/255, blue: 247/255))
        .cornerRadius(7)
        .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.55), radius: 3, x: 0, y: 0)
        .padding()
    }
    
    func formattedDate(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "오늘, \(formattedTime(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "어제, \(formattedTime(from: date))"
        } else {
            let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
            return "\(daysAgo)일 전, \(formattedTime(from: date))"
        }
    }
    
    func formattedTime(from date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "a h:mm"
        return timeFormatter.string(from: date)
    }
}

#Preview {
    BoardView(board: .constant(.mockData))
}
