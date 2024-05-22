//
//  CodingUseCase.swift
//  LabDuck
//
//  Created by 정종인 on 5/22/24.
//

import Foundation

enum CodingErrors: Error {
    case serializationFailed
}

protocol CodingUseCase {
    func encode<T>(_ value: T) -> Result<Data, CodingErrors> where T : Encodable
    func decode<T>(_ type: T.Type, from data: Data) -> Result<T, CodingErrors> where T: Decodable
}

final class JSONCodingUseCase: CodingUseCase {
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func encode<T>(_ value: T) -> Result<Data, CodingErrors> where T : Encodable {
        guard let serialized = try? encoder.encode(value) else { return .failure(.serializationFailed) }

        return .success(serialized)
    }

    func decode<T>(_ type: T.Type, from data: Data) -> Result<T, CodingErrors> where T : Decodable {
        guard let object = try? decoder.decode(T.self, from: data) else { return .failure(.serializationFailed) }

        return .success(object)
    }
}
