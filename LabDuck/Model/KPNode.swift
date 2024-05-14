//
//  KPNode.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

@Observable
class KPNode: Identifiable {
    var id: UUID
    var title: String?
    var note: String?
    var url: String?
    var tags: [KPTag] = []
    var colorTheme: KPColorTheme = .default
    var position: CGPoint = .zero
    var size: CGSize
    var inputPoints: [KPInputPoint] = []
    var outputPoints: [KPOutputPoint] = []

    init(title: String? = nil, note: String? = nil, url: String? = nil, tags: [KPTag] = [], colorTheme: KPColorTheme = .default, position: CGPoint = .zero, size: CGSize = CGSize(width: 400, height: 400), inputPoints: [KPInputPoint] = [], outputPoints: [KPOutputPoint] = []) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.url = url
        self.tags = tags
        self.colorTheme = colorTheme
        self.position = position
        self.size = size
        self.inputPoints = inputPoints
        self.outputPoints = outputPoints
    }
}

extension KPNode {
    var unwrappedTitle: String {
        get {
            self.title ?? ""
        }
        set {
            self.title = newValue
        }
    }
    var unwrappedNote: String {
        get {
            self.note ?? ""
        }
        set {
            self.note = newValue
        }
    }
    var unwrappedURL: String {
        get {
            self.url ?? ""
        }
        set {
            self.url = newValue
        }
    }
}

extension KPNode {
    static var mockData: KPNode {
        .init(title: "title1", position: .init(x: 50, y: 20))
    }
}

extension Array where Element == KPNode {
    static var mockData: [Element] = [
        .init(
            title: "Thrilled by Your Progress! Large Language Models (GPT-4) No Longer Struggle to Pass Assessments in Higher Education Programming Courses",
            url: "https://arxiv.org/pdf/2306.10073.pdf",
            tags: [KPTag.mockData, KPTag.mockData],
            colorTheme: .cyan, 
            position: .init(x: 50, y: 20)),
        .init(
            title: "Cracking the code: Co-coding with AI in creative programming education",
            url: "https://dl.acm.org/doi/abs/10.1145/3527927.3532801",
            position: .init(x: 80, y: 40)),
        .init(
            title: "AlgoSolve: Supporting Subgoal Learning in Algorithmic Problem-Solving with Learnersourced Microtasks",
            note: "Related work 살펴보기 좋을듯",
            url: "https://kixlab.github.io/website-files/2022/chi2022-AlgoSolve-paper.pdf",
            position: .init(x: 110, y: 30)),
        .init(
            title: "Supporting programming and learning-to-program with an integrated CAD and scaffolding workbench",
            tags: [KPTag.mockData],
            position: .init(x: 140, y: 60)),
        .init(
            title: "Robust and Scalable Online Code Execution System",
            note: "Judge0 - code execution system",
            url: "https://ieeexplore.ieee.org/document/9245310",
            tags: [KPTag.mockData],
            position: .init(x: 170, y: 70)),
    ]
}
