//
//  BoardUseCase.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import Foundation

enum BoardErrors: Error {
    case isExistFailed
    case fileNotExist
    case readError
    case writeError
    case decodeError
    case encodeError
}

protocol BoardUseCase {
    func readData(_ path: URL) async -> Result<KPBoard, BoardErrors>
    func saveData(_ path: URL, _ board: KPBoard) async -> Result<Void, BoardErrors>
}

final class DefaultBoardUseCase: BoardUseCase {
    let fileManageUseCase: FileManageUseCase
    let codingUseCase: CodingUseCase
    init(
        fileManageUseCase: FileManageUseCase,
        codingUseCase: CodingUseCase
    ) {
        self.fileManageUseCase = fileManageUseCase
        self.codingUseCase = codingUseCase
    }

    func readData(_ path: URL) async -> Result<KPBoard, BoardErrors> {
        guard case .success(let isExist) = fileManageUseCase.isExist(path) else {
            return .failure(.isExistFailed)
        }

        if !isExist {
            return .failure(.fileNotExist)
        }

        guard case .success(let data) = await fileManageUseCase.readFile(path) else {
            return .failure(.readError)
        }

        guard case .success(let dto) = codingUseCase.decode(KPBoardDTO.self, from: data) else {
            return .failure(.decodeError)
        }

        return .success(toVO(dto))
    }

    func saveData(_ path: URL, _ board: KPBoard) async -> Result<Void, BoardErrors> {
        let dto = toDTO(board)

        guard case .success(let data) = codingUseCase.encode(dto) else {
            return .failure(.encodeError)
        }

        guard case .success = await fileManageUseCase.writeFile(path, contents: data) else {
            return .failure(.writeError)
        }

        return .success(())
    }
}

// MARK: - toDTO
extension DefaultBoardUseCase {
    private func toDTO(_ board: KPBoard) -> KPBoardDTO {
        KPBoardDTO(
            id: board.id,
            title: board.title,
            nodes: board.nodes.map { toDTO($0) },
            edges: board.edges.map { toDTO($0) },
            texts: board.texts.map { toDTO($0) },
            modifiedDate: board.modifiedDate,
            viewType: board.viewType.rawValue,
            previewImage: board.previewImage
        )
    }

    private func toDTO(_ node: KPNode) -> KPNodeDTO {
        KPNodeDTO(
            id: node.id,
            title: node.title,
            note: node.note,
            url: node.url,
            tags: node.tags.map { toDTO($0) },
            colorTheme: node.colorTheme.rawValue,
            positionX: node.position.x,
            positionY: node.position.y,
            sizeWidth: node.size.width,
            sizeHeight: node.size.height,
            inputPoints: node.inputPoints.map { toDTO($0) },
            outputPoints: node.outputPoints.map { toDTO($0) }
        )
    }

    private func toDTO(_ tag: KPTag) -> KPTagDTO {
        KPTagDTO(
            id: tag.id,
            name: tag.name,
            colorTheme: tag.colorTheme.rawValue
        )
    }

    private func toDTO(_ edge: KPEdge) -> KPEdgeDTO {
        KPEdgeDTO(
            id: edge.id,
            sourceID: edge.sourceID,
            sinkID: edge.sinkID
        )
    }

    private func toDTO(_ inputPoint: KPInputPoint) -> KPInputPointDTO {
        KPInputPointDTO(
            id: inputPoint.id,
            name: inputPoint.name,
            ownerNode: inputPoint.ownerNode
        )
    }

    private func toDTO(_ outputPoint: KPOutputPoint) -> KPOutputPointDTO {
        KPOutputPointDTO(
            id: outputPoint.id,
            name: outputPoint.name,
            ownerNode: outputPoint.ownerNode
        )
    }

    private func toDTO(_ text: KPText) -> KPTextDTO {
        KPTextDTO(
            id: text.id,
            text: text.text,
            positionX: text.position.x,
            positionY: text.position.y,
            sizeWidth: text.size.width,
            sizeHeight: text.size.height
        )
    }
}

// MARK: - toVO
extension DefaultBoardUseCase {
    private func toVO(_ boardDTO: KPBoardDTO) -> KPBoard {
        KPBoard(
            id: boardDTO.id ?? UUID(),
            title: boardDTO.title ?? "",
            nodes: (boardDTO.nodes ?? []).map { toVO($0) },
            edges: (boardDTO.edges ?? []).map { toVO($0) },
            texts: (boardDTO.texts ?? []).map { toVO($0) },
            modifiedDate: boardDTO.modifiedDate ?? .now,
            viewType: KPBoard.BoardViewType(rawValue: boardDTO.viewType!) ?? .graph,
            previewImage: boardDTO.previewImage
        )
    }

    private func toVO(_ nodeDTO: KPNodeDTO) -> KPNode {
        KPNode(
            id: nodeDTO.id ?? UUID(),
            title: nodeDTO.title ?? "",
            note: nodeDTO.note ?? "",
            url: nodeDTO.url ?? "",
            tags: (nodeDTO.tags ?? []).map { toVO($0) },
            colorTheme: KPColorTheme(rawValue: nodeDTO.colorTheme!) ?? .default,
            position: CGPoint(x: nodeDTO.positionX ?? .zero, y: nodeDTO.positionY ?? .zero),
            size: CGSize(width: nodeDTO.sizeWidth ?? .zero, height: nodeDTO.sizeHeight ?? .zero),
            inputPoints: (nodeDTO.inputPoints ?? []).map { toVO($0) },
            outputPoints: (nodeDTO.outputPoints ?? []).map { toVO($0) }
        )
    }

    private func toVO(_ tagDTO: KPTagDTO) -> KPTag {
        KPTag(
            id: tagDTO.id ?? UUID(),
            name: tagDTO.name ?? "",
            colorTheme: KPTagColor(rawValue: tagDTO.colorTheme!) ?? .default
        )
    }

    private func toVO(_ edgeDTO: KPEdgeDTO) -> KPEdge {
        KPEdge(sourceID: edgeDTO.sourceID ?? UUID(), sinkID: edgeDTO.sinkID ?? UUID())
    }

    private func toVO(_ inputPointDTO: KPInputPointDTO) -> KPInputPoint {
        KPInputPoint(
            id: inputPointDTO.id ?? UUID(), 
            name: inputPointDTO.name,
            ownerNode: inputPointDTO.ownerNode
        )
    }

    private func toVO(_ outputPointDTO: KPOutputPointDTO) -> KPOutputPoint {
        KPOutputPoint(
            id: outputPointDTO.id ?? UUID(),
            name: outputPointDTO.name,
            ownerNode: outputPointDTO.ownerNode
        )
    }

    private func toVO(_ textDTO: KPTextDTO) -> KPText {
        KPText(
            id: textDTO.id ?? UUID(),
            text: textDTO.text ?? "",
            position: CGPoint(x: textDTO.positionX ?? .zero, y: textDTO.positionY ?? .zero),
            size: CGSize(width: textDTO.sizeWidth ?? .zero, height: textDTO.sizeHeight ?? .zero)
        )
    }
}
