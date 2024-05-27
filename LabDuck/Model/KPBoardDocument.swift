//
//  KPBoardDocument.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let kpBoardDocument = UTType(exportedAs: "team.kapochip.LabDuck")
}

final class KPBoardDocument: ReferenceFileDocument {
    typealias Snapshot = KPBoard

    @Published var board: KPBoard

    static var readableContentTypes: [UTType] { [.kpBoardDocument] }

    func snapshot(contentType: UTType) throws -> KPBoard {
        self.board
    }

    init() {
        self.board = .emptyData
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.board = try JSONDecoder().decode(KPBoard.self, from: data)
    }

    func fileWrapper(snapshot: KPBoard, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(board)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}

extension KPBoardDocument {
    private func getIndex(_ nodeID: KPNode.ID) -> Int? {
        self.board.nodes.firstIndex { $0.id == nodeID }
    }
    private func getInputPointIndex(_ nodeIndex: Int, _ inputPointID: KPInputPoint.ID) -> Int? {
        self.board.nodes[nodeIndex].inputPoints.firstIndex { $0.id == inputPointID }
    }
}

// MARK: - 노드 세부 사항
extension KPBoardDocument {
    // 전체 노드 
    // 최상위 뷰에서 이를 사용하지 않는 이유는?
    // 1. 노드를 undo / redo 하는 기준을 커스텀 하기 위해서
    // 2. 성능 문제
    // 3. 로직을 여기로 몰아넣고 Modified 시간을 같이 관리하기 위해서
    // 4. NodeView의 node를 @State가 아닌 그냥 일반 변수로 관리하고 싶어서. (성능 향상을 위해)
    // (5. 공식 예제가 이렇게 해서)
    // 6. 노드가 삭제될 때 이걸 undo 하려면 삭제되는 과정을 다시 되풀이 하는게 아니라 한번에 다 보여져야 함.
    func updateNode(node: KPNode, undoManager: UndoManager?) {
        let nodeID = node.id
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index]

        guard self.board.nodes[index] != node else { return }

        self.board.nodes[index] = node

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(node: original, undoManager: undoManager)
        }
    }

    // Title
    func updateNode(_ nodeID: KPNode.ID, title: String?, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].title

        if original == title { return }

        self.board.nodes[index].title = title

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, title: original, undoManager: undoManager)
        }
    }

    // Note
    func updateNode(_ nodeID: KPNode.ID, note: String?, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].note

        self.board.nodes[index].note = note

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, note: original, undoManager: undoManager)
        }
    }

    // URL
    func updateNode(_ nodeID: KPNode.ID, url: String?, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].url

        self.board.nodes[index].url = url

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, url: original, undoManager: undoManager)
        }
    }

    // tags
    func updateNode(_ nodeID: KPNode.ID, tags: [KPTag.ID], undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].tags

        withAnimation {
            self.board.nodes[index].tags = tags
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, tags: original, undoManager: undoManager)
        }
    }

    // tag
    func addTag(_ nodeID: KPNode.ID, tagID: KPTag.ID, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        if self.board.nodes[index].tags.contains(where: { $0 == tagID }) { return }

        withAnimation {
            self.board.nodes[index].tags.append(tagID)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.board.nodes[index].tags.removeLast()
        }
    }

    // ColorTheme
    func updateNode(_ nodeID: KPNode.ID, colorTheme: KPColorTheme, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].colorTheme

        withAnimation {
            self.board.nodes[index].colorTheme = colorTheme
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, colorTheme: original, undoManager: undoManager)
        }
    }

    // Position
    func updateNode(_ nodeID: KPNode.ID, position: CGPoint, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].position

        self.board.nodes[index].position = position

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, position: original, undoManager: undoManager)
        }
    }

    // Size
    func updateNode(_ nodeID: KPNode.ID, size: CGSize, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        let original = self.board.nodes[index].size

        self.board.nodes[index].size = size

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateNode(nodeID, size: original, undoManager: undoManager)
        }
    }

    // add InputPoint
    func addInputPoint(_ nodeID: KPNode.ID, inputPoint: KPInputPoint, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        withAnimation {
            self.board.nodes[index].inputPoints.append(inputPoint)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            withAnimation {
                doc.deleteInputPoint(nodeID, inputPointID: inputPoint.id, undoManager: undoManager)
            }
        }
    }

    // delete InputPoint
    func deleteInputPoint(_ nodeID: KPNode.ID, inputPointID: KPInputPoint.ID, undoManager: UndoManager?) {
        guard let nodeIndex = getIndex(nodeID) else { return }
        guard let inputPointIndex = getInputPointIndex(nodeIndex, inputPointID) else { return }

        let originalInputPoint = withAnimation {
            self.board.nodes[nodeIndex].inputPoints.remove(at: inputPointIndex)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            withAnimation {
                doc.addInputPoint(nodeID, inputPoint: originalInputPoint, undoManager: undoManager)
            }
        }
    }

    // add OutputPoint
    // TODO: - Edge 관련 로직 추가되어야 함
    func addOutputPoint(_ nodeID: KPNode.ID, outputPoint: KPOutputPoint, undoManager: UndoManager?) {
        guard let index = getIndex(nodeID) else { return }

        withAnimation {
            self.board.nodes[index].outputPoints.append(outputPoint)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            withAnimation {
                doc.deleteOutputPoint(nodeID, outputPointID: outputPoint.id, undoManager: undoManager)
            }
        }
    }

    // delete OutputPoint
    // TODO: - Edge 관련 로직 추가되어야 함
    func deleteOutputPoint(_ nodeID: KPNode.ID, outputPointID: KPOutputPoint.ID, undoManager: UndoManager?) {
        guard let nodeIndex = getIndex(nodeID) else { return }
        guard let outputPointIndex = getInputPointIndex(nodeIndex, outputPointID) else { return }

        let originalOutputPoint = withAnimation {
            self.board.nodes[nodeIndex].outputPoints.remove(at: outputPointIndex)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            withAnimation {
                doc.addOutputPoint(nodeID, outputPoint: originalOutputPoint, undoManager: undoManager)
            }
        }
    }
}

// MARK: - 엣지
extension KPBoardDocument {
    func addEdge(edge: KPEdge, undoManager: UndoManager?) {
        self.board.addEdge(edge)

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.removeEdge(edge.id, undoManager: undoManager)
        }

        // MARK: 디버그용 출력 문장들, 추후 삭제 등에 이 코드가 필요할 것 같음
        self.board.nodes.forEach { node in

            node.outputPoints.forEach { outputPoint in
                if outputPoint.id == edge.sourceID {
                    print("outputPoint 정보 : \(outputPoint.name ?? "")")
                    if let ownerNodeID = outputPoint.ownerNode {
                        self.board.nodes.forEach { node in
                            if node.id == ownerNodeID {
                                print("<- 그의 부모는 \(node.title ?? "") 입니다.")
                            }
                        }
                    }
                }
            }
            node.inputPoints.forEach { inputPoint in
                if inputPoint.id == edge.sinkID {
                    print("inputPoint 정보 : \(inputPoint.name ?? "")")


                    if let ownerNodeID = inputPoint.ownerNode {
                        self.board.nodes.forEach { node in
                            if node.id == ownerNodeID {

                                print("<- 그의 부모는 \(node.title ?? "") 입니다.")
                            }
                        }
                    }
                }
            }
        }
    }

    func removeEdge(_ edgeID: KPEdge.ID, undoManager: UndoManager?) {
        let oldEdges = self.board.edges

        withAnimation {
            self.board.removeEdge(edgeID)
            self.board.checkIsLinked()
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceEdges(oldEdges, undoManager: undoManager)
        }
    }

    func replaceEdges(_ edges: [KPEdge], undoManager: UndoManager?, animation: Animation? = .default) {
        let oldEdges = self.board.edges

        self.board.edges = edges
        self.board.checkIsLinked()

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceEdges(oldEdges, undoManager: undoManager, animation: animation)
        }
    }
}

// MARK: - 보드
extension KPBoardDocument {
    func addNode(_ node: KPNode, undoManager: UndoManager?, animation: Animation? = .default) {
        withAnimation(animation) {
            self.board.nodes.append(node)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            withAnimation(animation) {
                doc.removeNode(node.id, undoManager: undoManager, animation: animation)
            }
        }
    }

    func removeNode(_ nodeID: KPNode.ID, undoManager: UndoManager?, animation: Animation? = .default) {
        guard let nodeIndex = getIndex(nodeID) else { return }
        let originalNode = self.board.nodes[nodeIndex]
        let incomingEdges = self.board.edges.filter { edge in
            originalNode.inputPoints.contains { inputPoint in
                inputPoint.id == edge.sinkID
            }
        }
        let outgoingEdges = self.board.edges.filter { edge in
            originalNode.outputPoints.contains { outputPoint in
                outputPoint.id == edge.sourceID
            }
        }
        withAnimation(animation) {
            incomingEdges.forEach { self.board.removeEdge($0.id) }
            outgoingEdges.forEach { self.board.removeEdge($0.id) }
            self.board.nodes.removeAll { $0.id == nodeID }
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            withAnimation(animation) {
                doc.addNode(originalNode, undoManager: undoManager)
                incomingEdges.forEach { doc.addEdge(edge: $0, undoManager: undoManager) }
                outgoingEdges.forEach { doc.addEdge(edge: $0, undoManager: undoManager) }
            }
        }
    }

    func updateBoard(_ oldBoard: KPBoard, _ newBoard: KPBoard, undoManager: UndoManager?, animation: Animation? = .default) {
        withAnimation(animation) {
            self.board = newBoard
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.board = oldBoard
        }
    }

    func replaceBoard(_ newBoard: KPBoard, undoManager: UndoManager?, animation: Animation? = .default) {
        let oldBoard = self.board

        withAnimation(animation) {
            self.board = newBoard
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceBoard(oldBoard, undoManager: undoManager, animation: animation)
        }
    }

    func replaceNodes(_ newNodes: [KPNode], undoManager: UndoManager?, animation: Animation? = .default) {
        let oldNodes = self.board.nodes

        withAnimation(animation) {
            self.board.nodes = newNodes
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceNodes(oldNodes, undoManager: undoManager, animation: animation)
        }
    }

    func changeViewType(to viewType: KPBoard.BoardViewType, animation: Animation? = .default) {
        withAnimation(animation) {
            self.board.viewType = viewType
        }
    }

}

// MARK: - 태그
extension KPBoardDocument {
    // tag를 새로 만들 때 사용.
    // 보드에 해당 tag가 있으면 무시. 아니면 새로 생성.
    func createTag(_ name: String, undoManager: UndoManager?, animation: Animation? = .default) {
        if let tag = self.board.getTag(name) {
            print("Already there : \(tag)")
        } else {
            let tag = withAnimation(animation) {
                self.board.createTag(name)
            }

            undoManager?.registerUndo(withTarget: self) { doc in
                doc.deleteTag(tagID: tag.id, undoManager: undoManager)
            }
        }
    }

    // tag를 삭제할 때 사용.
    // 보드에 해당 tag가 없으면 무시. 아니면 지우기
    func deleteTag(tagID: KPTag.ID, undoManager: UndoManager?, animation: Animation? = .default) {
        guard let original = self.board.getTag(tagID) else { return }

        withAnimation(animation) {
            self.board.deleteTag(tagID)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.board.allTags.append(original)
        }
    }
}

// MARK: - 텍스트
extension KPBoardDocument {
    func createText(_ text: KPText, undoManager: UndoManager?, animation: Animation? = .default) {
        withAnimation(animation) {
            self.board.texts.append(text)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.board.texts.removeLast()
        }
    }

    func updateText(_ text: KPText, undoManager: UndoManager?, animation: Animation? = .default) {
        guard let originalTextIndex = self.board.texts.firstIndex(where: { $0.id == text.id }) else { return }

        let originalText = self.board.texts[originalTextIndex]

        withAnimation(animation) {
            self.board.texts[originalTextIndex] = text
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.board.texts[originalTextIndex] = originalText
        }
    }

    func updateText(_ textID: KPText.ID, position: CGPoint, undoManager: UndoManager?) {
        guard let originalTextIndex = self.board.texts.firstIndex(where: { $0.id == textID }) else { return }

        let original = self.board.texts[originalTextIndex].position

        self.board.texts[originalTextIndex].position = position

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.board.texts[originalTextIndex].position = original
        }
    }

    func deleteText(_ textID: KPText.ID, undoManager: UndoManager?) {
        guard let originalTextIndex = self.board.texts.firstIndex(where: { $0.id == textID }) else { return }

        let originalText = self.board.texts[originalTextIndex]

        self.board.texts.remove(at: originalTextIndex)

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.board.texts.insert(originalText, at: originalTextIndex)
        }
    }

}
